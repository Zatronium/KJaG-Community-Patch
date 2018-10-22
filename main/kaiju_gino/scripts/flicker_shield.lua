require 'scripts/common'

local avatar = 0;
local deflectchance = 0.5;
local durationtime = 20;
function onUse(a)
	avatar = a;
	if not avatar:hasStat("block_all") then
		avatar:addStat("block_all", 100);
	end
	local def = avatar:getStat("block_all");
	def = def * deflectchance;
	avatar:setStat("block_all", def);

	local view = a:getView();
	view:attachEffectToNode("root", "effects/flickerShield_burst.plist", durationtime, 0, 0, flase, true);
	view:attachEffectToNode("root", "effects/flickerShield.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/flickerShield_electric.plist", durationtime, 0, 0, true, false);

	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, "gino_fliker_shield");
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