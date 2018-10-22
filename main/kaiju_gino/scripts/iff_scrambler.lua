local duration = 5;
local ticktime = 0.5;
local avatar = nil;
function onUse(a)
	avatar = a;
	startAbilityUse(avatar, abilityData.name);
	local durationtime = 2;
	local view = a:getView();
	view:attachEffectToNode("root", "effects/flickerShield_burst.plist", durationtime, 0, 0, false, true);
	
	view:attachEffectToNode("root", "effects/IFFScrambler_pulseFrontUp.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/IFFScrambler_pulseBackUp.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/IFFScrambler_pulseFrontVertical.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/IFFScrambler_pulseBackVertical.plist", durationtime, 0, 0, false, true);
	
	local timeAura = Aura.create(this, a);
	timeAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	timeAura:setTickParameters(ticktime, 0);
	timeAura:setTarget(a); -- required so aura doesn't autorelease

end

function onTick(aura)
	avatar:misdirectMissiles(0.75, false);
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/IFFScrambler_shockwave.plist", 0, 0, 0, false, true);
	if aura:getElapsed() >= duration then
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end