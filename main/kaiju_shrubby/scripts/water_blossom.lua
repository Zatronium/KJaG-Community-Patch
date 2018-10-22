require 'scripts/avatars/common'

local avatar = 0;
local durationtime = 30;

local healBonus = 1.0;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_channel");
	avatar:removeDOT("Fire");
	avatar:addPassive("heal_bonus_mult", healBonus);
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/waterBlossomHealth.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/waterBlossom.plist", durationtime, 0, 250, true, false);
	view:attachEffectToNode("root", "effects/waterBlossomPetals.plist", durationtime, 0, 250, true, false);
	playSound("shrubby_ability_WaterBlossom");
	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, 0);
	aura:setTag("shrubby_water_blossom");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		endAbilityUse(avatar, abilityData.name);
		avatar:addPassive("heal_bonus_mult", -healBonus);
		aura:getOwner():detachAura(aura);
	end
end