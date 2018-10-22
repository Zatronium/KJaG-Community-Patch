local reducedPowerCost = 0.2

function onSet(a)
	a:setPassive("reduce_power_cost", reducedPowerCost);
end