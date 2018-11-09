 -- damage 10 - 18
 -- dot 10
 -- aoe 150
 -- cold
require 'scripts/avatars/common'
local kaiju = nil;

local minDamage = 10;
local maxDamage = 18;
 
local aoeRange = 150;
 
local isDone = false;
local immobileDuration = 3;
 
function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "stomp");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/bloop.plist", 1.5, 0, 150, true, false);
	kaiju = getPlayerAvatar();
	local worldPos = kaiju:getWorldPosition();
	local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone));
	for t in targets:iterator() do
		if getEntityType(t) == EntityType.Vehicle then	
			local veh = entityToVehicle(t);
			if not veh:isAir() then
				t:attachEffect("effects/rootCluster.plist", 3, true);
				t:attachEffect("effects/roots_shockwave.plist", .1, true);
				t:attachEffect("effects/rootSpike.plist", .3, true);
				t:attachEffect("effects/creeper_rocks.plist", .1, true);
				
				t:setImmobile(true);
				local aura = createAura(this, t, 0);
				aura:setTickParameters(immobileDuration, 0);
				aura:setScriptCallback(AuraEvent.OnTick, "immobilize");
				aura:setTarget(t);
				
				applyDamage(kaiju, t, math.random(minDamage, maxDamage));	
			end
		elseif canTarget(t) then
			t:attachEffect("effects/rootCluster.plist", 3, true);
			t:attachEffect("effects/roots_shockwave.plist", .1, true);
			t:attachEffect("effects/rootSpike.plist", .3, true);
			t:attachEffect("effects/creeper_rocks.plist", .1, true);
			applyDamage(kaiju, t, math.random(minDamage, maxDamage));	
		end
	end
	playSound("shrubby_ability_Roots");
	startCooldown(kaiju, abilityData.name);
	isDone = true;
end

function immobilize(aura)
	if not aura then return end
	if isDone then
		local self = aura:getOwner()
		self:setImmobile(false);
		if not self then
			aura = nil return
		else
			self:detachAura(aura)
		end
	end
end