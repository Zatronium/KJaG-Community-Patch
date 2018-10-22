require 'scripts/common'

local minDamage = 80;
local maxDamage = 100;

local range = 100;
function onUse(a)
	if a:MatterTransmission() then
	
		local view = a:getView();
		view:attachEffectToNode("root", "effects/pulseVertical_back.plist", 0, 0,0, false, true);
		view:attachEffectToNode("root", "effects/pulseVertical_front.plist", 0, 0,0, true, false);
		startCooldown(a, abilityData.name);
		local worldPos = a:getWorldPosition();
		local targets = getTargetsInRadius(worldPos, range, EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar));
		for t in targets:iterator() do
			applyDamage(a, t, math.random(minDamage, maxDamage));
		end
	end
	
end
