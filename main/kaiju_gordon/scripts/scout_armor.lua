local kaiju = nil;
enemyAcc = 0.95; 
local bonusSpeedPercent = 0.1;
function onSet(a)
	kaiju = a;
	local def = kaiju:getStat("acc_notrack");
	def = def * enemyAcc;
	kaiju:setStat("acc_notrack", def);
end

function bonusStats(s)
	local bonusSpeed = s:getStat("Speed") * bonusSpeedPercent;
	s:modStat("Speed", bonusSpeed);
end
