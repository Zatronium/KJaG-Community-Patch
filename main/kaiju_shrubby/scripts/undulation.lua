local enemyAcc = 0.95
local speedIncrease = -0.05

function onSet(a)
	if not a:hasStat("acc_notrack") then
		a:addStat("acc_notrack", 100)
	end
	local def = a:getStat("acc_notrack") * enemyAcc
	a:setStat("acc_notrack", def);
end

function bonusStats(s)
	local bonusSpeed = s:getStat("Speed") * speedIncrease
	s:modStat("Speed", bonusSpeed)
end