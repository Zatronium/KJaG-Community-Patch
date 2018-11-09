require 'scripts/avatars/common'

local bonusDamagePercent = 0.45;
local tempHpPercent = 0.25;
local duration = 20;

local kaiju = nil;
local orginalHP = 0;
local bonusHp = 0;

function onUse(a)
	kaiju = a;
	
	playAnimation(kaiju, "ability_cast");
		
	local buffAura = Aura.create(this, a);
	buffAura:setTag('military_tactics');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(duration, 0); 
	buffAura:setTarget(a);

	local view = a:getView();
	view:attachEffectToNode("root", "effects/omakBack.plist",duration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/omakFront.plist",duration, 0, 0, true, false);
	
	startAbilityUse(kaiju, abilityData.name);
	
	local orgMax = kaiju:getStat("MaxHealth");
	orginalHp = kaiju:getStat("Health");
	bonusHp = orgMax * tempHpPercent;
	
	kaiju:modStat("MaxHealth", bonusHp);
	kaiju:modStat("Health", bonusHp);
	kaiju:modStat("damage_amplify", bonusDamagePercent);

	playSound("OMAK");
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= duration then
		kaiju:modStat("MaxHealth", -bonusHp);
		local curHealth = kaiju:getStat("Health");
		if curHealth > orginalHP then
			local diff = curHealth - orginalHp;
			if diff < bonusHp then
				bonusHp = diff;
			end
			kaiju:modStat("Health", -bonusHp);
		end
		kaiju:modStat("damage_amplify", -bonusDamagePercent);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end