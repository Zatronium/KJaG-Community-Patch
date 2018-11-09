require 'scripts/avatars/common'

local CDRPercent = 0.1;
local bonusSpeedPercent = 0.1;
local duration = 60;

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
	view:attachEffectToNode("foot_01", "effects/doubleCrush.plist", duration,  0, 0,false, false);
	view:attachEffectToNode("foot_02", "effects/doubleCrush.plist", duration, 0, 0, false, false);
	view:attachEffectToNode("foot_01", "effects/doubleCrush_sparks.plist", duration, 0, 0, false, false);
	view:attachEffectToNode("foot_02", "effects/doubleCrush_sparks.plist", duration,  0, 0,false, false);
	
	startAbilityUse(kaiju, abilityData.name);
	
	kaiju:modStat("CoolDownReductionPercent", CDRPercent);
	local bonusSpeed = kaiju:getBaseStat("Speed") * bonusSpeedPercent;
	kaiju:modStat("Speed", bonusSpeed);
	
	playSound("NuclearInfusion");
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= duration then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:modStat("CoolDownReductionPercent", -CDRPercent);
		kaiju:modStat("Speed", -bonusSpeed);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end