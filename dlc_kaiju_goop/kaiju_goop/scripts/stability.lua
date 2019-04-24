require 'scripts/common'

durationtime = 60;
EnergyDamage = 0.75;

kaiju = 0;
scriptAura = 0;

function onUse(a)
	kaiju = a;

	local view = a:getView();
	view:attachEffectToNode("root", "effects/goop_stabilize_back.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/goop_stabilize_front.plist", durationtime, 0, 0, true, false);

	a:addPassiveScript(this);
	
	startAbilityUse(kaiju, abilityData.name);
	
	scriptAura = createAura(this, kaiju, 0);
	scriptAura:setTag("goop_stability");
	scriptAura:setTickParameters(durationtime, 0);
	scriptAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	scriptAura:setTarget(a);
	
	playSound("goop_ability_Stability");
end

function onInterrupt()
	kaiju = entityToAvatar(scriptAura:getOwner());
	endAbilityUse(kaiju, abilityData.name);
	kaiju:removePassiveScript(this);
	scriptAura:getOwner():detachAura(scriptAura);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		kaiju = entityToAvatar(aura:getOwner());
		endAbilityUse(kaiju, abilityData.name);
		kaiju:removePassiveScript(this);
		aura:getOwner():detachAura(aura);
	end
end

function onAvatarAbsorb(a, n, w)
	if n.y <= 1 or w == nil then
		return;
	end
	local weap = entityToWeapon(w);
	if weap == nil then
		return;
	end
	if weap:getWeaponClass() == WeaponClass.Energy then
		n.x = n.x * EnergyDamage;
--		local view = a:getView();
--		view:attachEffectToNode("root", "effects/kineticLayering_hitShockwave.plist", 0, 0, 0, false, true);
--		view:attachEffectToNode("root", "effects/kineticLayering_hitAbsorb.plist", 0, 0, 0, true, false);
--		view:attachEffectToNode("root", "effects/kineticLayering_hit.plist", 0, 0, 0, true, false);
	end
end