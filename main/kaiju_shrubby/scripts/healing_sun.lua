require 'scripts/avatars/common'

local avatar = 0;
local maxHealth = 0;
local healpertick = 5;
local durationtime = 30;
local ticktime = 1;
function onUse(a)
	avatar = a;
	maxHealth = avatar:getStat("MaxHealth");
	
	playSound("shrubby_ability_HealingSun");
	startAbilityUse(avatar, abilityData.name);
	
	playAnimation(avatar, "ability_cast");
	local view = a:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/healing_sun.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/healing_sun_spikes.plist", durationtime, 0, 0, true, false);
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(ticktime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
end

function onTick(aura)
	local curHealth = avatar:getStat("Health");
	if curHealth < maxHealth then
		avatar:gainHealth(healpertick);
	end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end