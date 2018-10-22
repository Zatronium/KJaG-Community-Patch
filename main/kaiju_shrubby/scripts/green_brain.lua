local bonusDamage = 0.2;
function onSet(a)
	if a:hasStat("damage_amplify") == true then
		a:modStat("damage_amplify", bonusDamage);
	else
		a:addStat("damage_amplify", 1 + bonusDamage);
	end
end

