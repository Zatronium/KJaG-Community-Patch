require 'scripts/avatars/common'
-- Global values.
local kaiju = 0;
local weapon = "Throw2";
local weapon_node = "palm_node_01"

local target = nil;
local targetPos = nil;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	target = getAbilityTarget(kaiju, abilityData.name);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_throw");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local proj;
	target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		proj = avatarFireAtTarget(kaiju, weapon, weapon_node, target, 90 - view:getFacingAngle());
	else
		proj = avatarFireAtPoint(kaiju, weapon, weapon_node, targetPos, 90 - view:getFacingAngle());
	end

	proj:setCallback(this, 'onHit');
	playSound("AtomicFastball");
	startCooldown(kaiju, abilityData.name);	
end

-- Projectile hits a target.
function onHit(proj)
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
	local t = proj:getTarget();
	if canTarget(t) then
		local worldPos = proj:getWorldPosition();
		local otherPos = t:getWorldPosition();

		local dir = getDirectionFromPoints(worldPos, otherPos);
		t:displaceDirection(dir, kbPower, kbDistance);
--		applyDamageWithWeapon(kaiju, t, weapon);
	end
end