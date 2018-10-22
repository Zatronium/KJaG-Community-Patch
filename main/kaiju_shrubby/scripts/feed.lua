local healpertarget = 1;
function onSet(a)
	a:setPassive("heal_on_hit", healpertarget);
end

