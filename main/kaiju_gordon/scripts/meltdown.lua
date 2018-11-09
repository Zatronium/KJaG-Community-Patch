require 'scripts/avatars/common'

local kaiju = nil;

function onSet(a)
	kaiju = a;
	kaiju:setPassive("gord_meltdown", 1);
end