require 'scripts/common'

local kaiju = nil;
local weaponRange = 500;
local beamDuration = 1.0;
local tickTime = 0.125;
local weaponFiringArc = 60.0
local zoneTarget = nil

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', weaponRange);
end

function onTargets(position)
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), position);
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_eyeblast");
	registerAnimationCallback(this, kaiju, "start");
	startCooldown(kaiju, abilityData.name);
end

function onAnimationEvent(a)
	local view = a:getView();
	view:pauseAnimation(beamDuration);
	
	local beamAura = Aura.create(this, a);
	beamAura:setTag('gino_eyeBeam');
	beamAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	beamAura:setTickParameters(tickTime, beamDuration);
	beamAura:setTarget(a); -- required so aura doesn't autorelease
	playSound("gino_eye_beam");
end

function onTick(aura)
	if not aura then
		return
	end
	local targetEnt 	= getAbilityTarget(kaiju, abilityData.name);
	local newTargetPos 	= nil
	local kaijuFacing 	= kaiju:getWorldFacing()
	local worldPos 		= kaiju:getWorldPosition()
	
	if not zoneTarget == nil and targetEnt and canTarget(targetEnt) and getEntityType(targetEnt) == EntityType.Zone then
		zoneTarget = true
	else
		zoneTarget = false
	end
	
	if (not targetEnt or not canTarget(targetEnt)) and not zoneTarget then
		targetEnt = getTargetInEntityRadius(kaiju, weaponRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar, EntityType.Minion), TargetFlags(TargetType.Air, TargetType.Land, TargetType.Sea), weaponFiringArc)
	end
	
	if not targetEnt or not canTarget(targetEnt) then
		targetEnt = getTargetInEntityRadius(kaiju, weaponRange, EntityFlags(EntityType.Zone), TargetFlags(TargetType.Land), weaponFiringArc)
	end
	
	if (not targetEnt or not canTarget(targetEnt)) and zoneTarget then
		targetEnt = getTargetInEntityRadius(kaiju, weaponRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar, EntityType.Minion), TargetFlags(TargetType.Air, TargetType.Land, TargetType.Sea), weaponFiringArc)
	end
	
	local beamEnd = getBeamEndWithFacing(worldPos, weaponRange, kaijuFacing)
	if targetEnt and canTarget(targetEnt) then
		newTargetPos = targetEnt:getWorldPosition();
		if newTargetPos then
			beamEnd = newTargetPos
		end
	end
	
	local view = kaiju:getView();
	local sceneBeamOrigin = view:getAnimationNodePosition('breath_node');
	local sceneBeamEnd = getScenePosition(beamEnd);
	local sceneBeamFacing = getFacingAngle(sceneBeamOrigin, sceneBeamEnd);
	
	if targetEnt then
		applyFire(kaiju, targetEnt, 0.75);
		applyDamageWithWeapon(kaiju, targetEnt, "weapon_EyeBeam1");
	end
	view:doBeamEffectFromNode('eye_node_01', sceneBeamEnd, 'effects/eyeBeam.plist', sceneBeamFacing);
	view:doBeamEffectFromNode('eye_node_02', sceneBeamEnd, 'effects/eyeBeam.plist', sceneBeamFacing);
	view:doEffectFromNode('eye_node_01', 'effects/eyeBeam_muzzleGlow.plist', 0);
	view:doEffectFromNode('eye_node_02', 'effects/eyeBeam_muzzleGlow.plist', 0);
	
	createEffect("effects/explosion_BoomLayer.plist",		sceneBeamEnd);
	createEffect("effects/explosion_SmokeLayer.plist",		sceneBeamEnd);
	createEffect("effects/explosion_SparkLayer.plist",		sceneBeamEnd);
	createEffect("effects/explosion_SparkFireLayer.plist",	sceneBeamEnd);
end