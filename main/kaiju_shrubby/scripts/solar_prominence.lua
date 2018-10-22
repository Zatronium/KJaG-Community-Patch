require 'kaiju_shrubby/scripts/shrubby'

local avatar = nil;
local ShieldHealthPct = 0.5;
local SolarAura = nil;

local aoeRange = 200;
local aoeDamageMin = 10;
local aoeDamageMax = 15;

function onUse(a)
	avatar = a;
	a:setPassive("shield", a:getStat("Health") * ShieldHealthPct);
	startAbilityUse(a, abilityData.name);
	ToggleShields(a, false);
	a:createShieldEffect("root", "effects/solarRadiateBottom.plist", 0, 0, false, true);
	a:createShieldEffect("root", "effects/solarRadiateBack.plist", 0, 0, false, true);
	a:createShieldEffect("root", "effects/solarRadiateFront.plist", 0, 0, true, false);
	a:createShieldEffect("root", "effects/solarShield_pulseback.plist", 0, 0, false, true);
	a:createShieldEffect("root", "effects/solarShield_pulsefront.plist", 0, 0, true, false);
	a:createShieldEffect("root", "effects/solarShield_core.plist", 0, 0, true, false);
	a:createShieldEffect("root", "effects/solarShield_impact.plist", 0, 0, true, false);
	playSound("shrubby_ability_SolarProminence");
	a:setShieldScript(this);
	
	SolarAura = createAura(this, avatar, 0);
	SolarAura:setTag("solar_prominence");
	SolarAura:setTickParameters(1, 0);
	SolarAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	SolarAura:setTarget(avatar);
end

function onTick(aura)
	local targets = getTargetsInRadius(avatar:getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar));
	avatar = getPlayerAvatar();
	for t in targets:iterator() do
		if canTarget(t) and not isSameEntity(avatar, t) then
			applyDamage(avatar, t, math.random(aoeDamageMin, aoeDamageMax));
		end
	end
end

function onShieldEnd(a, broken)
	endAbilityUse(a, abilityData.name);
	ToggleShields(a, true);
	avatar:detachAura(SolarAura);
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