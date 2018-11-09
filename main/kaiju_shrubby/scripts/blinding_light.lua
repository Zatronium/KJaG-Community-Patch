require 'scripts/avatars/common'

local kaiju = 0;
local durationtime = 10;
local pointdefenserate = 50;

enemyAcc = 0.2; 
local enemyAccNum = 0;

function onUse(a)
	kaiju = a;
	if not(kaiju:hasStat("PD_Tracking"))then
		kaiju:modStat("PD_Tracking", pointdefenserate);
	else
		kaiju:addStat("PD_Tracking", pointdefenserate);
	end
	
	if kaiju:hasStat("acc_notrack") then
		kaiju:addStat("acc_notrack", 100);
	end
	enemyAccNum = kaiju:getStat("acc_notrack") * enemyAcc;
	kaiju:modStat("acc_notrack", -enemyAccNum);
	
	playSound("shrubby_ability_BlindingLight");
	startAbilityUse(kaiju, abilityData.name);
	playAnimation(kaiju, "ability_cast");
	
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
	if not aura then
		return
	end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:modStat("acc_notrack", enemyAccNum);
		kaiju:modStat("PD_Tracking", -pointdefenserate);
	--	createFloatingNumber(kaiju, 1, 255, 255, 0);
	end
end