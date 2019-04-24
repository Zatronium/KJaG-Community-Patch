local damageBonus = 0.25;

function onSet(a)
	a:modStat("damage_amplify", damageBonus);
	a:addPassive("gino_damage", damageBonus);
end