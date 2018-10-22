local avatar = nil;
local bonusSpeed = 0.0;
local speedBonusPercent = 1.0;
local durationtime = 10;
function onUse(a)
	avatar = a;
	hasUpdated = false;
	
	--modify stats first and store the values to remove EXACLTY the same amount 
	--	(otherwise with %, you run the risk of leaving trace bonuses behind
	
	-- create aura that just calls an update to remove
	boostAura = Aura.create(this, a);
	boostAura:setTag('boost');
	boostAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	boostAura:setTickParameters(durationtime, 0); --updates at time 0 then at time 10
	boostAura:setTarget(a); -- required so aura doesn't autorelease
	
	if not avatar:hasStat("acc_notrack") then
		avatar:addStat("acc_notrack", 100);
	end
	local acc = avatar:getStat("acc_notrack");
	acc = acc - 100;
	avatar:setStat("acc_notrack", acc);
	
	a:misdirectMissiles(1.0, false);
	a:setEnablePhysicsBody(false);
	avatar:setPassive("ignore_proj", 100);
	a:getView():setKaijuVisible(false);

	startAbilityUse(avatar, abilityData.name);
	local view = a:getView();
	view:attachEffectToNode("root", "effects/pulseVertical_back.plist", 0, 0,0, false, true);
	view:attachEffectToNode("root", "effects/pulseVertical_front.plist", 0, 0,0, true, false);
	
	--store bonus total (NOTE: may need a "getBaseStat" and go off of that, but minor concern)
	bonusSpeed = a:getBaseStat("Speed") * speedBonusPercent;
	a:modStat("Speed", bonusSpeed);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		avatar:modStat("Speed", -bonusSpeed);	
		avatar:setEnablePhysicsBody(true);
		avatar:removePassive("ignore_proj", 0);
		avatar:getView():setKaijuVisible(true);
		local acc = avatar:getStat("acc_notrack");
		acc = acc + 100;
		avatar:setStat("acc_notrack", acc);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end