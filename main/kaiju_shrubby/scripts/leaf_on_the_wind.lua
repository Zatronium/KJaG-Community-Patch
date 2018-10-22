local enemyAcc = 0.90;
local speedIncrease = 0.20;

function onSet(a)
	avatar = a;
	if not avatar:hasStat("acc_notrack") then
		avatar:addStat("acc_notrack", 100);
	end
	local def = avatar:getStat("acc_notrack");
	def = def * enemyAcc;
	avatar:setStat("acc_notrack", def);
end

function bonusStats(s)
	local bonusSpeed = s:getStat("Speed") * speedIncrease;
	s:modStat("Speed", bonusSpeed);
end