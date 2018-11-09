require 'scripts/common'

-- Global values.
local kaiju = nil;

function onUse(a, t)
	kaiju = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), t:getWorldPosition());
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_beam");
	registerAnimationCallback(this, kaiju, "start");
end

function onAnimationEvent(a)
	local target = kaiju:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	local proj = avatarFireAtTarget(kaiju, "weapon_Cannon", "palm_node_01", target, 0);
	proj = avatarFireAtTarget(kaiju, "weapon_Cannon", "palm_node_02", target, 0);
end

