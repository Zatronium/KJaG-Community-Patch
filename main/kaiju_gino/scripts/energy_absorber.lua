require 'scripts/common'

local avatar = 0;
local durationtime = 15;
local percentconverted = 0.5;
function onUse(a)
	avatar = a;

	local view = a:getView();
	view:attachEffectToNode("root", "effects/energyAbsorber_coreElectric.plist", durationtime,  0, 0,true, false);
	view:attachEffectToNode("root", "effects/mirrorShield_solid.plist", durationtime,  0, 0,true, false);

	a:addPassiveScript(this);
	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, "gino_energyabsorber");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		avatar:removePassiveScript(this);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
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