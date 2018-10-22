require 'scripts/avatars/common'

-- Global values.
local avatar = nil;
local targetPos = 0;
local beamDuration = 1.0;
tickTime = beamDuration / 7;

local weapon = "RadBeam1"
local beamNode = "breath_node"

local beamWidth = 180;

local sceneBeamFacing = 0;
local sceneBeamEnd = nil;
local beamEnd = nil;
local beamOrigin = nil;
local beamAura = nil;

local empower = 0;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

function onTargets(position)
	targetPos = position;
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);
	playAnimation(avatar, "ability_breath");
	registerAnimationCallback(this, avatar, "start");
	empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
	startCooldown(avatar, abilityData.name);
end

function onAnimationEvent(a)
	beamOrigin = avatar:getWorldPosition();
	local view = avatar:getView();
	view:pauseAnimation(beamDuration);
	
	beamAura = Aura.create(this, avatar);
	beamAura:setTag('eyeBeam');
	beamAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	beamAura:setTickParameters(tickTime, beamDuration);
	beamAura:setTarget(avatar); -- required so aura doesn't autorelease
	playSound("RadBeam");
end

function onTick(aura)
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
	
	local currentTarget = getClosestTargetInBeam(beamOrigin, beamEnd, beamWidth, EntityFlags(EntityType.Vehicle, EntityType.Avatar), avatar);
	if currentTarget then	
		local pos = getScenePosition(currentTarget:getWorldPosition());
		
		view:doBeamEffectFromNode(beamNode, pos, 'effects/beam_rad.plist', sceneBeamFacing );
		view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
		
		createEffect("effects/explosion_BoomLayer.plist",		pos);
		createEffect("effects/explosion_SmokeLayer.plist",		pos);
		createEffect("effects/explosion_SparkLayer.plist",		pos);
		createEffect("effects/explosion_SparkFireLayer.plist",	pos);
		
		applyFire(avatar, currentTarget, 0.75);
		abilityEnhance(empower);
		applyDamageWithWeapon(avatar, currentTarget, weapon);
		abilityEnhance(0);		
	else 
		view:doBeamEffectFromNode(beamNode, sceneBeamEnd, 'effects/beam_rad.plist', sceneBeamFacing );
		view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
		
		createEffect("effects/explosion_BoomLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SmokeLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkFireLayer.plist",	sceneBeamEnd);
	end
	if aura:getElapsed() >= beamDuration then
		aura:getOwner():detachAura(aura);
	end
end