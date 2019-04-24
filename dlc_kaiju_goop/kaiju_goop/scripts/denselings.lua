local minionHealthBonus = 10;

function onSet(a)
	a:addPassive("minion_health_bonus_flat", minionHealthBonus);
end