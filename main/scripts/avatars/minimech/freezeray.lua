require 'scripts/common'

local avatar = nil;
local target = nil;

local weaponRange = 1000;

local debuffTime = 3;

function onUse(a, t)
	avatar = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), t:getWorldPosition());
	avatar:setWorldFacing(facingAngle);
	playAnimation(avatar, "ability_beam");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	target = avatar:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	local view = avatar:getView();
    
	local pos = getScenePosition(target:getWorldPosition());
	
	view:doBeamEffectFromNode('palm_node_01', pos, 'effects/freezeRay.plist', 0 );
	view:doEffectFromNode('palm_node_01', 'effects/gigablast_muzzle.plist', 0);
	
	view:doBeamEffectFromNode('palm_node_02', pos, 'effects/freezeRay.plist', 0 );
	view:doEffectFromNode('palm_node_02', 'effects/gigablast_muzzle.plist', 0);
	
	createEffect("effects/freezeImpact.plist",	pos);
	playSound("sfx_weap_freeze_ray_muzzle");
	applyDamageWithWeapon(avatar, target, "weapon_FreezeRay");
end
