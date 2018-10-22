--A set of powerful localized force fields that have a chance of getting between the KAIJU and incoming fire.
--50% chance to block incoming shots for 5 seconds.
--Active.
require 'scripts/common'

local avatar = 0;
local deflectchance = 0.5;
local durationtime = 10;
function onUse(a)
	avatar = a;
	if not avatar:hasStat("block_all") then
		avatar:addStat("block_all", 100);
	end
	local def = avatar:getStat("block_all");
	def = def * deflectchance;
	avatar:setStat("block_all", def);
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/deflector_shieldPulseBack.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/deflector_shieldPulseFront.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/deflector_coreShield.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/deflector_shieldSolid.plist", durationtime, 0, 0, true, false);

	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, "gino_defelctors");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		local def = avatar:getStat("block_all");
		def = def / deflectchance;
		avatar:setStat("block_all", def);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end

