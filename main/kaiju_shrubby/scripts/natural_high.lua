local bonusSpeedAtFull = 0.2
local bonusCDRAtFull = 0.2

function onSet(a)
	a:setPassive("natural_high_speed", bonusSpeedAtFull)
	a:setPassive("natural_high_cdr", bonusCDRAtFull)
end