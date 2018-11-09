require 'scripts/avatars/common'

local kaiju = 0;
local durationTime = 30;
local convertEnergy = 0.20;

local absorbEnable = false;
function onUse(a)
	kaiju = a;
	absorbEnable = true;

	kaiju:addPassiveScript(this);
	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(durationTime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
	effectsON(kaiju);
end

function effectsON(a)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/absorptionModule.plist",durationTime, 0, 0, true, false);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationTime then	
		if kaiju:hasPassive("absorption_infusion") > 0 then
			local auraB = createAura(this, kaiju, 0);
			auraB:setTickParameters(kaiju:hasPassive("absorption_infusion"), 0);
			auraB:setScriptCallback(AuraEvent.OnTick, "onCD");
			auraB:setTarget(a);
			absorbEnable = false;
		else
			kaiju:removePassiveScript(this);
			endAbilityUse(kaiju, abilityData.name);
		end
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end

function onCD(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationTime then	
		kaiju:setPassive("absorption_infusion_ready", 1);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end

function onAvatarAbsorb(a, n, w)
	if kaiju:hasPassive("absorption_infusion_ready") > 0 then
		local aura = createAura(this, kaiju, 0);
		aura:setTickParameters(durationTime, 0);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(a);
		kaiju:removePassive("absorption_infusion_ready", 0);
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
			kaiju:gainPower(amount);
		end
	end
end