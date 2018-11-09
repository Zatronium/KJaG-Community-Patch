local shieldBonus = 0.25;
function onSet(a)
	kaiju = a;
	kaiju:addPassive("shield_bonus", shieldBonus);
end
	