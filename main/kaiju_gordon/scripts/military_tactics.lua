require 'scripts/avatars/common'

local CDRPercent = 0.2;
local bonusDamagePercent = 0.3;
local duration = 15;

local kaiju = nil;

function onUse(a)
	kaiju = a;
	
	playAnimation(kaiju, "ability_stomp");
	
	local buffAura = Aura.create(this, a);
	buffAura:setTag('military_tactics');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(duration, 0); 
	buffAura:setTarget(a);

	local view = a:getView();
	view:attachEffectToNode("foot_01", "effects/combat_maneuvers.plist", duration, 0, 0, false, true);
	view:attachEffectToNode("foot_02", "effects/combat_maneuvers.plist", duration, 0, 0, false, true);
	view:attachEffectToNode("foot_01", "effects/militaryTacticsFire.plist", duration, 0, 0, false, true);
	view:attachEffectToNode("foot_02", "effects/militaryTacticsFire.plist", duration, 0, 0, false, true);
	
	startAbilityUse(kaiju, abilityData.name);
	
	kaiju:modStat("damage_amplify", bonusDamagePercent);
	kaiju:modStat("CoolDownReductionPercent", CDRPercent);
	
	playSound("MilitaryTactics");
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= duration then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:modStat("damage_amplify", -bonusDamagePercent);
		kaiju:modStat("CoolDownReductionPercent", -CDRPercent);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end