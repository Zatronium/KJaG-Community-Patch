require 'scripts/avatars/common'

local kaiju = nil;
local aoeRange = 500;

local fearChance = 50;
local fearDuration = 5;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_cast");
	local view = a:getView();
	local worldPos = kaiju:getWorldPosition();
	view:attachEffectToNode("root", "effects/terrorize_back.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/terrorize_front.plist",0, 0, 0, true, false);

		
	local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle));
	for t in targets:iterator() do

		local veh = entityToVehicle(t);
		if not veh:isAir() and math.random(0, 100) < fearChance then
			local aura = nil;
			if not veh:hasAura("FEAR") then
				aura = createAura(nil, veh, "FEAR");
				aura:setTarget(veh);
			else
				aura = veh:getAura("FEAR");
			end
			aura:setDuration(fearDuration);
		end
	end
		
--	playSound("shrubby_ability_VineWave");
	startCooldown(kaiju, abilityData.name);	
end