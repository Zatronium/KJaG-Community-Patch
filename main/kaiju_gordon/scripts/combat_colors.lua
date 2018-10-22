local damageBonus = 2;
enemyAcc = 0.9; 
function onSet(a)
	avatar = a;
	local def = avatar:getStat("acc_notrack");
	def = def * enemyAcc;
	avatar:setStat("acc_notrack", def);
	avatar:addStat("damage_flat_bonus", damageBonus);
end
	