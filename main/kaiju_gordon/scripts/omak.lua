require 'scripts/avatars/common'

local bonusDamagePercent = 0.45;
local tempHpPercent = 0.25;
local duration = 20;

local avatar = nil;
local orginalHP = 0;
local orgMax = 0;
local bonusHp = 0;

function onUse(a)
	avatar = a;
	
	playAnimation(avatar, "ability_cast");
		
	local buffAura = Aura.create(this, a);
	buffAura:setTag('military_tactics');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(duration, 0); 
	buffAura:setTarget(a);

	local view = a:getView();
	view:attachEffectToNode("root", "effects/omakBack.plist",duration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/omakFront.plist",duration, 0, 0, true, false);
	
	startAbilityUse(avatar, abilityData.name);
	
	orgMax = avatar:getStat("MaxHealth");
	orginalHp = avatar:getStat("Health");
	bonusHp = orgMax * tempHpPercent;
	
	avatar:modStat("MaxHealth", bonusHp);
	avatar:modStat("Health", bonusHp);
	avatar:modStat("damage_amplify", bonusDamagePercent);

	playSound("OMAK");
end

function onTick(aura)
	if aura:getElapsed() >= duration then
		local a = aura:getOwner();
		a:modStat("MaxHealth", -bonusHp);
		local curHealth = a:getStat("Health");
		if curHealth > orginalHP then
			local diff = curHealth - orginalHp;
			if diff < bonusHp then
				bonusHp = diff;
			end
			a:modStat("Health", -bonusHp);
		end
		a:modStat("damage_amplify", -bonusDamagePercent);
		endAbilityUse(avatar, abilityData.name);
		a:detachAura(aura);
	end
end