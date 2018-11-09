healPerTick = 3;

function onSet(a)
	a:addPassive("goop_regen", healPerTick);
end