require 'scripts/avatars/common'

-- Global values.
local avatar = nil;
local targetPos = 0;
local beamDuration = 1.0;
local tickTime = 0.125;

local waitTime = 0.5;

local numberOfPulses = 3;
local pulseNumber = 0;
local shot = 0;

local weapon = "RadBeam1"
local beamNode = "breath_node"

local sceneBeamFacing = 0;
local sceneBeamEnd = nil;
local beamEnd = nil;
local beamOrigin = nil;
local beamAura = nil;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

function onTargets(position)
	targetPos = position;
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);
	local view = avatar:getView();
	view:setAnimation("ability_breath", false);
	registerAnimationCallback(this, avatar, "start");
	startCooldown(avatar, abilityData.name);
end

function onAnimationEvent(a, event)
	beamOrigin = avatar:getWorldPosition();
	local view = avatar:getView();
	view:pauseAnimation(beamDuration * numberOfPulses + (numberOfPulses - 1) * waitTime);
	
	local empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
	abilityEnhance(empower);
	
	beamAura = Aura.create(this, avatar);
	beamAura:setTag('eyeBeam');
	beamAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	beamAura:setTickParameters(tickTime, 0);
	beamAura:setTarget(avatar); -- required so aura doesn't autorelease
	playSound("PulsedRads");
end

function onTick(aura)
	local elapsed = aura:getElapsed();

	if elapsed <= beamDuration then
		avatar = getPlayerAvatar();
		local targetEnt = getAbilityTarget(avatar, abilityData.name);
		if targetEnt then
			targetPos =  targetEnt:getWorldPosition();
		end
		beamEnd = getBeamEndWithPoint(beamOrigin, getWeaponRange(weapon), targetPos);
		
		local view = avatar:getView();
		local sceneBeamOrigin = view:getAnimationNodePosition('breath_node');
		sceneBeamEnd = getScenePosition(beamEnd);
		sceneBeamFacing = getFacingAngle(sceneBeamOrigin, sceneBeamEnd);
		
		local currentTarget = getClosestTargetInBeam(beamOrigin, beamEnd, 35, EntityFlags(EntityType.Vehicle, EntityType.Avatar), avatar);
		if currentTarget then	
			local pos = getScenePosition(currentTarget:getWorldPosition());
			
			view:doBeamEffectFromNode(beamNode, pos, 'effects/beam_rad.plist', sceneBeamFacing );
			view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
			
			createEffect("effects/explosion_BoomLayer.plist",		pos);
			createEffect("effects/explosion_SmokeLayer.plist",		pos);
			createEffect("effects/explosion_SparkLayer.plist",		pos);
			createEffect("effects/explosion_SparkFireLayer.plist",	pos);
			
			applyFire(avatar, currentTarget, 0.75);
			applyDamageWithWeapon(avatar, currentTarget, weapon);
		else 
			view:doBeamEffectFromNode(beamNode, sceneBeamEnd, 'effects/beam_rad.plist', sceneBeamFacing );
			view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
			
			createEffect("effects/explosion_BoomLayer.plist",		sceneBeamEnd);
			createEffect("effects/explosion_SmokeLayer.plist",		sceneBeamEnd);
			createEffect("effects/explosion_SparkLayer.plist",		sceneBeamEnd);
			createEffect("effects/explosion_SparkFireLayer.plist",	sceneBeamEnd);
		end
	end
	
	if elapsed >= beamDuration + waitTime then
		pulseNumber = pulseNumber + 1;
		if pulseNumber >= numberOfPulses then
			local view = avatar:getView();
			view:addAnimation("idle", true);
			aura:getOwner():detachAura(aura);
			abilityEnhance(0);
		else
			aura:resetElapsed();
		end
		
	end
end