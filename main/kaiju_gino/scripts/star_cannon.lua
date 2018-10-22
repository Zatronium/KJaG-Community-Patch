require 'scripts/common'

-- Global values.
local avatar = 0;
local targetPos = 0;
local weaponRange = 1500;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', weaponRange);
end

function onTargets(position)
	targetPos = position;
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);	
	playAnimation(avatar, "ability_breath");
	registerAnimationCallback(this, avatar, "start");
end

function onAnimationEvent(a)
	local proj = avatarFireAtPoint(avatar, "weapon_mortar1", "breath_node", targetPos, 90);
	proj:setCallback(this, 'onHit');
	proj:fromAvatar(true);
	playSound("starcannon");
	startCooldown(a, abilityData.name);	
end

function onHit(proj)
	local worldPos = proj:getWorldPosition();
	local scenePos = proj:getView():getPosition();
	playSound("explosion");
	local weapon = proj:getWeapon();
	createImpactEffect(proj:getWeapon(), scenePos);
end