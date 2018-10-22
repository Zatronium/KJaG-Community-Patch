--This tech sends extra power into the Kaiju's systems, increasing speed and recharging of attacks.
--+50% speed and +20% cooldown reduction for 10s
--Active
require 'scripts/common'

local bonusSpeed = 0.0;
local coolDownReductionPercent = 0.2;
local durationtime = 20;

local avatar = 0;
function onUse(a)
	avatar = a;
	--modify stats first and store the values to remove EXACLTY the same amount 
	--	(otherwise with %, you run the risk of leaving trace bonuses behind
	
	-- create aura that just calls an update to remove
	boostAura = Aura.create(this, a);
	boostAura:setTag('boost');
	boostAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	boostAura:setTickParameters(durationtime, 0); --updates at time 0 then at time 20
	boostAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("foot_01", "effects/booster.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("foot_02", "effects/booster.plist", durationtime, 0, 0, false, true);
	
	startAbilityUse(avatar, abilityData.name);
	
	--since this is actually a percent, it will be like this
	if a:hasStat("CoolDownReductionPercent") then
		a:modStat("CoolDownReductionPercent", coolDownReductionPercent);
	else
		a:addStat("CoolDownReductionPercent", coolDownReductionPercent);
	end
	--store bonus total (NOTE: may need a "getBaseStat" and go off of that, but minor concern)
	bonusSpeed = a:getBaseStat("Speed") * 0.3;
	a:modStat("Speed", bonusSpeed);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		local a = aura:getOwner();
		a:modStat("Speed", -bonusSpeed);
		a:modStat("CoolDownReductionPercent", -coolDownReductionPercent);
		endAbilityUse(avatar, abilityData.name);
		a:detachAura(aura);
	end
end