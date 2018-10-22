require 'scripts/avatars/common'

local avatar = 0;
local durationtime = 10;

local PdValue = 100;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_channel");
	
	avatar:misdirectMissiles(1.0, false);
	avatar:modStat("PD_Tracking", PdValue);
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/chaffBlossomLeft.plist", durationtime, -110, 100, true, false);
	view:attachEffectToNode("root", "effects/chaffBlossomRight.plist", durationtime, 110, 100, true, false);
	view:attachEffectToNode("root", "effects/chaffBlossomLeft.plist", durationtime, -80, 180, true, false);
	view:attachEffectToNode("root", "effects/chaffBlossomRight.plist", durationtime, 80, 180, true, false);
	view:attachEffectToNode("root", "effects/chaffBlossomLeft.plist", durationtime, -50, 280, true, false);
	view:attachEffectToNode("root", "effects/chaffBlossomRight.plist", durationtime, 50, 280, true, false);
	playSound("shrubby_ability_ChaffBlossom");
	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, 0);
	aura:setTag("shrubby_chaff_blossom");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		endAbilityUse(avatar, abilityData.name);
		avatar:modStat("PD_Tracking", -PdValue);
		aura:getOwner():detachAura(aura);
	end
end