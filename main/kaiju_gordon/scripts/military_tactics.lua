require 'scripts/avatars/common'

local CDRPercent = 0.2;
local bonusDamagePercent = 0.3;
local duration = 15;

local avatar = nil;

function onUse(a)
	avatar = a;
	
	playAnimation(avatar, "ability_stomp");
	
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
	
	startAbilityUse(avatar, abilityData.name);
	
	avatar:modStat("damage_amplify", bonusDamagePercent);
	avatar:modStat("CoolDownReductionPercent", CDRPercent);
	
	playSound("MilitaryTactics");
end

function onTick(aura)
	if aura:getElapsed() >= duration then
		endAbilityUse(avatar, abilityData.name);
		local a = aura:getOwner();
		a:modStat("damage_amplify", -bonusDamagePercent);
		a:modStat("CoolDownReductionPercent", -CDRPercent);
		a:detachAura(aura);
	end
end