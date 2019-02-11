local cooldownPercent = 0.1
local speedIncrease = 0.1
local bonusMove = 10

function onSet(a)
	if a:hasStat("CoolDownReductionPercent") then
		a:modStat("CoolDownReductionPercent", cooldownPercent)
	else
		a:addStat("CoolDownReductionPercent", cooldownPercent)
	end
end

function bonusStats(s)
	local bonusSpeed = s:getStat("Speed") * speedIncrease
	s:modStat("Speed", bonusSpeed)
	s:modStat("MapSpeed", bonusMove)
end