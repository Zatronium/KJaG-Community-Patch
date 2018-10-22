local extraMoneyPct = 0.25;
local extraPowerPct = 0.25;
local extraKnowPct = 0.25;
local extraOrganicPct = 0.25;
local extraPurplePct = 0.25;

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
end


