local meleeBonus = 0.25;

function onSet(a)
	a:modStat("melee_damage_amplify", meleeBonus);
	a:addPassive("gino_melee", meleeBonus);
end