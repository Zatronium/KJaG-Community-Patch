require 'scripts/common'
require 'scripts/abstraction'

-- Global values.
local kaiju = nil;
local targetPos = 0;
local weaponRange = 800;
local beamDuration = 1.0;
local tickTime = 0.125;
local weaponFiringAngle = 60.0

local sceneBeamFacing = 0;
local sceneBeamEnd = nil;
local beamEnd = nil;
local beamOrigin = nil;
local beamAura = nil;

local target = nil;
function onUse(a, t)
	kaiju = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), t:getWorldPosition());
	kaiju:setWorldFacing(facingAngle);
--	playAnimation(kaiju, "ability_eyeblast");
	local v = a:getView();
	v:setAnimation("ability_eyeblast", false);
	v:addAnimation("walk", true);
	registerAnimationCallback(this, kaiju, "start");
end

function onAnimationEvent(a)
	target = kaiju:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	targetPos =  target:getWorldPosition();
	beamOrigin = kaiju:getWorldPosition();
	local view = kaiju:getView();
	view:pauseAnimation(beamDuration);
	
	beamAura = createAura(this, kaiju, 'ultra_laserheavy');
	beamAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	beamAura:setTickParameters(tickTime, beamDuration);
	beamAura:setTarget(kaiju); -- required so aura doesn't autorelease
	playSound("sfx_weap_laser_muzzle");
end

function onTick(aura)	
	if not aura then
		return
	end
	local targetEnt = getAbilityTarget(kaiju, abilityData.name);
	local newTargetPos = nil
	local kaijuFacing = kaiju:getWorldFacing()
	local worldPos = kaiju:getWorldPosition()
	
	if not targetEnt or not canTarget(targetEnt) then
		targetEnt = getTargetInEntityRadius(kaiju, weaponRange, EntityFlags(EntityType.Avatar, EntityType.Zone, EntityType.Minion), TargetFlags(TargetType.Land, TargetType.Sea), weaponFiringArc)
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
		applyDamageWithWeapon(kaiju, targetEnt, "weapon_ultrasan_laser");
	end
	view:doBeamEffectFromNode('breath_node', sceneBeamEnd, 'effects/gigablast_flare.plist', sceneBeamFacing );
	view:doBeamEffectFromNode('breath_node', sceneBeamEnd, 'effects/gigablast_core.plist', sceneBeamFacing );
	view:doEffectFromNode('breath_node', 'effects/gigablast_muzzle.plist', 0);
	
	createEffect("effects/explosion_BoomLayer.plist",		sceneBeamEnd);
	createEffect("effects/explosion_SmokeLayer.plist",		sceneBeamEnd);
	createEffect("effects/explosion_SparkLayer.plist",		sceneBeamEnd);
	createEffect("effects/explosion_SparkFireLayer.plist",	sceneBeamEnd);
end