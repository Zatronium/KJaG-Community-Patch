require 'scripts/avatars/common'
-- Global values.
local kaiju = 0;
local weapon = "Bolter1";

local weapon_node = "breath_node"

local target = nil;
local targetPos = nil;

local disableDuration = 5;
local aoe = 100;
function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
		kaiju:setWorldFacing(facingAngle);	
		playAnimation(kaiju, "ability_breath");
		registerAnimationCallback(this, kaiju, "start");
	end
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local proj;
	target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) and not (getEntityType(target) == EntityType.Zone) then
		proj = avatarFireAtTarget(kaiju, weapon, weapon_node, target, 90 - view:getFacingAngle());
	else
		proj = avatarFireAtPoint(kaiju, weapon, weapon_node, targetPos, 90 - view:getFacingAngle());
	end
	proj:setCallback(this, 'onHit');
	playSound("AtomoBolt");
	startCooldown(kaiju, abilityData.name);	
end

-- Projectile hits a target.
function onHit(proj)
	kaiju = getPlayerAvatar();
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
	local pos = proj:getWorldPosition();
	local cloud = spawnEntity(EntityType.Minion, "unit_shrubby_patch", pos);

	local targets = getTargetsInRadius(pos, aoe, EntityFlags(EntityType.Vehicle, EntityType.Avatar));
		
	for t in targets:iterator() do
		if canTarget(t) and not isSameEntity(t, kaiju) then
			t:disabled(disableDuration);
			t:attachEffect("effects/electricShard_core.plist", disableDuration, true);
			t:attachEffect("effects/atomoBolt_wave.plist", disableDuration, true);
			applyDamageWithWeapon(kaiju, t, weapon);
		end
	end
end


