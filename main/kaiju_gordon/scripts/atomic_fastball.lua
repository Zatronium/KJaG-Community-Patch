require 'scripts/avatars/common'

local avatar = 0;
local weapon = "Throw2";
local weapon_node = "palm_node_01"

local target = nil;
local targetPos = nil;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	target = getAbilityTarget(avatar, abilityData.name);
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);	
	playAnimation(avatar, "ability_throw");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	local view = avatar:getView();
	local proj;
	target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) then
		proj = avatarFireAtTarget(avatar, weapon, weapon_node, target, 90 - view:getFacingAngle());
	else
		proj = avatarFireAtPoint(avatar, weapon, weapon_node, targetPos, 90 - view:getFacingAngle());
	end

	proj:setCallback(this, 'onHit');
	playSound("AtomicFastball");
	startCooldown(avatar, abilityData.name);	
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
--		applyDamageWithWeapon(avatar, t, weapon);
	end
end