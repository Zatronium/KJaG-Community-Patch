require 'scripts/common'

local range = 200;
local damage = 50;

function onUse(a)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/shrapnelStorm.plist", durationtime, 0, 0, flase, true);
	view:attachEffectToNode("root", "effects/shrapnelStorm_trigger.plist",0, 0, -60, true, false);
	view:attachEffectToNode("root", "effects/shrapnelStorm_trigger.plist",0, -40, -40, true, false);
	view:attachEffectToNode("root", "effects/shrapnelStorm_trigger.plist",0, 40, -40, true, false);
	view:attachEffectToNode("root", "effects/shrapnelStorm_trigger.plist",0, -80, -20, true, false);
	view:attachEffectToNode("root", "effects/shrapnelStorm_trigger.plist",0, 80,-20, true, false);
	view:attachEffectToNode("root", "effects/shrapnelStorm_flash.plist", durationtime, 0, 0, flase, true);

	startCooldown(a, abilityData.name);
	local armor = a:getBaseStat("Armor");
	local cur = a:getStat("Armor");
	local dec = a:hasPassive("shrapnel");
	if armor > dec and cur > 0 then
		dec = dec + 1;
		a:setPassive("shrapnel", dec);
		a:modStat("Armor", -1);
		
		local worldPos = a:getWorldPosition();
		local targets = getTargetsInRadius(worldPos, range, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
		for t in targets:iterator() do
			applyDamage(a, t, damage);
		end
		
		if armor <= dec then
			abilityEnabled(a, abilityData.name, false);
		end
	end
end
