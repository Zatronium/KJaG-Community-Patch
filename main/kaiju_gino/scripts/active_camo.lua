enemyAcc = 0.7; 
function onSet(a)
	kaiju = a;
	if not kaiju:hasStat("acc_notrack") then
		kaiju:addStat("acc_notrack", 100);
	end
	local def = kaiju:getStat("acc_notrack");
	kaiju:setStat("acc_notrack", def * enemyAcc);
end
	