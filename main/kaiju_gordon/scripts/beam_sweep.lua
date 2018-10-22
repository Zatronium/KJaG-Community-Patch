require 'scripts/avatars/common'

-- Global values.
local avatar = nil;
local targetPos = 0;
local beamDuration = 1.0;
local tickTime = 0.125;

local waitTime = tickTime * 4;

local weapon = "RadBeam1"
local beamNode = "breath_node"

local empower = 0;

local sweepDuration = 1;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

function onTargets(position)
	targetPos = position;
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);
	local view = avatar:getView();
	playAnimation(avatar, "ability_breath");
	registerAnimationCallback(this, avatar, "start");
end

function onAnimationEvent(a, event)
	local view = avatar:getView();
	view:pauseAnimation(beamDuration);
	playSound("BeamSweep");
	local range = getWeaponRange(weapon);
	local worldPosition = avatar:getWorldPosition();
	local worldFacing = avatar:getWorldFacing();
	local targets = getTargetsInCone(worldPosition, range, 45, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Avatar));
	
	local totaltargets = 6;
	
		-- angle compare
	local startAngle = worldFacing - 45;
	if startAngle < 0 then
		startAngle = startAngle + 360;
	end
	
	for t in targets:iterator() do
		if not isSameEntity(t, avatar) then
			totaltargets = totaltargets - 1;
			if totaltargets > 0 then
				local tAura = Aura.create(this, avatar);
				tAura:setTag('beam_sweep');
				tAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
				tAura:setTickParameters(tickTime, 0);
				
				local currentAngle = getFacingAngle(worldPosition, t:getWorldPosition());
				if currentAngle < 0 then
					currentAngle = currentAngle + 360;
				end
	
				local scale = (currentAngle - startAngle);

				scale = 1 - (scale / 90);
				
				tAura:setUpdateDelay(scale * sweepDuration);
				tAura:setTarget(t); -- required so aura doesn't autorelease
			end
		end
	end
	
	local halfRange = getWeaponRange(weapon) * 0.5;
	local center = getBeamEndWithFacing(worldPosition, halfRange, worldFacing);
	while totaltargets > 0 do
		totaltargets = totaltargets - 1;
		local pt = offsetRandomDirection(center, halfRange * 0.5, halfRange)
		
		local dummy = spawnEntity(EntityType.Minion, "unit_shrubby_patch", pt);
		dummy:setImmobile(true);
		
		local tAura = Aura.create(this, avatar);
		tAura:setTag('beam_sweep');
		tAura:setScriptCallback(AuraEvent.OnTick, 'dummyTick');
		tAura:setTickParameters(tickTime, 0);
		
		local currentAngle = getFacingAngle(worldPosition, pt);
		if currentAngle < 0 then
			currentAngle = currentAngle + 360;
		end
	       
		local scale = (currentAngle - startAngle);
        
		scale = 1 - (scale / 90);
		
		tAura:setUpdateDelay(scale * sweepDuration);
		tAura:setTarget(dummy); -- required so aura doesn't autorelease	
	end
	startCooldown(avatar, abilityData.name);
	empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);

end

function dummyTick(aura)
	local view = avatar:getView();
	
	local currentTarget = aura:getTarget();
	local pos = getScenePosition(currentTarget:getWorldPosition());
	
	view:doBeamEffectFromNode(beamNode, pos, 'effects/beam_rad.plist', 0 );
	view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
	
	createEffect("effects/explosion_BoomLayer.plist",		pos);
	createEffect("effects/explosion_SmokeLayer.plist",		pos);
	createEffect("effects/explosion_SparkLayer.plist",		pos);
	createEffect("effects/explosion_SparkFireLayer.plist",	pos);
		
	aura:getOwner():detachAura(aura);
	removeEntity(currentTarget);
end

function onTick(aura)
	avatar = getPlayerAvatar();
	local view = avatar:getView();
	
	local currentTarget = aura:getTarget();
	local pos = getScenePosition(currentTarget:getWorldPosition());
	
	view:doBeamEffectFromNode(beamNode, pos, 'effects/beam_rad.plist', 0 );
	view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
	
	createEffect("effects/explosion_BoomLayer.plist",		pos);
	createEffect("effects/explosion_SmokeLayer.plist",		pos);
	createEffect("effects/explosion_SparkLayer.plist",		pos);
	createEffect("effects/explosion_SparkFireLayer.plist",	pos);
	
	applyFire(avatar, currentTarget, 0.75);
	
	abilityEnhance(empower);
	applyDamageWithWeapon(avatar, currentTarget, weapon);
	abilityEnhance(0);
	if aura:getElapsed() >= beamDuration then
		aura:getOwner():detachAura(aura);
	end
end