require 'scripts/common'

local avatar = 0;
local energygain = 2;
local durationtime = 15;
function onUse(a)
	avatar = a;

	local view = a:getView();
	view:attachEffectToNode("root", "effects/kineticLayering_core.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/kineticLayering_intro.plist", durationtime, 0, 0, true, false);

	a:addPassiveScript(this);
	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, 0);
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