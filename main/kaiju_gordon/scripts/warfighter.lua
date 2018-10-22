enemyAcc = 0.9; 
local avatar = nil;
function onSet(a)
	avatar = a;
	local def = avatar:getStat("acc_notrack");
	def = def * enemyAcc;
	avatar:setStat("acc_notrack", def);
end
