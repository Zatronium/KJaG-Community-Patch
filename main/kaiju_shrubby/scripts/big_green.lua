local bonusSeedHealth = 1
local bonusSeedDamage = 0.2

function onSet(a)
	a:addPassive("seed_health_bonus", bonusSeedHealth)
	a:addPassive("seed_damage_bonus", bonusSeedDamage)
end
