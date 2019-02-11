local healpertarget = 1

function onSet(a)
	a:addPassive("heal_on_hit", healpertarget)
end

