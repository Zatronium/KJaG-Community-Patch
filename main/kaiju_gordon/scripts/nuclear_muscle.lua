local leapBonus = 0.2;
local meleeBonusDamageVsZones = 1.0;
--See Leaps
function onSet(a)
	a:addPassive("gordon_leap_distance", leapBonus);
	a:modStat("melee_damage_zone_amplify", bonusDamagePercent);
end
	