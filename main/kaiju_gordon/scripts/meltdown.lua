require 'scripts/avatars/common'

local avatar = nil;

function onSet(a)
	avatar = a;
	avatar:setPassive("gord_meltdown", 1);
end