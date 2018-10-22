require 'scripts/avatars/common'

local CDRPercent = 0.1;
local bonusSpeedPercent = 0.1;
local duration = 60;

local avatar = nil;
local bonusSpeed = 0;

function onUse(a)
	avatar = a;
	
	playAnimation(avatar, "ability_stomp");
	
	local buffAura = Aura.create(this, a);
	buffAura:setTag('military_tactics');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(duration, 0); 
	buffAura:setTarget(a);

	local view = a:getView();
	view:attachEffectToNode("foot_01", "effects/doubleCrush.plist", duration,  0, 0,false, false);
	view:attachEffectToNode("foot_02", "effects/doubleCrush.plist", duration, 0, 0, false, false);
	view:attachEffectToNode("foot_01", "effects/doubleCrush_sparks.plist", duration, 0, 0, false, false);
	view:attachEffectToNode("foot_02", "effects/doubleCrush_sparks.plist", duration,  0, 0,false, false);
	
	startAbilityUse(avatar, abilityData.name);
	
	avatar:modStat("CoolDownReductionPercent", CDRPercent);
	bonusSpeed = avatar:getBaseStat("Speed") * bonusSpeedPercent;
	avatar:modStat("Speed", bonusSpeed);
	
	playSound("NuclearInfusion");
end

function onTick(aura)
	if aura:getElapsed() >= duration then
		endAbilityUse(avatar, abilityData.name);
		local a = aura:getOwner();
		a:modStat("CoolDownReductionPercent", -CDRPercent);
		a:modStat("Speed", -bonusSpeed);
		a:detachAura(aura);
	end
end