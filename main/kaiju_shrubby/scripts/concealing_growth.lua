enemyAcc = 0.85; 
local bonusSensory = -5;

function onSet(a)
	kaiju = a;
	if not(kaiju:hasStat("acc_notrack")) then
		kaiju:addStat("acc_notrack", 100);
	end
	local def = kaiju:getStat("acc_notrack");
	def = def * enemyAcc;
	kaiju:setStat("acc_notrack", def);
end

function bonusStats(s)
	s:modStat("SensorsSignature", bonusSensory);
end