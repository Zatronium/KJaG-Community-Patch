require 'scripts/common'

local kaiju = nil
local deflectchance = 0.25;
local durationtime = 30;
function onUse(a)
	kaiju = a;
	if not(kaiju:hasStat("def_beam")) then
		kaiju:addStat("def_beam", 100);
	end
	local def = kaiju:getStat("def_beam") * deflectchance;
	kaiju:setStat("def_beam", def);

	local view = a:getView();
	view:attachEffectToNode("root", "effects/mirrorShield_pulseBack.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/mirrorShield_pulseFront.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/mirrorShield_solid.plist", durationtime, 0, 0, true, false);

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
		local def = kaiju:getStat("def_beam") / deflectchance;
		kaiju:setStat("def_beam", def);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end