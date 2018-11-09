bonusHealth = 100;

function bonusStats(s)
	s:modStat("MaxHealth", bonusHealth);
end

function onSet(a)
	a:addPassive("shrubby_health_val", bonusHealth);
end