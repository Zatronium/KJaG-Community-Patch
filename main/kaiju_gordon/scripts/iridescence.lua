require 'kaiju_gordon/scripts/dispersal_field'

local kaiju = nil;

local shieldCooldown = 20;
local onCD = false;

function onSet(a)
	kaiju = a;
	kaiju:addPassiveScript(this);
end

function bonusStats(s)
	setAbilityToPassive("ability_gordon_DispersalField");
end


