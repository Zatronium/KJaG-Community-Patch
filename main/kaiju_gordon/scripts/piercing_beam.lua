require 'scripts/avatars/common'

-- Global values.
local kaiju = nil;
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
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

function onTargets(position)
	targetPos = position;
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_breath");
	registerAnimationCallback(this, kaiju, "start");
	startCooldown(kaiju, abilityData.name);
	local empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	damageAmount = damageAmount + damageAmount * empower;
end

function onAnimationEvent(a)
	kaiju = a;
	beamOrigin = kaiju:getWorldPosition();
	local view = kaiju:getView();
	view:pauseAnimation(beamDuration);
	
	playSound("PiercingBeam");

	if targetEnt then
		targetPos =  targetEnt:getWorldPosition();
	end
	beamEnd = getBeamEndWithPoint(beamOrigin, getWeaponRange(weapon), targetPos);
	
	local view = kaiju:getView();
	local sceneBeamOrigin = view:getAnimationNodePosition('breath_node');
	sceneBeamEnd = getScenePosition(beamEnd);
	sceneBeamFacing = getFacingAngle(sceneBeamOrigin, sceneBeamEnd);
	
	local fired = false;
	
	local targets = getTargetsInBeam(beamOrigin, beamEnd, 35, EntityFlags(EntityType.Vehicle, EntityType.Avatar, EntityType.Zone));
	for t in targets:iterator() do
		if damageAmount > 0 and t and not isSameEntity(t, kaiju) then
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
			
			applyFire(kaiju, t, 0.75);
			applyDamageWithWeaponDamage(kaiju, t, weapon, damageAmount);
							
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