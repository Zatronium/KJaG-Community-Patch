

require 'scripts/common'

-- Global values.
local kaiju = nil;

function onUse(a, t)
	kaiju = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), t:getWorldPosition());
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_laserlight");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	local target = kaiju:getWeakTarget();
	if not canTarget(target) then
		return;
	end

	local view = kaiju:getView();
    
	local pos = getScenePosition(target:getWorldPosition());
	
	view:doBeamEffectFromNode('breath_node', pos, 'effects/laserLight.plist', 0 );
	view:doEffectFromNode('breath_node', 'effects/laserLight_muzzle.plist', 0);
	
	createEffect("effects/explosion_BoomLayer.plist",		pos);
	createEffect("effects/explosion_SmokeLayer.plist",		pos);
	createEffect("effects/explosion_SparkLayer.plist",		pos);
	createEffect("effects/explosion_SparkFireLayer.plist",	pos);
	playSound("sfx_weap_laser_small_muzzle");
	applyDamageWithWeapon(kaiju, target, "weapon_LaserLight");
end