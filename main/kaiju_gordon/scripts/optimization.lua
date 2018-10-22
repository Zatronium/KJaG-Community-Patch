local bonusDamagePercent = 0.25;
function onSet(a)
	a:modStat("damage_amplify", bonusDamagePercent);
end
	