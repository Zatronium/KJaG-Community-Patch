require 'scripts/avatars/common'

local kaiju = nil;
local weapon = "Stomp1";
local aoeRange = 80;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_stomp");
	
	registerAnimationCallback(this, kaiju, "attack");
end 

function onAnimationEvent(a, event)
	kaiju = a;
	local view = a:getView();
	local worldPos = kaiju:getWorldPosition();

	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/stompBack.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/stompFront.plist",0, 0, 0, true, false);
		
	local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		local flying = false;
		if getEntityType(t) == EntityType.Vehicle then
			local veh = entityToVehicle(t);
			flying = veh:isAir();
		end
		if not flying then
			applyDamageWithWeapon(kaiju, t, weapon);
		end
	end
		
	playSound("Stomp");
	startCooldown(kaiju, abilityData.name);	
end

