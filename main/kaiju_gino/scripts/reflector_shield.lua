local avatar = nil;
local durationtime = 30;

function onUse(a)
	avatar = a;
	avatar:setPassive("reflect_beam", 1);
	local aura = createAura(this, avatar, "gino_reflector");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);

	startAbilityUse(avatar, abilityData.name);

	local view = a:getView();
	view:attachEffectToNode("root", "effects/shieldPulse_backDown.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/shieldPulse_backUp.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/shieldPulse_frontUp.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/shieldPulse_frontDown.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/reflectorShield_solid.plist", durationtime, 0, 0, true, false);
end

function onTick(aura)
	if aura:getElapsed() > durationtime then
		avatar:removePassive("reflect_beam", 0);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end