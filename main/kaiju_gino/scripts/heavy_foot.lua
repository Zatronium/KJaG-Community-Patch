require 'scripts/avatars/common'

local avatar = nil;
local damageincrease = 10;

function onSet(a)
	local damage = a:hasPassive("stomp_damage");
	damage = damage + damageincrease;
	a:setPassive("stomp_damage", damage);
end