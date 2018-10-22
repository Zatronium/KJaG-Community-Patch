require 'scripts/avatars/common'

-- Global values.
local avatar = nil;
local targetPos = 0;
local beamDuration = 1.0;
local tickTime = 0.125;

local weapon = "PiercingBeam1"

local sceneBeamFacing = 0;
local sceneBeamEnd = nil;
local beamEnd = nil;
local beamOrigin = nil;
local beamAura = nil;

local damageAmount = 50;
local damageDecay = 5;

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
	startCooldown(avatar, abilityData.name);
	local empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
	damageAmount = damageAmount + damageAmount * empower;
end

function onAnimationEvent(a)
	avatar = a;
	beamOrigin = avatar:getWorldPosition();
	local view = avatar:getView();
	view:pauseAnimation(beamDuration);
	
	playSound("PiercingBeam");

	if targetEnt then
		targetPos =  targetEnt:getWorldPosition();
	end
	beamEnd = getBeamEndWithPoint(beamOrigin, getWeaponRange(weapon), targetPos);
	
	local view = avatar:getView();
	local sceneBeamOrigin = view:getAnimationNodePosition('breath_node');
	sceneBeamEnd = getScenePosition(beamEnd);
	sceneBeamFacing = getFacingAngle(sceneBeamOrigin, sceneBeamEnd);
	
	local fired = false;
	
	local targets = getTargetsInBeam(beamOrigin, beamEnd, 35, EntityFlags(EntityType.Vehicle, EntityType.Avatar, EntityType.Zone));
	for t in targets:iterator() do
		if damageAmount > 0 and (not isSameEntity(t, avatar)) then
			fired = true;
			local pos = getScenePosition(t:getWorldPosition());
		
			if damageAmount == damageDecay then
				local d = getDistanceFromPoints(beamOrigin, pos);
				
				view:doBeamEffectFromNode('breath_node', getEndOfBeamPosition(beamOrigin, sceneBeamFacing, d), 'effects/beam_piercing.plist', sceneBeamFacing );
				view:doEffectFromNode('breath_node', 'effects/eyeBeam_muzzleGlow.plist', 0);
			end
			
			createEffect("effects/explosion_BoomLayer.plist",		pos);
			createEffect("effects/explosion_SmokeLayer.plist",		pos);
			createEffect("effects/explosion_SparkLayer.plist",		pos);
			createEffect("effects/explosion_SparkFireLayer.plist",	pos);
			
			applyFire(avatar, t, 0.75);
			applyDamageWithWeaponDamage(avatar, t, weapon, damageAmount);
							
			damageAmount = damageAmount - damageDecay;
		end
	end
	
	if not fired then
		view:doBeamEffectFromNode('breath_node', sceneBeamEnd, 'effects/beam_piercing.plist', sceneBeamFacing );
		view:doEffectFromNode('breath_node', 'effects/eyeBeam_muzzleGlow.plist', 0);
		
		createEffect("effects/explosion_BoomLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SmokeLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkFireLayer.plist",	sceneBeamEnd);
	end
end