enemyAcc = 0.85; 
local bonusSensory = -5;

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
	s:modStat("SensorsSignature", bonusSensory);
end