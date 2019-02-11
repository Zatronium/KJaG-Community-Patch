local threshold = 0.5
local bonusSpeed = 0.5
local bonusRegen = 0.5

function onSet(a)
	a:setPassive("shrubby_survival", threshold)
	a:setPassive("shrubby_survival_speed", bonusSpeed)
	a:setPassive("shrubby_survival_regen", bonusRegen)
end
