local avatar = nil;
local enemyAcc = 0.95; 
local bonusSpeedPercent = 0.1;
function onSet(a)
	avatar = a;
	local def = avatar:getStat("acc_notrack");
	def = def * enemyAcc;
	avatar:setStat("acc_notrack", def);
end

function bonusStats(s)
	local bonusSpeed = s:getStat("Speed") * bonusSpeedPercent;
	s:modStat("Speed", bonusSpeed);
end
