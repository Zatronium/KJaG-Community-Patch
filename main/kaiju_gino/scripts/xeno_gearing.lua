local speedIncrease = 0.25;

function bonusStats(s)
	local bonusSpeed = s:getStat("Speed") * speedIncrease;
	s:modStat("Speed", bonusSpeed);
end
