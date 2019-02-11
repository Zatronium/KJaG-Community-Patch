local speedDecrease = -0.05
local armorBonus = 3

function bonusStats(s)
	local bonusSpeed = s:getStat("Speed") * speedDecrease
	s:modStat("Speed", bonusSpeed)
	s:modStat("Armor", armorBonus)
end
