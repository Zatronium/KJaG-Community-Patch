require 'scripts/avatars/common'

local kaiju = 0;
local durationTime = 20;
local energyReduction = 0.5;

function onUse(a)
	kaiju = a;
	
	--local view = a:getView();

	kaiju:addPassiveScript(this);
	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(durationTime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/energyAbsorber_coreElectric.plist",durationTime, 0, 0, true, false);
	playSound("DispersalField");
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationTime then	
		endAbilityUse(kaiju, abilityData.name);
		kaiju:removePassiveScript(this);
		
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
	if weap:getWeaponType() == WeaponType.Beam then
		-- dampens lasers but still take the damage
		if a:hasPassive("shield_laser_block") > 0 then
			n.x = n.x * a:hasPassive("shield_laser_block");
		end
	end
	if n.x > 0 and weap:getWeaponClass() == WeaponClass.Energy then
		n.x = n.x * energyReduction;
	end
end