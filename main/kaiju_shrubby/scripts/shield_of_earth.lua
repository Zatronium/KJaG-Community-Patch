require 'kaiju_shrubby/scripts/shrubby'

local ShieldHealth = 75;
local avatar = 0;

local bonusArmor = 3;
local bonusSpeedPercent = -0.1;
local bonusSpeed = 0;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "stomp");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	a:setPassive("shield", ShieldHealth);
	a:modStat("Armor", bonusArmor);
	bonusSpeed = a:getStat("Speed") * bonusSpeedPercent;
	a:modStat("Speed", bonusSpeed);
	startAbilityUse(a, abilityData.name);
	ToggleShields(a, false);
	a:createShieldEffect("root", "effects/auraEarthShield_core.plist", 0, 0, true, false);
	a:createShieldEffect("root", "effects/auraShield_electric.plist", 0, 0, true, false);
	playSound("shrubby_ability_ShieldOfEarth");
	a:setShieldScript(this);
	a:addPassiveScript(this);
end

function onShieldEnd(a, broken)
	endAbilityUse(a, abilityData.name);
	ToggleShields(a, true);
	a:removePassiveScript(this);
	a:modStat("Armor", -bonusArmor);
	a:modStat("Speed", -bonusSpeed);
end

function onShieldHit(a, n, w)
	if w and w:getWeaponType() == WeaponType.Beam then
		n.x = 0;
	else
		local view = a:getView();
		view:attachEffectToNode("root", "effects/shield_hit.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/auraShield_hit.plist", 0, 0, 0, true, false);
	end
end