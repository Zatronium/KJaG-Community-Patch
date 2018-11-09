require 'scripts/avatars/common'

-- Global values.
kaiju = nil;
angle = 90;
beamDuration = 0.5;

weapon = "goop_Glare2"
beamNode = "iris"

pulses = 5;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

function onTargets(position)
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), position);
	kaiju:setWorldFacing(facingAngle);
	local view = kaiju:getView();
	playAnimation(kaiju, "ability_breath");
	registerAnimationCallback(this, kaiju, "start");
end

function onAnimationEvent(a, event)
	local beamAura = Aura.create(this, kaiju);
	beamAura:setScriptCallback(AuraEvent.OnTick, 'beamTick');
	beamAura:setTickParameters(beamDuration, 0);
	beamAura:setTarget(kaiju); -- required so aura doesn't autorelease
	local view = kaiju:getView();
	view:togglePauseAnimation(true);
	startAbilityUse(kaiju, abilityData.name);
	playSound("goop_ability_WideGlare");
end

function beamTick(aura)
	local view = kaiju:getView();
	pulses = pulses - 1;
	if pulses <= 0 then
		aura:getOwner():detachAura(aura);
		view:togglePauseAnimation(false);
		view:pauseAnimation(beamDuration);
		endAbilityUse(kaiju, abilityData.name);
	end
	local range = getWeaponRange(weapon);
	local worldPosition = kaiju:getWorldPosition();
	local worldFacing = kaiju:getWorldFacing();
	local targets = getTargetsInCone(worldPosition, range, angle, worldFacing, EntityFlags(EntityType.Zone, EntityType.Vehicle, EntityType.Avatar));
	
	local totaltargets = 6;
	
		-- angle compare
	local startAngle = worldFacing - angle;
	if startAngle < 0 then
		startAngle = startAngle + 360;
	end
	
	local doBeam = true;
	
	for t in targets:iterator() do
		if not isSameEntity(t, kaiju) then
		--	if doBeam and totaltargets > 0 then
		--		totaltargets = totaltargets - 1;
		--		beamEffect(t:getWorldPosition());
		--		doBeam = false;
		--	else 
		--		doBeam = true;
		--	end
			
			applyDamageWithWeapon(kaiju, t, weapon);
		end
	end
	
	local halfRange = getWeaponRange(weapon) * 0.5;
	local center = getBeamEndWithFacing(worldPosition, halfRange, worldFacing);
	while totaltargets > 0 do
		totaltargets = totaltargets - 1;
		local pt = offsetRandomDirection(center, halfRange * 0.5, halfRange)
		beamEffect(pt);
	end
end

function beamEffect(worldpos)
	local view = kaiju:getView();
	local pos = getScenePosition(worldpos);
	
	view:doBeamWeaponFromNode('eyeball', pos, weapon, Point(0, 0));
	
--	view:doBeamEffectFromNode(beamNode, pos, 'effects/beam_rad.plist', 0 );
--	view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
		
--	createEffect("effects/explosion_BoomLayer.plist",		pos);
--	createEffect("effects/explosion_SmokeLayer.plist",		pos);
--	createEffect("effects/explosion_SparkLayer.plist",		pos);
--	createEffect("effects/explosion_SparkFireLayer.plist",	pos);
end