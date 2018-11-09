require 'scripts/common'

local kaiju = nil
local resetdamage = 10;
local totalabsorbed = 0;
local durationtime = 5;
function onUse(a)
	kaiju = a;
	local view = a:getView();
	view:attachEffectToNode("root", "effects/hyCap_electric.plist", durationtime,  0, 0,true, false);
	view:attachEffectToNode("root", "effects/hyCap_core.plist", durationtime,  0, 0,true, false);
	view:attachEffectToNode("root", "effects/hyCap_pulseFront.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/hyCap_pulseBack.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/hyCap_pulseFront.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/hyCap_pulseBack.plist", durationtime, 0, 0, false, true);

	kaiju:addPassiveScript(this);
	kaiju:setPassive("hy_cap", resetdamage);
	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationtime then
		kaiju:setPassive("hy_cap", 0);
		kaiju:removePassiveScript(this);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end

function onAvatarAbsorb(a, n, w)
	if n.y < 1 or not w then
		return;
	end
	local weap = entityToWeapon(w);
	if not weap then
		return;
	end
	
	if weap:getWeaponClass() == WeaponClass.Energy then
		totalabsorbed = totalabsorbed + n.y;
		if totalabsorbed >= resetdamage then
			totalabsorbed = 0;
			a:resetLowestCooldown();
		end
		local view = a:getView();
		view:attachEffectToNode("root", "effects/blastAbsorbtion_hitShockwave.plist", 0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/blastAbsorbtion_hitEnergy.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/kineticLayering_hitAbsorb.plist", 0, 0, 0, true, false);
		n.x = 0;
	end
end