require 'scripts/common'
local kaiju = nil;
local duration = 20;

function onUse(a)
	kaiju = a;
	startAbilityUse(kaiju, abilityData.name);
	a:setPassive("infinity_pulse", 1);
	local timeAura = Aura.create(this, a);
	timeAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	timeAura:setTickParameters(duration, 0);
	timeAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("root", "effects/infinityPulse_back.plist", duration, 0,0, false, true);
	view:attachEffectToNode("root", "effects/infinityPulse_front.plist", duration, 0,0, true, false);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= duration then
		kaiju:setPassive("infinity_pulse", 0);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end