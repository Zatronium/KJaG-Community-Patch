local bonusMove = 10
local speedIncrease = 0.15

function bonusStats(s)
	local bonusSpeed = s:getStat("Speed") * speedIncrease
	s:modStat("Speed", bonusSpeed)
	s:modStat("MapSpeed", bonusMove)
end
