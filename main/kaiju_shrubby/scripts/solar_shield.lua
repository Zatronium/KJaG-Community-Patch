require 'kaiju_shrubby/scripts/shrubby'

local ShieldHealthPct = 0.25;

function onUse(a)
	a:setPassive("shield", a:getStat("Health") * ShieldHealthPct);
	startAbilityUse(a, abilityData.name);
	ToggleShields(a, false);
	a:createShieldEffect("root", "effects/solarShield_pulseback.plist", 0, 0, false, true);
	a:createShieldEffect("root", "effects/solarShield_pulsefront.plist", 0, 0, true, false);
	a:createShieldEffect("root", "effects/solarShield_core.plist", 0, 0, true, false);
	playSound("shrubby_ability_SolarShield");
	a:setShieldScript(this);
end

function onShieldEnd(a, broken)
	endAbilityUse(a, abilityData.name);
	ToggleShields(a, true);
end

function onShieldHit(a, n, w)
	if w and w:getWeaponType() == WeaponType.Beam then
		n.x = 0;
	else
		local view = a:getView();
		view:attachEffectToNode("root", "effects/shield_hit.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/solarShield_impact.plist", 0, 0, 0, true, false);
	end
end