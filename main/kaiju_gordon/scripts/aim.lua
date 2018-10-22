require 'scripts/avatars/common'

local CDRPercent = 0.05;
local increaseAoe = 0.3;


local avatar = nil;


function onSet(a)
	avatar = a;
	
	avatar:modStat("CoolDownReductionPercent", CDRPercent);
	avatar:addPassive("increased_range", increaseAoe);

end
