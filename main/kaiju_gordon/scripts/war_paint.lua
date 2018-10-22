local damageBonusPercent = 1.05;
enemyAcc = 0.9; 
function onSet(a)
	avatar = a;
	local def = avatar:getStat("acc_notrack");
	def = def * enemyAcc;
	avatar:setStat("acc_notrack", def);
	if avatar:hasStat("damage_amplify") then
		avatar:setStat("damage_amplify", damageBonusPercent * avatar:getStat("damage_amplify"));
	else
		avatar:addStat("damage_amplify", damageBonusPercent);
	end
end
	