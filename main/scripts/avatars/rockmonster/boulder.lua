require 'scripts/common'

-- Global values.
local kaiju = nil;
local target = nil;

local shotdelay = 0.1;
local shotsfired = 3;

function onUse(a, t)
	kaiju = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), t:getWorldPosition());
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_throw");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	target = kaiju:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	local view = kaiju:getView();
	
	local offset = 350 * getDistance(kaiju, target) / 1500;
	local locPos = target:getWorldPosition();
	locPos["x"] = locPos["x"] + math.random(-offset, offset);
	locPos["y"] = locPos["y"] + math.random(-offset, offset);
	--local proj = avatarFireAtTarget(kaiju, "weapon_Boulder", "palm_node_01", target, 0);
	local proj = avatarFireAtPoint(kaiju, "weapon_Boulder", "palm_node_01", locPos, 0);
	proj:setCollisionEnabled(false);
end