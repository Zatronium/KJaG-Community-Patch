function onUse(a)
	a:setPassive("shield", 200);
	startAbilityUse(a, abilityData.name);
	abilityEnabled(a, abilityData.name, false);
	abilityEnabled(a, "Saturation Field", false);
	abilityEnabled(a, "Blackout", false);
	a:createShieldEffect("root", "effects/forceShield_pulseBack.plist", 0, 0, false, true);
	a:createShieldEffect("root", "effects/forceShield_pulseFront.plist", 0, 0, true, false);
	a:createShieldEffect("root", "effects/forceShield_core.plist", 0, 0, true, false);
	a:createShieldEffect("root", "effects/forceShield_electric.plist", 0, 0, true, false);
	a:setShieldScript(this);
end

function onShieldEnd(a, broken)
	abilityEnabled(a, abilityData.name, true);
	abilityEnabled(a, "Saturation Field", true);
	abilityEnabled(a, "Blackout", true);
	endAbilityUse(a, abilityData.name);
end

function onShieldHit(a, n, w)
	if w and w:getWeaponType() == WeaponType.Beam then
		n.x = 0;
	else
		local view = a:getView();
		view:attachEffectToNode("root", "effects/shield_hit.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/forceshield_hit.plist", 0, 0, 0, true, false);
	end
end