require 'scripts/avatars/common'

local CDRPercent = 0.05;
local increaseAoe = 0.3;


local kaiju = nil;


function onSet(a)
	kaiju = a;
	
	kaiju:modStat("CoolDownReductionPercent", CDRPercent);
	kaiju:addPassive("increased_range", increaseAoe);

end
