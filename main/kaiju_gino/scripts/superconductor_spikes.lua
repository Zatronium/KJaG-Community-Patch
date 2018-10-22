local bonuspowermultiplier = 0.2

function onSet(a)
	local pgb = a:hasPassive("power_gain_bonus");
	pgb = pgb + bonuspowermultiplier;
	a:setPassive("power_gain_bonus", pgb);
end