 require 'scripts/common'
local range = 500;

function onUse(a)
	local total = 0;
	local worldPos = a:getWorldPosition();
	local targets = getTargetsInRadius(worldPos, range, EntityFlags(EntityType.Zone));	
	local view = a:getView();
	local scenePos = view:getAnimationNodePositionOffset("pelvis");
	for t in targets:iterator() do
		local minpow = t:getStat("MinPower");
		local maxpow = t:getStat("MaxPower");
		if minpow > 0 or maxpow > 0 then
			local proj = fireProjectileAtTarget(t, a, Point(0,0), scenePos, "weapon_electricShard");
			if maxpow > 0 and minpow < maxpow then
				total = total + math.random(minpow, maxpow);
			else
				total = total + minpow;
			end
		end
		t:setStat("MinPower", 0);
		t:setStat("MaxPower", 0);
		local zone = entityToZone(t);
		zone:disableEmission();
	end
	if total > 0 then
		a:setPassive("shield", total);
		startAbilityUse(a, abilityData.name);
		abilityEnabled(a, abilityData.name, false);
		abilityEnabled(a, "Saturation Field", false);
		abilityEnabled(a, "Force Shield", false);
		a:createShieldEffect("root", "effects/forceShield_pulseBack.plist", 0, 0, false, true);
		a:createShieldEffect("root", "effects/forceShield_pulseFront.plist", 0, 0, true, false);
		a:createShieldEffect("root", "effects/forceShield_core.plist", 0, 0, true, false);
		a:createShieldEffect("root", "effects/forceShield_electric.plist", 0, 0, true, false);
		local view = a:getView();
		view:attachEffectToNode("root", "effects/blackOut_energyDraw.plist", 0,  0, 0,false, true);
		a:setShieldScript(this);
	end
end

function onShieldEnd(a, broken)
	abilityEnabled(a, abilityData.name, true);
	abilityEnabled(a, "Saturation Field", true);
	abilityEnabled(a, "Force Shield", true);
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