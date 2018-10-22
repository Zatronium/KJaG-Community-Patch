local extraMoneyPct = 0.2;
local extraPowerPct = 0.2;
local extraKnowPct = 0.2;
local extraOrganicPct = 0.2;
local extraPurplePct = 0.2;

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
	
	s:modStat("ExtraAbilitySlot", 1);
end


