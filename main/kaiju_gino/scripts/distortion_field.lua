require 'scripts/common'

local avatar = 0;
local enemyAcc = 0.5;
local enemyAccNum = 0;
local durationtime = 20;
local hasUpdated = false;
function onUse(a)
	avatar = a;
	if not avatar:hasStat("acc_notrack") then
		avatar:addStat("acc_notrack", 100);
	end
	enemyAccNum = avatar:getStat("acc_notrack") * enemyAcc;
	avatar:modStat("acc_notrack", -enemyAccNum);

	local view = a:getView();
	view:attachEffectToNode("root", "effects/distortionField_trailing.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/distortionField.plist", durationtime, -40, 20, true, false);
	view:attachEffectToNode("root", "effects/distortionField.plist", durationtime, 40, 20, true, false);
	view:attachEffectToNode("root", "effects/distortionField.plist", durationtime, -80, 40, true, false);
	view:attachEffectToNode("root", "effects/distortionField.plist", durationtime, 80,40, true, false);

	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, "gino_distortion_field");
	aura:setTickParameters(durationtime, durationtime);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		avatar:modStat("acc_notrack", enemyAccNum);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end