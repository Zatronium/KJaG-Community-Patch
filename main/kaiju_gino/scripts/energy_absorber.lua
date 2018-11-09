require 'scripts/common'

local kaiju = nil
local durationtime = 15;
local percentconverted = 0.5;
function onUse(a)
	kaiju = a;

	local view = a:getView();
	view:attachEffectToNode("root", "effects/energyAbsorber_coreElectric.plist", durationtime,  0, 0,true, false);
	view:attachEffectToNode("root", "effects/mirrorShield_solid.plist", durationtime,  0, 0,true, false);

	a:addPassiveScript(this);
	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, "gino_energyabsorber");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationtime then
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
		local view = a:getView();
		view:attachEffectToNode("root", "effects/blastAbsorbtion_hitShockwave.plist", 0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/blastAbsorbtion_hitEnergy.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/kineticLayering_hitAbsorb.plist", 0, 0, 0, true, false);
		local powergain = percentconverted * n.y;
		a:gainPower(powergain);
		n.x = 0;
	end
end