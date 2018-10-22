

require 'scripts/common'

-- Global values.
local avatar = nil;

function onUse(a, t)
	avatar = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), t:getWorldPosition());
	avatar:setWorldFacing(facingAngle);
	playAnimation(avatar, "ability_laserlight");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	local target = avatar:getWeakTarget();
	if not canTarget(target) then
		return;
	end

	local view = avatar:getView();
    
	local pos = getScenePosition(target:getWorldPosition());
	
	view:doBeamEffectFromNode('breath_node', pos, 'effects/laserLight.plist', 0 );
	view:doEffectFromNode('breath_node', 'effects/laserLight_muzzle.plist', 0);
	
	createEffect("effects/explosion_BoomLayer.plist",		pos);
	createEffect("effects/explosion_SmokeLayer.plist",		pos);
	createEffect("effects/explosion_SparkLayer.plist",		pos);
	createEffect("effects/explosion_SparkFireLayer.plist",	pos);
	playSound("sfx_weap_laser_small_muzzle");
	applyDamageWithWeapon(avatar, target, "weapon_LaserLight");
end