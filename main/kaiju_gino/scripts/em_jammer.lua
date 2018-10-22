--A jamming field that can block missiles targeting this kaiju
-- Effect:  10% chance that any missile targeting Gino goes haywire instead of targeting the Kaiju.
--passive
local missChance = 0.35
function onSet(a)
	a:addStat("MissileJamming", missChance);
end
