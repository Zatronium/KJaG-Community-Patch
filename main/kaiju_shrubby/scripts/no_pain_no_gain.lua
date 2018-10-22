local extraMoneyPct = 0.6;
local extraPowerPct = 0.6;
local extraKnowPct = 0.6;
local extraOrganicPct = 0.6;
local extraPurplePct = 0.6;

local extraMapSpeed = -5;

function bonusStats(s)
	local value = s:getStat("MaxMoney");
	s:modStat("MaxMoney", value * extraMoneyPct);
	value = s:getStat("MaxPower");
	s:modStat("MaxPower", value * extraPowerPct);
	value = s:getStat("MaxKnow");
	s:modStat("MaxKnow", value * extraKnowPct);
	value = s:getStat("MaxOrganic");
	s:modStat("MaxOrganic", value * extraOrganicPct);
	value = s:getStat("MaxPurple");
	s:modStat("MaxPurple", value * extraPurplePct);
	
	s:modStat("MapSpeed", extraMapSpeed);
end


