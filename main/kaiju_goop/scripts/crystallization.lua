local armorBonus = 3;
local speedBonus = -0.15;

function bonusStats(s)
	s:modStat("Armor", armorBonus);
	local bonusSpeed = s:getStat("Speed") * speedBonus;
	s:modStat("Speed", bonusSpeed);
end