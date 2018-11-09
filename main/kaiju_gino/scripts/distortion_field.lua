require 'scripts/common'

local kaiju = nil
local enemyAcc = 0.5;
local enemyAccNum = 0;
local durationtime = 20;
local hasUpdated = false;
function onUse(a)
	kaiju = a;
	if not(kaiju:hasStat("acc_notrack")) then
		kaiju:addStat("acc_notrack", 100);
	end
	enemyAccNum = kaiju:getStat("acc_notrack") * enemyAcc;
	kaiju:modStat("acc_notrack", -enemyAccNum);

	local view = a:getView();
	view:attachEffectToNode("root", "effects/distortionField_trailing.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/distortionField.plist", durationtime, -40, 20, true, false);
	view:attachEffectToNode("root", "effects/distortionField.plist", durationtime, 40, 20, true, false);
	view:attachEffectToNode("root", "effects/distortionField.plist", durationtime, -80, 40, true, false);
	view:attachEffectToNode("root", "effects/distortionField.plist", durationtime, 80,40, true, false);

	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, "gino_distortion_field");
	aura:setTickParameters(durationtime, durationtime);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationtime then
		kaiju:modStat("acc_notrack", enemyAccNum);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end