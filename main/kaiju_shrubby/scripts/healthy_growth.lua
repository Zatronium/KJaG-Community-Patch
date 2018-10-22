local bonusBaseRegen = 0.2;

function onSet(a)
	a:addPassive("base_heal_bonus", bonusBaseRegen);
end