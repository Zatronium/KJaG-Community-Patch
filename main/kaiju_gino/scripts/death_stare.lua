require 'scripts/common'

local kaiju = nil;
local weaponRange = 750;
local beamDuration = 1.0;
local tickTime = 0.1;
local weaponFiringArc = 75.0
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
	beamAura:setTag('deathStare');
	beamAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	beamAura:setTickParameters(tickTime, beamDuration);
	beamAura:setTarget(a); -- required so aura doesn't autorelease
	playSound("deathstare");
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
	
	if targetEnt and canTarget(targetEnt) then
		newTargetPos = targetEnt:getWorldPosition();
	end
	
	local beamEnd = getBeamEndWithFacing(worldPos, weaponRange, kaijuFacing)
	if newTargetPos then
		beamEnd = getBeamEndWithPoint(worldPos, weaponRange, newTargetPos)
	end
	
	local view = kaiju:getView();
	local sceneBeamOrigin = view:getAnimationNodePosition('breath_node');
	local sceneBeamEnd = getScenePosition(beamEnd);
	local sceneBeamFacing = getFacingAngle(sceneBeamOrigin, sceneBeamEnd);
	
	if targetEnt then
		applyDamageWithWeapon(kaiju, targetEnt, "weapon_EyeBeam2");
		createEffect("effects/onRadiated.plist", position);
	end
	view:doBeamEffectFromNode('eye_node_01', sceneBeamEnd, 'effects/deathStare.plist', sceneBeamFacing);
	view:doBeamEffectFromNode('eye_node_02', sceneBeamEnd, 'effects/deathStare.plist', sceneBeamFacing);
	view:doEffectFromNode('eye_node_01', 'effects/deathStare_muzzleGlow.plist', 0);
	view:doEffectFromNode('eye_node_02', 'effects/deathStare_muzzleGlow.plist', 0);
	
	createEffect("effects/explosion_BoomLayer.plist",		sceneBeamEnd);
	createEffect("effects/explosion_SmokeLayer.plist",		sceneBeamEnd);
	createEffect("effects/explosion_SparkLayer.plist",		sceneBeamEnd);
	createEffect("effects/explosion_SparkFireLayer.plist",	sceneBeamEnd);
end