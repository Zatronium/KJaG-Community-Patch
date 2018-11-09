require 'scripts/common'

local kaiju = nil
local energygain = 2;
local durationtime = 5;
local reduceEXP = 0.5;
function onUse(a)
	kaiju = a;
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/blastAbsorbtion_core.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/kineticLayering_intro.plist", durationtime, 0, 0, true, false);

	a:addPassiveScript(this);
	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, "gino_blast_absorbtion");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
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