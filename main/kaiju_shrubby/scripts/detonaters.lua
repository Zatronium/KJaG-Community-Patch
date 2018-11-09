require 'scripts/avatars/common'
local kaiju = nil;
local detonateRange = 50;
local detonateDamage = 50;
function onSet(a)
	a:setPassive("seed_detonate_range", detonateRange);
	a:setPassive("seed_detonate_damage", detonateDamage);
end