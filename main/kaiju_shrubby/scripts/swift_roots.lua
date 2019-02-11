local bonusSpeed = 0.0
local bonusSpeedPct = 0.15
local bonusBaseRegen = 0.15

function onSet(a)
	a:addPassive("base_heal_bonus", bonusBaseRegen)
end

function bonusStats(s)
	s:addStat("RepairRateMod", 0.05)
	bonusSpeed = s:getStat("Speed") * bonusSpeedPct
	s:modStat("Speed", bonusSpeed)
end