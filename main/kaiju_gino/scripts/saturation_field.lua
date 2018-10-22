require 'scripts/common'

local avatar = nil;

local range = 500;
local disableDuration = 25;
local freezeDuration = 5;

local shieldDuration = 30;

function onUse(a)
	avatar = a;
	startAbilityUse(a, abilityData.name);
	a:setPassive("shield", 200);
	abilityEnabled(a, abilityData.name, false);
	abilityEnabled(a, "Force Shield", false); -- turn off force shield 
	abilityEnabled(a, "Blackout", false);
	a:createShieldEffect("root", "effects/forceShield_pulseBack.plist", 0, 0, false, true);
	a:createShieldEffect("root", "effects/forceShield_pulseFront.plist", 0, 0, true, false);
	a:createShieldEffect("root", "effects/forceShield_core.plist", 0, 0, true, false);
	a:createShieldEffect("root", "effects/forceShield_electric.plist", 0, 0, true, false);
	a:setShieldScript(this);
	
	local shieldAura = Aura.create(this, a);
	shieldAura:setTag('saturation_field');
	shieldAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	shieldAura:setTickParameters(shieldDuration, 0); --updates every second                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	shieldAura:setTarget(a); -- required so aura doesn't autorelease
end

function onTick(aura)
	if aura:getElapsed() >= shieldDuration then
		avatar:endShield(false);
		aura:getOwner():detachAura(aura);
	end
end

function onShieldEnd(a, broken)
	abilityEnabled(a, abilityData.name, true);
	abilityEnabled(a, "Force Shield", true); -- turn on force shield 
	abilityEnabled(a, "Blackout", true);
	endAbilityUse(a, abilityData.name);
	if broken == true then
		local view = a:getView();
		view:attachEffectToNode("root", "effects/saturationField_burst.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/saturationField_shockwave.plist", 0, 0, 0, true, false);
		view:pauseAnimation(freezeDuration);
		local worldPos = avatar:getWorldPosition();
		local targets = getTargetsInRadius(worldPos, range, EntityFlags(EntityType.Vehicle));
		for t in targets:iterator() do
			local v = entityToVehicle(t);
			if v:getVehicleType() == VehicleType.Infantry then
			
			else
				v:attachEffect("effects/onEmp.plist", disableDuration, true);
				t:disabled(disableDuration);
			end
		end
	end
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