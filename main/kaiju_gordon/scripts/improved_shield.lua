local shieldBonus = 0.25;
function onSet(a)
	avatar = a;
	avatar:addPassive("shield_bonus", shieldBonus);
end
	