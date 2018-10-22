require 'scripts/avatars/common'

local avatar = 0;
local durationtime = 30;
local hasUpdated = false;

local PdValue = 100;
local accDebuff = -0.1;
local accValue = 0;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_channel");
	
	avatar:misdirectMissiles(1.0, false);
	accValue = avatar:getStat("acc_notrack") * accDebuff;
	avatar:modStat("acc_notrack", accValue);
	avatar:modStat("PD_Tracking", PdValue);
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/sakuraStormPetals.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormAura_back.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/sakuraStormAura_front.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormLeft.plist", durationtime, -110, 100, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormRight.plist", durationtime, 110, 100, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormLeft.plist", durationtime, -80, 180, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormRight.plist", durationtime, 80, 180, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormLeft.plist", durationtime, -50, 280, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormRight.plist", durationtime, 50, 280, true, false);
	playSound("shrubby_ability_SakuraStorm");
	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
end

function onTick(aura)
	if hasUpdated then
		endAbilityUse(avatar, abilityData.name);
		avatar:modStat("acc_notrack", -accValue);
		avatar:modStat("PD_Tracking", -PdValue);
		aura:getOwner():detachAura(aura);
	end
	hasUpdated = true;
end