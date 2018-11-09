local kaiju = nil;
local bonusSpeed = 0.0;
local speedBonusPercent = 1.0;
local durationtime = 10;
function onUse(a)
	kaiju = a;
	
	--modify stats first and store the values to remove EXACLTY the same amount 
	--	(otherwise with %, you run the risk of leaving trace bonuses behind
	
	-- create aura that just calls an update to remove
	boostAura = Aura.create(this, a);
	boostAura:setTag('boost');
	boostAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	boostAura:setTickParameters(durationtime, 0); --updates at time 0 then at time 10
	boostAura:setTarget(a); -- required so aura doesn't autorelease
	
	if not(kaiju:hasStat("acc_notrack")) then
		kaiju:addStat("acc_notrack", 100);
	end
	local acc = kaiju:getStat("acc_notrack") - 100;
	kaiju:setStat("acc_notrack", acc);
	
	a:misdirectMissiles(1.0, false);
	a:setEnablePhysicsBody(false);
	kaiju:setPassive("ignore_proj", 100);
	local view = a:getView();
	view:setKaijuVisible(false);

	startAbilityUse(kaiju, abilityData.name);
	view:attachEffectToNode("root", "effects/pulseVertical_back.plist", 0, 0,0, false, true);
	view:attachEffectToNode("root", "effects/pulseVertical_front.plist", 0, 0,0, true, false);
	
	bonusSpeed = a:getBaseStat("Speed") * speedBonusPercent;
	a:modStat("Speed", bonusSpeed);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationtime then
		kaiju:modStat("Speed", -bonusSpeed);	
		kaiju:setEnablePhysicsBody(true);
		kaiju:removePassive("ignore_proj", 0);
		kaiju:getView():setKaijuVisible(true);
		local acc = kaiju:getStat("acc_notrack") + 100;
		kaiju:setStat("acc_notrack", acc);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end