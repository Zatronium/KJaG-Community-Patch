require 'scripts/avatars/common'

local avatar = 0;
local durationTime = 30;
local convertEnergy = 0.20;

local absorbEnable = false;
function onUse(a)
	avatar = a;
	absorbEnable = true;

	avatar:addPassiveScript(this);
	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(durationTime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
	effectsON(avatar);
end

function effectsON(a)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/absorptionModule.plist",durationTime, 0, 0, true, false);
end

function onTick(aura)
	if aura:getElapsed() >= durationTime then	
		if avatar:hasPassive("absorption_infusion") > 0 then
			local aura = createAura(this, avatar, 0);
			aura:setTickParameters(avatar:hasPassive("absorption_infusion"), 0);
			aura:setScriptCallback(AuraEvent.OnTick, "onCD");
			aura:setTarget(a);
			absorbEnable = false;
		else
			avatar:removePassiveScript(this);
			endAbilityUse(avatar, abilityData.name);
		end
		aura:getOwner():detachAura(aura);
	end
end

function onCD(aura)
	if aura:getElapsed() >= durationTime then	
		avatar:setPassive("absorption_infusion_ready", 1);
		aura:getOwner():detachAura(aura);
	end
end

function onAvatarAbsorb(a, n, w)
	if avatar:hasPassive("absorption_infusion_ready") > 0 then
		local aura = createAura(this, avatar, 0);
		aura:setTickParameters(durationTime, 0);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(a);
		avatar:removePassive("absorption_infusion_ready", 0);
		absorbEnable = true;
		effectsON(a);
	end
	
	if absorbEnable then
		if n.y <= 1 or not w then
			return;
		end
		local weap = entityToWeapon(w);
		if not weap then
			return;
		end
	
		if weap:getWeaponClass() == WeaponClass.Energy then
			local amount = n.x * convertEnergy;
			n.x = n.x - amount;
			avatar:gainPower(amount);
		end
	end
end