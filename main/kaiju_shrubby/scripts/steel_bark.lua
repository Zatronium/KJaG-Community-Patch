local speedDecrease = -0.05;
local armorBonus = 2;
local maxHealthBonus = 30;

function bonusStats(s)
	s:modStat("MaxHealth", maxHealthBonus);
	local bonusSpeed = s:getStat("Speed") * speedDecrease;
	s:modStat("Speed", bonusSpeed);
	s:modStat("Armor", armorBonus);
end
