local stunDuration = 3;
local infantryDamage = 3;

function onSet(a)
	a:addPassive("goop_electro_stun", stunDuration);
	a:addPassive("goop_electro_infantry_damage", infantryDamage);
end