require 'scripts/common'

local kaiju = nil
local deflectchance = 0.5;
local durationtime = 20;
function onUse(a)
	kaiju = a;
	if not kaiju:hasStat("block_all") then
		kaiju:addStat("block_all", 100);
	end
	local def = kaiju:getStat("block_all");
	kaiju:setStat("block_all", def * deflectchance);

	local view = a:getView();
	view:attachEffectToNode("root", "effects/flickerShield_burst.plist", durationtime, 0, 0, flase, true);
	view:attachEffectToNode("root", "effects/flickerShield.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/flickerShield_electric.plist", durationtime, 0, 0, true, false);

	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, "gino_flicker_shield");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationtime then
		local def = kaiju:getStat("block_all");
		kaiju:setStat("block_all", def / deflectchance);
		endAbilityUse(kaiju, abilityData.name);	

		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end