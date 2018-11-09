require 'scripts/avatars/common'

local kaiju = 0;
local durationtime = 30;

local healBonus = 1.0;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_channel");
	kaiju:removeDOT("Fire");
	kaiju:addPassive("heal_bonus_mult", healBonus);
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/waterBlossomHealth.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/waterBlossom.plist", durationtime, 0, 250, true, false);
	view:attachEffectToNode("root", "effects/waterBlossomPetals.plist", durationtime, 0, 250, true, false);
	playSound("shrubby_ability_WaterBlossom");
	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, 0);
	aura:setTag("shrubby_water_blossom");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:addPassive("heal_bonus_mult", -healBonus);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end