require 'scripts/common'

local damagePercent = 0.05; -- 5%
local dodgeChance = 15; -- 15%

function onSet(a)
	a:modStat("damage_amplify", -damagePercent);
	a:modStat("block_all", -dodgeChance);
end