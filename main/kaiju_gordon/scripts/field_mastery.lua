require 'kaiju_gordon/scripts/gordon'
-- see Personal shield
local shieldBonus = 0.20;
local shieldCD = 0.20;
shieldCooldownRedution = 0.1; --??
function onSet(a)
	kaiju = a;
	kaiju:addPassive("shield_bonus", shieldBonus);
	kaiju:addPassive("field_mastery_cd", shieldCD);
end
	