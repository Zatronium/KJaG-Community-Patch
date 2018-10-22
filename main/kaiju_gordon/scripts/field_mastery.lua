require 'kaiju_gordon/scripts/gordon'
-- see Personal shield
local shieldBonus = 0.20;
local shieldCD = 0.20;

function onSet(a)
	avatar = a;
	avatar:addPassive("shield_bonus", shieldBonus);
	avatar:addPassive("field_mastery_cd", shieldCD);
end
	