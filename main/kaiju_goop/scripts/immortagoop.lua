healPerTick = 3;

function onSet(a)
	a:addPassive("goop_regen", healPerTick);
	a:addPassive("minion_health_regen", healPerTick);
end