require 'scripts/avatars/common'

-- Global values.
local kaiju = nil;
local targetPos = 0;
local beamDuration = 1.0;
local tickTime = 0.125;

local weapon = "PiercingBeam2"

local sceneBeamFacing = 0;
local sceneBeamEnd = nil;
local beamEnd = nil;
local beamOrigin = nil;
local beamAura = nil;

local damageAmount = 100;
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
end

function onAnimationEvent(a)
	kaiju = a;
	beamOrigin = kaiju:getWorldPosition();
	local view = kaiju:getView();
	view:pauseAnimation(beamDuration);
	

	playSound("IgnitionBeam");

	if targetEnt then
		targetPos =  targetEnt:getWorldPosition();
	end
	beamEnd = getBeamEndWithPoint(beamOrigin, getWeaponRange(weapon), targetPos);
	
	local view = kaiju:getView();
	local sceneBeamOrigin = view:getAnimationNodePosition('breath_node');
	sceneBeamEnd = getScenePosition(beamEnd);
	sceneBeamFacing = getFacingAngle(sceneBeamOrigin, sceneBeamEnd);
	local fired = false;
	local targets = getTargetsInBeam(beamOrigin, beamEnd, 35, EntityFlags(EntityType.Vehicle, EntityType.Avatar));
	
	local empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	abilityEnhance(empower);

	for t in targets:iterator() do
		if damageAmount > 0 and t and not isSameEntity(t, kaiju) then
			fired = true;
			local pos = getScenePosition(t:getWorldPosition());
		
			view:doBeamEffectFromNode('breath_node', pos, 'effects/beam_piercing.plist', sceneBeamFacing );
			view:doBeamEffectFromNode('breath_node', pos, 'effects/beam_piercingSparks.plist', sceneBeamFacing );
			view:doEffectFromNode('breath_node', 'effects/eyeBeam_muzzleGlow.plist', 0);
			
			createEffect("effects/explosion_BoomLayer.plist",		pos);
			createEffect("effects/explosion_SmokeLayer.plist",		pos);
			createEffect("effects/explosion_SparkLayer.plist",		pos);
			createEffect("effects/explosion_SparkFireLayer.plist",	pos);
			
			applyFire(kaiju, t, 0.75);
			applyDamageWithWeaponDamage(kaiju, t, weapon, damageAmount);
							
			damageAmount = damageAmount - damageDecay;
		end
	end
	
	abilityEnhance(0);
	
	if not fired then
		view:doBeamEffectFromNode('breath_node', sceneBeamEnd, 'effects/beam_piercing.plist', sceneBeamFacing );
		view:doBeamEffectFromNode('breath_node', sceneBeamEnd, 'effects/beam_piercingSparks.plist', sceneBeamFacing );
		view:doEffectFromNode('breath_node', 'effects/eyeBeam_muzzleGlow.plist', 0);
		
		createEffect("effects/explosion_BoomLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SmokeLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkFireLayer.plist",	sceneBeamEnd);
	end
end