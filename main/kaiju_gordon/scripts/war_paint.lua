local damageBonusPercent = 1.05;
enemyAcc = 0.9; 
function onSet(a)
	kaiju = a;
	local def = kaiju:getStat("acc_notrack");
	def = def * enemyAcc;
	kaiju:setStat("acc_notrack", def);
	if kaiju:hasStat("damage_amplify") then
		kaiju:setStat("damage_amplify", damageBonusPercent * kaiju:getStat("damage_amplify"));
	else
		kaiju:addStat("damage_amplify", damageBonusPercent);
	end
end
	