require 'scripts/common'
local avatar = nil;
local duration = 20;

function onUse(a)
	avatar = a;
	startAbilityUse(avatar, abilityData.name);
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
	if aura:getElapsed() >= duration then
		avatar:setPassive("infinity_pulse", 0);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end