bonusHealthPct = 0.2;

function bonusStats(s)
	local maxhp = s:getStat("MaxHealth");
	s:modStat("MaxHealth", maxhp * bonusHealthPct);
end

function onSet(a)
	a:addPassive("shrubby_health_pct", bonusHealthPct);
end