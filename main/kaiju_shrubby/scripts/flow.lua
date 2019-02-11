local bonusMove = -10
local bonusSensory = -15

function bonusStats(s)
	s:modStat("MapSpeed", bonusMove)
	s:modStat("SensorsSignature", bonusSensory)
end
