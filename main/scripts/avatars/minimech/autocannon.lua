require 'scripts/common'

-- Global values.
local avatar = nil;

function onUse(a, t)
	avatar = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), t:getWorldPosition());
	avatar:setWorldFacing(facingAngle);
	playAnimation(avatar, "ability_beam");
	registerAnimationCallback(this, avatar, "start");
end

function onAnimationEvent(a)
	local target = avatar:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	local proj = avatarFireAtTarget(avatar, "weapon_Cannon", "palm_node_01", target, 0);
	proj = avatarFireAtTarget(avatar, "weapon_Cannon", "palm_node_02", target, 0);
end

