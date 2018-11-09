require 'scripts/avatars/common'
local kaiju = nil;
local bonusArmor = 50;
local duration = 5;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_root");
	playSound("shrubby_ability_Entrench");
	kaiju:modStat("Armor", bonusArmor);
	kaiju:setImmobile(true);
	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(duration, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
end

function onTick(aura)
	if not aura then return end
	
	if aura:getElapsed() >= duration then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:setImmobile(false);
		kaiju:modStat("Armor", -bonusArmor);
		playAnimation(kaiju, "ability_unroot");
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end
