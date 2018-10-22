require 'scripts/common'

local bonusSpeed = 0.0;
local bonusSpeedpct = 0.25;
local enemyAcc = 0.75;
local enemyAccNum = 0;
local duration = 15;
local avatar = 0;
function onUse(a)
	avatar = a;
	
	--modify stats first and store the values to remove EXACLTY the same amount 
	--	(otherwise with %, you run the risk of leaving trace bonuses behind
	
	-- create aura that just calls an update to remove
	boostAura = Aura.create(this, a);
	boostAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	boostAura:setTickParameters(duration, 0); --updates at time 0 then at time 10
	boostAura:setTarget(a); -- required so aura doesn't autorelease
	
	startAbilityUse(avatar, abilityData.name);

	local view = a:getView();
	view:attachEffectToNode("root", "effects/predictiveAlgo_back.plist", duration, 0,0, false, true);
	view:attachEffectToNode("root", "effects/predictiveAlgo_front.plist", duration, 0,0, true, false);
	
	--since this is actually a percent, it will be like this
	if not a:hasStat("acc_notrack")then
		a:addStat("acc_notrack", 100);
	end
	enemyAccNum = a:getStat("acc_notrack") * enemyAcc;
	a:modStat("acc_notrack", -enemyAccNum);
	
	--store bonus total (NOTE: may need a "getBaseStat" and go off of that, but minor concern)
	bonusSpeed = a:getBaseStat("Speed") * bonusSpeedpct;
	a:modStat("Speed", -bonusSpeed);
end

function onTick(aura)
	if aura:getElapsed() >= duration then
		local a = aura:getOwner();
		a:modStat("Speed", bonusSpeed);
		a:modStat("acc_notrack", enemyAccNum);
		endAbilityUse(avatar, abilityData.name);
		a:detachAura(aura);
	end
end