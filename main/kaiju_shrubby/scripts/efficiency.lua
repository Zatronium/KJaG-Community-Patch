local reducedCost = 0.1

function onSet(a)
	a:addPassive("reduce_cost", reducedCost);
end