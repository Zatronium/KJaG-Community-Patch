require 'scripts/avatars/common'

local Angle = 20;
local range = 200;
local minDamage = 18;
local maxDamage = 23;
local disableTime = 5;
local kaiju = nil
function onUse(a)
	kaiju = a;
	playAnimation(a, "ability_breath");
	registerAnimationCallback(this, a, "start");
end
-- damageEffect can be nil

function onAnimationEvent(a)
	local view = a:getView();
	local worldPosition = a:getWorldPosition();
	local worldFacing = a:getWorldFacing();
	local sceneFacing = a:getSceneFacing();

	local targets = getTargetsInCone(worldPosition, range, Angle, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar));
	view:doEffectFromNode('breath_node', 'effects/icefire.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/icefire_snowflakes.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/icefire_snowflakeBurst.plist', sceneFacing);
	playSound("gino_breath");
	startCooldown(a, abilityData.name);
	for t in targets:iterator() do
		if getEntityType(t) == EntityType.Vehicle then
			local veh = entityToVehicle(t);
			veh:disabled(disableTime);
		end
		if getEntityType(t) ~= EntityType.Avatar then
			t:attachEffect("effects/onFreeze.plist", disableTime, true);
		end
	end
	dotSetTargets(a, targets, 1, 4, "onTick");
end

function onTick(aura)
	if not aura then
		return
	end
	local target = aura:getTarget();
	local self = aura:getOwner()
	if not target or not self then
		if not self then
			aura = nil
		else
			self:detachAura(aura);
		end
	else
		applyDamage(self, target, math.random (minDamage,maxDamage));
	end
end
