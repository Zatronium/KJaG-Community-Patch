local kaiju = nil;
local durationtime = 30;

function onUse(a)
	kaiju = a;
	kaiju:setPassive("reflect_beam", 1);
	local aura = createAura(this, kaiju, "gino_reflector");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);

	startAbilityUse(kaiju, abilityData.name);

	local view = a:getView();
	view:attachEffectToNode("root", "effects/shieldPulse_backDown.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/shieldPulse_backUp.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/shieldPulse_frontUp.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/shieldPulse_frontDown.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/reflectorShield_solid.plist", durationtime, 0, 0, true, false);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() > durationtime then
		kaiju:removePassive("reflect_beam", 0);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end