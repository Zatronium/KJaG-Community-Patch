require 'scripts/avatars/common'
-- Global values.
local avatar = 0;
local weapon = "Throw1";
local weapon_node = "palm_node_01"

local target = nil;
local targetPos = nil;
local kbPower = 500;
local kbDistance = 200; -- max distance

local empower = 0;

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
	playSound("Toss");
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
	--playSound("shrubby_ability_FangStrike");
	startCooldown(avatar, abilityData.name);	
	empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
end

-- Projectile hits a target.
function onHit(proj)
	avatar = getPlayerAvatar();
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
	local t = proj:getTarget();
	if canTarget(t) then
		local worldPos = proj:getWorldPosition();
		local otherPos = t:getWorldPosition();

		local dir = getDirectionFromPoints(worldPos, otherPos);
		t:displaceDirection(dir, kbPower, kbDistance);
		
		abilityEnhance(empower);	
		applyDamageWithWeapon(avatar, t, weapon);
		abilityEnhance(0);
	end
end