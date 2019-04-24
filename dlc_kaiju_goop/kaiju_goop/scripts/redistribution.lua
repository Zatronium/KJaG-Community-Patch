require 'scripts/common'

local durationtime = 10;

local passiveName = "goop_redist_speed";
local passiveMult = "goop_redist_mult";
local passiveEffect = "goop_redist_effect";

local passiveEmpower = "goop_redist_damage"
--passiveEmpowerFX = "goop_empower_effect"

local redistAura = 0;
local damagePerStep = 5;

local kaiju = nil

function onSet(a)
	kaiju = a;

	kaiju:addPassiveScript(this);
	kaiju:setPassive(passiveMult, 0.01);
	
	redistAura = createAura(this, kaiju, 0);
	redistAura:setTag("goop_redistribution");
	redistAura:setTickParameters(durationtime, 0);
	redistAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	redistAura:setTarget(kaiju);
end

function onOn(speed)
	local current = kaiju:hasPassive(passiveName);
	local empower = kaiju:hasPassive(passiveEmpower);
	local view = kaiju:getView();
	if empower > 0 then
		view:attachEffectToNode("root", "effects/empower.plist", 0, 0, 50, true, false);
	else 
		view:attachEffectToNode("root", "effects/redistribute.plist", 0, 0, 50, true, false);
	end
	if current == 0 then
		local effectID = 0;
		if empower > 0 then
			effectID = view:attachEffectToNode("root", "effects/empower_sparkles.plist", -1, 0, 50, true, false);
		else
			effectID = view:attachEffectToNode("root", "effects/redistribute_sparkles.plist", -1, 0, 50, true, false);
		end
		kaiju:setPassive(passiveEffect, effectID); -- use a differnet core shield with the next id eg "core_shield_1"
	end
	kaiju:setPassive(passiveName, math.min(100, current + speed));
	redistAura:resetElapsed();
end

function onOff()
	if not canTarget(kaiju) then
		return;
	end
	local current = kaiju:hasPassive(passiveName);
	if current > 0 then
		redistAura:enableUpdate(false);
		kaiju:removePassive(passiveName, 0);
		local view = kaiju:getView();
		view:endEffect(kaiju:hasPassive(passiveEffect)); -- make sure to do these 2 lines for each "core_sheld_x" you used
		kaiju:removePassive(passiveEffect, 0); -- make sure to do these 2 lines for each "core_sheld_x" you used
	end
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationtime then
		onOff();
	end
end

function onAvatarDamageTaken(a, n, w)
	if n.y < 5 or not w then
		return;
	end
	local weap = entityToWeapon(w);
	if not weap then
		return;
	end
	if weap:getWeaponClass() == WeaponClass.Energy then
		local speed = n.y / damagePerStep;
		if speed > 0 then
			onOn(speed);
		end
	end
end