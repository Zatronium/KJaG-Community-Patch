bonusMove = 0.2;
bonusSensory = -20;

function bonusStats(s)
	s:modStat("MapSpeed", s:getStat("MapSpeed") * bonusMove);
	s:modStat("SensorsSignature", bonusSensory);
end
