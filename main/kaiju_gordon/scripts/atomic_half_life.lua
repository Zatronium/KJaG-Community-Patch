require 'scripts/avatars/common'

local bonusDamagePercent = 0.10;
local bonusSpeedPercent = 0.2;
local CDRPercent = 0.2;

local thresholdPercent = 0.5;
--duration = 20;
-- this ability has no definate duration

local hpLossPerSecond = -2;

local kaiju = nil;
local bonusSpeed = 0;
local HealthThreshold = 0;

local buffAura = nil;

function onUse(a)
	kaiju = a;
	if not buffAura then --if off then on
		onON(kaiju);
	else -- else if on then off
		onOFF(kaiju);
	end
end

function onON(a)	
	HealthThreshold = a:getStat("MaxHealth") * thresholdPercent;
	if a:getStat("Health") > HealthThreshold then
		
		buffAura = Aura.create(this, a);
		buffAura:setTag("atomic_half_life");
		buffAura:setScriptCallback(AuraEvent.OnTick, "onTick");
		buffAura:setTickParameters(1, 0); 
		buffAura:setTarget(a);

		local view = a:getView();	
		view:attachEffectToNode("root", "effects/halfLifeBack.plist",0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/halfLifeFront.plist",0, 0, 0, true, false);
		
		useResources(a, abilityData.name);
		abilityInUse(a, abilityData.name, true);

		bonusSpeed = a:getBaseStat("Speed") * bonusSpeedPercent;
		a:modStat("Speed", bonusSpeed);
		a:modStat("CoolDownReductionPercent", CDRPercent);
		a:modStat("damage_amplify", bonusDamagePercent);
	end
	playSound("AtomicHalf-Life");
end

function onOFF(a)
	if not buffAura then
		return
	end
	a:modStat("Speed", -bonusSpeed);
	a:modStat("CoolDownReductionPercent", -CDRPercent);
	a:modStat("damage_amplify", -bonusDamagePercent);
	abilityInUse(a, abilityData.name, false);
	startOnlyCooldown(a, abilityData.name);
	
	a:detachAura(buffAura);
	buffAura = nil;
end

function onTick(aura)
	kaiju:modStat("Health", hpLossPerSecond);
	if kaiju:getStat("Health") <  HealthThreshold then
		onOFF(kaiju);
	end
end