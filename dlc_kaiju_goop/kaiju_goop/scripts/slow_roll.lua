--Active
require 'scripts/common'

-- control vars
local bonusSpeedPercent = -0.5;
local healPerTick = 5;
local durationtime = 45;
local ticktime = 1;

--
local bonusSpeed = 0.0;
local kaiju = nil
local scriptAura = 0;

function onUse(a)
	kaiju = a;
	-- create aura that just calls an update to remove
	onActive(kaiju, durationtime);
	
	startAbilityUse(kaiju, abilityData.name);
	
	playSound("goop_ability_SlowRoll");
end

function onActive(a, duration)
	durationtime = duration;
	scriptAura = Aura.create(this, a);
	scriptAura:setTag('goop_slow_roll');
	scriptAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	scriptAura:setTickParameters(ticktime, 0); --updates at time 0 then at time 20
	scriptAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("root", "effects/goop_cloudybits.plist", duration, 0, 50, true, false);
	view:attachEffectToNode("root", "effects/goop_corrosive.plist", duration, 0, 0, false, true);
	
	bonusSpeed = a:getBaseStat("Speed") * bonusSpeedPercent;
	a:modStat("Speed", bonusSpeed);
end

function onInterrupt()
	kaiju:modStat("Speed", -bonusSpeed);
	endAbilityUse(kaiju, abilityData.name);
	
	scriptAura:getOwner():detachAura(scriptAura);
end

function onTick(aura)
	if not aura then return end
	local owner = aura:getOwner()
	if not owner then
		aura = nil return
	end
	local av = entityToAvatar(owner);
	if av then
		av:gainHealth(healPerTick);
		if durationtime > 0 and aura:getElapsed() >= durationtime then
			endAbilityUse(av, abilityData.name);
			owner:modStat("Speed", -bonusSpeed);
			owner:detachAura(aura);
		end
	end
end