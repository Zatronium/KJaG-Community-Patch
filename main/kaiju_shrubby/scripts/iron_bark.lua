local speedDecrease = -0.02
local armorBonus = 1
function bonusStats(s)
	local bonusSpeed = s:getStat("Speed") * speedDecrease
	s:modStat("Speed", bonusSpeed)
	s:modStat("Armor", armorBonus)
end
