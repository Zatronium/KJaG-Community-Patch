

require 'scripts/common'

-- Global values.
local kaiju = nil;
local target = nil;

local weaponRange = 1000;

local debuffTime = 3;

function onUse(a, t)
	kaiju = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), t:getWorldPosition());
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_beam");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	target = kaiju:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	local view = kaiju:getView();
    
	local pos = getScenePosition(target:getWorldPosition());
	
	view:doBeamEffectFromNode('palm_node_01', pos, 'effects/freezeRay.plist', 0 );
	view:doEffectFromNode('palm_node_01', 'effects/gigablast_muzzle.plist', 0);
	
	view:doBeamEffectFromNode('palm_node_02', pos, 'effects/freezeRay.plist', 0 );
	view:doEffectFromNode('palm_node_02', 'effects/gigablast_muzzle.plist', 0);
	
	createEffect("effects/freezeImpact.plist",	pos);
	playSound("sfx_weap_freeze_ray_muzzle");
	applyDamageWithWeapon(kaiju, target, "weapon_FreezeRay");
end
