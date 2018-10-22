require 'scripts/avatars/common'

local avatar = nil;
local weapon = "Stomp1";
local aoeRange = 80;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_stomp");
	
	registerAnimationCallback(this, avatar, "attack");
end 

function onAnimationEvent(a, event)
	avatar = a;
	local view = a:getView();
	local worldPos = avatar:getWorldPosition();

	local view = avatar:getView();
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
			applyDamageWithWeapon(avatar, t, weapon);
		end
	end
		
	playSound("Stomp");
	startCooldown(avatar, abilityData.name);	
end

