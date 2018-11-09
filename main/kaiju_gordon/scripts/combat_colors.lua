local damageBonus = 2;
enemyAcc = 0.9; 
function onSet(a)
	kaiju = a;
	local def = kaiju:getStat("acc_notrack");
	def = def * enemyAcc;
	kaiju:setStat("acc_notrack", def);
	kaiju:addStat("damage_flat_bonus", damageBonus);
end
	