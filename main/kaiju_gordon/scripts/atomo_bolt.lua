require 'scripts/avatars/common'
-- Global values.
local avatar = 0;
local weapon = "Bolter1";

local weapon_node = "breath_node"

local target = nil;
local targetPos = nil;

local disableDuration = 5;
local aoe = 100;
function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) then
		local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
		avatar:setWorldFacing(facingAngle);	
		playAnimation(avatar, "ability_breath");
		registerAnimationCallback(this, avatar, "start");
	end
end

function onAnimationEvent(a)
	local view = avatar:getView();
	local proj;
	target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) and not (getEntityType(target) == EntityType.Zone) then
		proj = avatarFireAtTarget(avatar, weapon, weapon_node, target, 90 - view:getFacingAngle());
	else
		proj = avatarFireAtPoint(avatar, weapon, weapon_node, targetPos, 90 - view:getFacingAngle());
	end
	proj:setCallback(this, 'onHit');
	playSound("AtomoBolt");
	startCooldown(avatar, abilityData.name);	
end

-- Projectile hits a target.
function onHit(proj)
	avatar = getPlayerAvatar();
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
	local pos = proj:getWorldPosition();
	local cloud = spawnEntity(EntityType.Minion, "unit_shrubby_patch", pos);

	local targets = getTargetsInRadius(pos, aoe, EntityFlags(EntityType.Vehicle, EntityType.Avatar));
		
	for t in targets:iterator() do
		if canTarget(t) and not isSameEntity(t, avatar) then
			t:disabled(disableDuration);
			t:attachEffect("effects/electricShard_core.plist", disableDuration, true);
			t:attachEffect("effects/atomoBolt_wave.plist", disableDuration, true);
			applyDamageWithWeapon(avatar, t, weapon);
		end
	end
end


