local enemyAcc = 0.9
local speedIncrease = 0.2

function onSet(a)
	kaiju = a
	if not kaiju:hasStat("acc_notrack") then
		kaiju:addStat("acc_notrack", 100)
	end
	local def = kaiju:getStat("acc_notrack") * enemyAcc
	kaiju:setStat("acc_notrack", def)
end

function bonusStats(s)
	local bonusSpeed = s:getStat("Speed") * speedIncrease
	s:modStat("Speed", bonusSpeed)
end