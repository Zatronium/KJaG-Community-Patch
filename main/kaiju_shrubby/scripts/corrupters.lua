require 'scripts/avatars/common'
local kaiju = nil;
local buildingMult = 1;
local rangeMult = 1;

function onSet(a)
	a:addPassive("seed_damage_zone_bonus", buildingMult);
	a:addPassive("seed_range_bonus", rangeMult);
end

