require 'kaiju_gordon/scripts/dispersal_field'

local avatar = nil;

local shieldCooldown = 20;
local onCD = false;

function onSet(a)
	avatar = a;
	avatar:addPassiveScript(this);
end

function bonusStats(s)
	setAbilityToPassive("ability_gordon_DispersalField");
end


