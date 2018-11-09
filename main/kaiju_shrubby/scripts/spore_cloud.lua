require 'scripts/avatars/common'

local kaiju = nil;
local targetPos = nil;
local weapon = "weapon_shrubby_poisonCloud1"

local poisoncheck = 1;
local poisonduration = 0;
local cloudaoe = 60;

local dotDamge = 5;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end 
	
function onTargets(position)
	targetPos = position;
	
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_breath");
	registerAnimationCallback(this, kaiju, "start");
end

function onAnimationEvent(a)
	startCooldown(kaiju, abilityData.name);	
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
	if not aura then return end
	local targets = getTargetsInRadius(aura:getTarget():getWorldPosition(), cloudaoe, EntityFlags(EntityType.Vehicle, EntityType.Avatar));
	for t in targets:iterator() do
		if canTarget(t) and isOrganic(t) and not isSameEntity(kaiju, t) then
			applyDamageWithWeapon(kaiju, t, weapon);
		end
	end
end