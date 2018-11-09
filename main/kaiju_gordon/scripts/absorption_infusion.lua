require 'kaiju_gordon/scripts/absorption_module'

local kaiju = nil;

local shieldCooldown = 20;
local onCD = false;

function onSet(a)
	kaiju = a;
	kaiju:addPassiveScript(this);
	kaiju:addPassive("absorption_infusion", shieldCooldown);
	kaiju:addPassive("absorption_infusion_ready", 1);
end

function bonusStats(s)
	setAbilityToPassive("ability_gordon_AbsorptionModule");
end