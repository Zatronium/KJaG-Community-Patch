--A set of powerful localized force fields that have a chance of getting between the KAIJU and incoming fire.
--50% chance to block incoming shots for 5 seconds.
--Active.
require 'scripts/common'

local kaiju = 0;
local deflectchance = 0.5;
local durationtime = 10;
function onUse(a)
	kaiju = a;
	if not(kaiju:hasStat("block_all")) then
		kaiju:addStat("block_all", 100);
	end
	local def = kaiju:getStat("block_all");
	kaiju:setStat("block_all", def * deflectchance);
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/deflector_shieldPulseBack.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/deflector_shieldPulseFront.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/deflector_coreShield.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/deflector_shieldSolid.plist", durationtime, 0, 0, true, false);

	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, "gino_defelctors");
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

