bonusSpeedPct = 0.2;

function bonusStats(s)
	local bonusSpeed = s:getStat("Speed") * bonusSpeedPct;
	s:modStat("Speed", bonusSpeed);
end

function onSet(a)
	a:addPassive("gordon_speed_pct", bonusHealthPct);
end