local threshold = 0.9;
local bonusDamage = 0.3;
function onSet(a)
	a:setPassive("green_feast", threshold);
	a:setPassive("green_feast_bonus_damage", bonusDamage);
end

