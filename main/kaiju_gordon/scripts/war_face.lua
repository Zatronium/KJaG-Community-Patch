require 'scripts/avatars/common'

local kaiju = nil;
local aoeRange = 250;

fearChance = 0.25; -- 0 - 1
local fearDuration = 5;

function onSet(a)
	kaiju = a;
	kaiju:addPassive("war_face_range", aoeRange);
	kaiju:addPassive("war_face_chance", fearChance);
	kaiju:addPassive("war_face_duration", fearDuration);
end