require 'scripts/common'

-- Global values.
local kaiju = nil;
local target = nil;

function onUse(a, t)
	kaiju = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), t:getWorldPosition());
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_megapunch");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	target = kaiju:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	applyDamageWithWeapon(kaiju, target, "weapon_rock_punch");
end