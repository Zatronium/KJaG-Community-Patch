require 'scripts/common'

local avatar = nil;
local targetPos = 0;
local weaponRange = 1000;
local beamDuration = 1.0;
local tickTime = 0.125;

local sceneBeamFacing = 0;
local sceneBeamEnd = nil;
local beamEnd = nil;
local beamOrigin = nil;
local beamAura = nil;

local target = nil;
function onUse(a, t)
	avatar = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), t:getWorldPosition());
	avatar:setWorldFacing(facingAngle);
--	playAnimation(avatar, "ability_eyeblast");
	local v = a:getView();
	v:setAnimation("ability_eyeblast", false);
	v:addAnimation("walk", true);
	registerAnimationCallback(this, avatar, "start");
end

function onAnimationEvent(a)
	target = avatar:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	targetPos =  target:getWorldPosition();
	beamOrigin = avatar:getWorldPosition();
	local view = avatar:getView();
	view:pauseAnimation(beamDuration);
	
	beamAura = createAura(this, avatar, 'ultra_laserheavy');
	beamAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	beamAura:setTickParameters(tickTime, beamDuration);
	beamAura:setTarget(avatar); -- required so aura doesn't autorelease
	playSound("sfx_weap_laser_muzzle");
end

function onTick(aura)	
	beamEnd = getBeamEndWithPoint(beamOrigin, weaponRange, targetPos);
	
	local view = avatar:getView();
	local sceneBeamOrigin = view:getAnimationNodePosition('breath_node');
	sceneBeamEnd = getScenePosition(beamEnd);
	sceneBeamFacing = getFacingAngle(sceneBeamOrigin, sceneBeamEnd);
	
	local currentTarget = getClosestTargetInBeam(beamOrigin, beamEnd, 35, EntityFlags(EntityType.Avatar, EntityType.Zone), avatar);
	if currentTarget then	
		local pos = getScenePosition(currentTarget:getWorldPosition());
		
		view:doBeamEffectFromNode('breath_node', pos, 'effects/gigablast_flare.plist', sceneBeamFacing );
		view:doBeamEffectFromNode('breath_node', pos, 'effects/gigablast_core.plist', sceneBeamFacing );
		view:doEffectFromNode('breath_node', 'effects/gigablast_muzzle.plist', 0);
		
		createEffect("effects/explosion_BoomLayer.plist",		pos);
		createEffect("effects/explosion_SmokeLayer.plist",		pos);
		createEffect("effects/explosion_SparkLayer.plist",		pos);
		createEffect("effects/explosion_SparkFireLayer.plist",	pos);

		applyDamageWithWeapon(avatar, currentTarget, "weapon_ultrasan_laser");
	else 
		view:doBeamEffectFromNode('breath_node', sceneBeamEnd, 'effects/gigablast_flare.plist', sceneBeamFacing );
		view:doBeamEffectFromNode('breath_node', sceneBeamEnd, 'effects/gigablast_core.plist', sceneBeamFacing );
		view:doEffectFromNode('breath_node', 'effects/gigablast_muzzle.plist', 0);
		
		createEffect("effects/explosion_BoomLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SmokeLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkFireLayer.plist",	sceneBeamEnd);
	end
end