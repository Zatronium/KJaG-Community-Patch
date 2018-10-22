local reducedCost = 0.25

function onSet(a)
	a:addPassive("reduce_cost", reducedCost);
end