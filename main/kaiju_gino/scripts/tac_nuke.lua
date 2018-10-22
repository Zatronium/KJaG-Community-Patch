require 'scripts/common'

-- Global values.
local avatar = 0
local targetPos = 0
local weaponRange = 1200

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', weaponRange);
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);	
	playAnimation(avatar, "ability_launch");
	registerAnimationCallback(this, avatar, "attack");
end

-- Animation event 'breath_start'.
function onAnimationEvent(a)
	local target = getAbilityTarget(avatar, abilityData.name);
	if target and canTarget(target) then
		targetPos = target:getWorldPosition();
	end
	local proj = avatarFireAtPoint(avatar, "weapon_Nuke1", "gun_node_03", targetPos, 0);
	proj:setCallback(this, 'onHit');
	proj:fromAvatar(true);
	proj:setCollisionEnabled(false);
	playSound("tacnuke");
	startCooldown(avatar, abilityData.name);
	
end

-- Projectile hits a target.
function onHit(proj)
	local worldPos = proj:getWorldPosition();
	local scenePos = proj:getView():getPosition();

	local weapon = proj:getWeapon();
	playSound("explosion");
	createImpactEffect(proj:getWeapon(), scenePos);
end