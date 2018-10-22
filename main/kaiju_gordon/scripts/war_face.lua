require 'scripts/avatars/common'

local avatar = nil;
local aoeRange = 250;

local fearChance = 0.25; -- 0 - 1
local fearDuration = 5;

function onSet(a)
	avatar = a;
	avatar:addPassive("war_face_range", aoeRange);
	avatar:addPassive("war_face_chance", fearChance);
	avatar:addPassive("war_face_duration", fearDuration);
end