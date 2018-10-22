require 'kaiju_gordon/scripts/absorption_module'

local avatar = nil;

local shieldCooldown = 20;
local onCD = false;

function onSet(a)
	avatar = a;
	avatar:addPassiveScript(this);
	avatar:addPassive("absorption_infusion", shieldCooldown);
	avatar:addPassive("absorption_infusion_ready", 1);
end

function bonusStats(s)
	setAbilityToPassive("ability_gordon_AbsorptionModule");
end