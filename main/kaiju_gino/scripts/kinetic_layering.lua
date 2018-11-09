require 'scripts/common'

local kaiju = nil
local energygain = 2;
local durationtime = 15;
function onUse(a)
	kaiju = a;

	local view = a:getView();
	view:attachEffectToNode("root", "effects/kineticLayering_core.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/kineticLayering_intro.plist", durationtime, 0, 0, true, false);

	a:addPassiveScript(this);
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

function onAvatarHit(a, n, w)
	if n.y <= 1 or not w then
		return;
	end
	local weap = entityToWeapon(w);
	if not weap then
		return;
	end
	
	if weap:getWeaponType() ~= WeaponType.Beam and not weap:hasMode("EXP") then
		a:gainPower(energygain);
		local view = a:getView();
		view:attachEffectToNode("root", "effects/kineticLayering_hitShockwave.plist", 0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/kineticLayering_hitAbsorb.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/kineticLayering_hit.plist", 0, 0, 0, true, false);
	end
end