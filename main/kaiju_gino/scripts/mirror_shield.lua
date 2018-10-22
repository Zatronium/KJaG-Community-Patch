require 'scripts/common'

local avatar = 0;
local deflectchance = 0.25;
local durationtime = 30;
function onUse(a)
	avatar = a;
	if not avatar:hasStat("def_beam") then
		avatar:addStat("def_beam", 100);
	end
	local def = avatar:getStat("def_beam");
	def = def * deflectchance;
	avatar:setStat("def_beam", def);

	local view = a:getView();
	view:attachEffectToNode("root", "effects/mirrorShield_pulseBack.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/mirrorShield_pulseFront.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/mirrorShield_solid.plist", durationtime, 0, 0, true, false);

	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		local def = avatar:getStat("def_beam");
		def = def / deflectchance;
		avatar:setStat("def_beam", def);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end