local bonusDamage = 1.0 -- At 0% health

function onSet(a)
	a:setPassive("green_soul", bonusDamage)
end

