require 'scripts/common'

local avatar = nil;
local target = nil;

function onUse(a, t)
	avatar = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), t:getWorldPosition());
	avatar:setWorldFacing(facingAngle);
	playAnimation(avatar, "ability_megapunch");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	target = avatar:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	applyDamageWithWeapon(avatar, target, "weapon_rock_punch");
end