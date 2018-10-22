local armorBonus = -1;
local bonusSensory = -25;
enemyAcc = 0.75; 

function onSet(a)
	if not isDayTime() then
		local def = a:getStat("acc_notrack");
		def = def * enemyAcc;
		a:setStat("acc_notrack", def);
	end
end

function bonusStats(s)
	s:modStat("Armor", armorBonus);
	s:modStat("SensorsSignature", bonusSensory);
end
