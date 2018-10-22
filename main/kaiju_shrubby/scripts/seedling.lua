require 'scripts/avatars/common'
local avatar = nil;

local avatar = 0;
local targetPos = 0;
local seedSpawnRange = 400;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTarget', seedSpawnRange);
end

-- Target selection is complete.
function onTarget(position)
	targetPos = position;
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);	
	playAnimation(avatar, "ability_roar");
	registerAnimationCallback(this, avatar, "start");
end

function onAnimationEvent(a)
	local proj = avatarFireAtPoint(avatar, "weapon_spawnseedling", "breath_node", targetPos, 0);
	proj:setCollisionEnabled(false);
	proj:setCallback(this, 'onHit');
	playSound("shrubby_ability_Seedling");
	startCooldown(avatar, abilityData.name);
end

function onHit(proj)
	targetPos = getNearestRoad(proj:getWorldPosition());
	local ent = spawnEntity(EntityType.Minion, "unit_shrubby_seedling", targetPos);
	setRole(ent, "Player");
	local scenePos = ent:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
end
