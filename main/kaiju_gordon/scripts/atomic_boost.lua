local bonusDamagePercent = 0.1;

function onSet(a)
	a:modStat("damage_amplify", bonusDamagePercent);
end
	