require 'scripts/common'

local avatar = 0;
local energygain = 2;
local durationtime = 5;
local reduceEXP = 0.5;
local hasUpdated = false;
function onUse(a)
	avatar = a;
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/blastAbsorbtion_core.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/kineticLayering_intro.plist", durationtime, 0, 0, true, false);

	a:addPassiveScript(this);
	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, "gino_blast_absorbtion");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		avatar:removePassiveScript(this);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end

function onAvatarAbsorb(a, n, w)
	if n.y <= 1 or not w then
		return;
	end
	local weap = entityToWeapon(w);
	if not weap then
		return;
	end
	
	if weap:getWeaponType() ~= WeaponType.Beam then
		if weap:hasMode("EXP") then
			n.x = n.x * reduceEXP;
		end
		a:gainPower(energygain);
		local view = a:getView();
		view:attachEffectToNode("root", "effects/blastAbsorbtion_hitShockwave.plist", 0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/blastAbsorbtion_hitEnergy.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/kineticLayering_hitAbsorb.plist", 0, 0, 0, true, false);
	end
end