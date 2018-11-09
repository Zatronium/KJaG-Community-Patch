enemyAcc = 0.9; 
local kaiju = nil;
function onSet(a)
	kaiju = a;
	local def = kaiju:getStat("acc_notrack");
	def = def * enemyAcc;
	kaiju:setStat("acc_notrack", def);
end
