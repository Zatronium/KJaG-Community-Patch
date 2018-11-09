require 'scripts/avatars/common'

local kaiju = nil
local maxHealth = 0;
local healpertick = 5;
local durationtime = 30;
local ticktime = 1;
function onUse(a)
	kaiju = a;
	maxHealth = kaiju:getStat("MaxHealth");
	
	playSound("shrubby_ability_HealingSun");
	startAbilityUse(kaiju, abilityData.name);
	
	playAnimation(kaiju, "ability_cast");
	local view = a:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/healing_sun.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/healing_sun_spikes.plist", durationtime, 0, 0, true, false);
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(ticktime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
end

function onTick(aura)
	if not aura then return end
	local curHealth = kaiju:getStat("Health");
	if curHealth < maxHealth then
		kaiju:gainHealth(healpertick);
	end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end