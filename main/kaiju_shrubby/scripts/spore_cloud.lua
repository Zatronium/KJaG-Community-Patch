require 'scripts/avatars/common'

local avatar = nil;
local targetPos = nil;
local weapon = "weapon_shrubby_poisonCloud1"

local poisoncheck = 1;
local poisonduration = 0;
local cloudaoe = 60;

local dotDamge = 5;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end 
	
function onTargets(position)
	targetPos = position;
	
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);	
	playAnimation(avatar, "ability_breath");
	registerAnimationCallback(this, avatar, "start");
end

function onAnimationEvent(a)
	startCooldown(avatar, abilityData.name);	
	playSound("shrubby_ability_SporeCloud");
	local cloud = spawnEntity(EntityType.Minion, "unit_shrubby_cloud", targetPos);
	setRole(cloud, "Player");
	cloud:attachEffect("effects/sporesBurst.plist", -1, true);
	cloud:attachEffect("effects/sporecloud.plist", -1, true);
	cloud:attachEffect("effects/position.plist", -1, true);
	local aura = createAura(this, cloud, 0);
	aura:setTickParameters(poisoncheck, poisonduration);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(cloud);
end

function onTick(aura)
	local targets = getTargetsInRadius(aura:getTarget():getWorldPosition(), cloudaoe, EntityFlags(EntityType.Vehicle, EntityType.Avatar));
	avatar = getPlayerAvatar();
	for t in targets:iterator() do
		if canTarget(t) and isOrganic(t) and not isSameEntity(avatar, t) then
			applyDamageWithWeapon(avatar, t, weapon);
		end
	end
end