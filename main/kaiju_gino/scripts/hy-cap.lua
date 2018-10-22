require 'scripts/common'

local avatar = 0;
local resetdamage = 10;
local totalabsorbed = 0;
local durationtime = 5;
function onUse(a)
	avatar = a;
	local view = a:getView();
	view:attachEffectToNode("root", "effects/hyCap_electric.plist", durationtime,  0, 0,true, false);
	view:attachEffectToNode("root", "effects/hyCap_core.plist", durationtime,  0, 0,true, false);
	view:attachEffectToNode("root", "effects/hyCap_pulseFront.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/hyCap_pulseBack.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/hyCap_pulseFront.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/hyCap_pulseBack.plist", durationtime, 0, 0, false, true);

	avatar:addPassiveScript(this);
	avatar:setPassive("hy_cap", resetdamage);
	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		avatar:setPassive("hy_cap", 0);
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