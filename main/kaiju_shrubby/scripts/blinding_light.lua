require 'scripts/avatars/common'

local avatar = 0;
local durationtime = 10;
local pointdefenserate = 50;

local enemyAcc = 0.2; 
local enemyAccNum = 0;

function onUse(a)
	avatar = a;
	if not avatar:hasStat("PD_Tracking") then
		avatar:modStat("PD_Tracking", pointdefenserate);
	else
		avatar:addStat("PD_Tracking", pointdefenserate);
	end
	
	if avatar:hasStat("acc_notrack") then
		avatar:addStat("acc_notrack", 100);
	end
	enemyAccNum = avatar:getStat("acc_notrack") * enemyAcc;
	avatar:modStat("acc_notrack", -enemyAccNum);
	
	playSound("shrubby_ability_BlindingLight");
	startAbilityUse(avatar, abilityData.name);
	playAnimation(avatar, "ability_cast");
	
	local aura = Aura.create(this, a);
	aura:setTag('shrubby_blinding_light');
	aura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	aura:setTickParameters(durationtime, 0);
	aura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("root", "effects/blindingLight_flashFade.plist", 0, 0, 200, true, false);
	view:attachEffectToNode("root", "effects/blindingLight_flash.plist", 0, 0, 200, true, false);
	view:attachEffectToNode("root", "effects/blindingLight_waveBack.plist", 0, 0, 130, false, true);
	view:attachEffectToNode("root", "effects/blindingLight_waveFront.plist", 0, 0, 130, true, false);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		endAbilityUse(avatar, abilityData.name);
		avatar:modStat("acc_notrack", enemyAccNum);
		avatar:modStat("PD_Tracking", -pointdefenserate);
	--	createFloatingNumber(avatar, 1, 255, 255, 0);
	end
end