require 'scripts/common'

local avatar = nil;
local target = nil;

local shotdelay = 0.1;
local shotsfired = 3;

function onUse(a, t)
	avatar = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), t:getWorldPosition());
	avatar:setWorldFacing(facingAngle);
	playAnimation(avatar, "ability_throw");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	target = avatar:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	local view = avatar:getView();
	
	local offset = 350 * getDistance(avatar, target) / 1500;
	local locPos = target:getWorldPosition();
	locPos["x"] = locPos["x"] + math.random(-offset, offset);
	locPos["y"] = locPos["y"] + math.random(-offset, offset);
	--local proj = avatarFireAtTarget(avatar, "weapon_Boulder", "palm_node_01", target, 0);
	local proj = avatarFireAtPoint(avatar, "weapon_Boulder", "palm_node_01", locPos, 0);
	proj:setCollisionEnabled(false);
end