require 'scripts/avatars/common'
local avatar = nil;
local bonusArmor = 50;
local duration = 5;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_root");
	playSound("shrubby_ability_Entrench");
	avatar:modStat("Armor", bonusArmor);
	avatar:setImmobile(true);
	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(duration, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
end

function onTick(aura)
	
	
	if aura:getElapsed() >= duration then
		endAbilityUse(avatar, abilityData.name);
		avatar:setImmobile(false);
		avatar:modStat("Armor", -bonusArmor);
		playAnimation(avatar, "ability_unroot");
		aura:getOwner():detachAura(aura);
	end
end
