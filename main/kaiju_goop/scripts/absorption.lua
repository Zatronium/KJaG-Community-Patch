require 'scripts/common'

local hpPerHit = 1;
local durationtime = 60;

local kaiju = nil
local scriptAura = 0;

function onUse(a)
	kaiju = a;

	onStart(durationtime);
	
	a:addPassiveScript(this);

	startAbilityUse(kaiju, abilityData.name);
	
	scriptAura = createAura(this, kaiju, 0);
	scriptAura:setTag("goop_absorption");
	scriptAura:setTickParameters(durationtime, 0);
	scriptAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	scriptAura:setTarget(a);
end

function onStart(duration)
	kaiju:setPassive("goop_absorption", hpPerHit);
	local view = kaiju:getView();
--	view:attachEffectToNode("root", "effects/absorption_heal.plist", duration, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/absorbo_glob2.plist", duration, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/harden.plist", 0, 0, 50, true, false);
--	view:attachEffectToNode("root", "effects/kineticLayering_intro.plist", duration, 0, 0, true, false);
	
	playSound("goop_ability_Absorption");
end

function onInterrupt()
	endAbilityUse(kaiju, abilityData.name);
	kaiju:removePassiveScript(this);
	
	scriptAura:getOwner():detachAura(scriptAura);
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:removePassiveScript(this);
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			owner:detachAura(aura)
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
	if weap:getWeaponType() ~= WeaponType.Beam
	and weap:getWeaponType() ~= WeaponType.Melee  
	and not weap:hasMode("EXP") then
		if a:hasPassive("goop_meals") > 0 and n.y >= a:hasPassive("goop_meals") then
			a:gainHealth(a:hasPassive("goop_meals_heal"));
		else
			a:gainHealth(a:hasPassive("goop_absorption"));
		end
		local view = a:getView();
	--	view:attachEffectToNode("root", "effects/kineticLayering_hitShockwave.plist", 0, 0, 0, false, true);
	--	view:attachEffectToNode("root", "effects/kineticLayering_hitAbsorb.plist", 0, 0, 0, true, false);
	--	view:attachEffectToNode("root", "effects/absorption_heal.plist", 0, 0, 0, true, false);
	end
end