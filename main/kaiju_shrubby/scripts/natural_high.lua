local bonusSpeedAtFull = 0.20
local bonusCDRAtFull = 0.20

function onSet(a)
	a:setPassive("natural_high_speed", bonusSpeedAtFull);
	a:setPassive("natural_high_cdr", bonusCDRAtFull);
end