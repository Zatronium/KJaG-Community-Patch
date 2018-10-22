local meleeBonus = 0.2;
local leapThresholdBonus = 0.2;
--See Leaps
function onSet(a)
	a:modStat("melee_damage_amplify", meleeBonus);
	a:addPassive("zone_health_threshold", leapThresholdBonus);
end
	