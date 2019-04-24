--Active
require 'scripts/common'

-- control vars
local bonusSpeedPercent = 0.25;
local durationtime = 30;

local bonusSpeed = 0.0;
local kaiju = nil
local scriptAura = 0;

function onUse(a)
	kaiju = a;
	-- create aura that just calls an update to remove
	scriptAura = Aura.create(this, a);
	scriptAura:setTag('goop_harden');
	scriptAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	scriptAura:setTickParameters(durationtime, 0); --updates at time 0 then at time 20
	scriptAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("root", "effects/goop_cloudybits.plist", durationtime, 0, 50, true, false);
	--view:attachEffectToNode("foot_02", "effects/booster.plist", durationtime, 0, 0, false, true);
	
	startAbilityUse(kaiju, abilityData.name);
	
	bonusSpeed = a:getBaseStat("Speed") * bonusSpeedPercent;
	a:modStat("Speed", bonusSpeed);
	
	kaiju:setInvulnerableTime(durationtime);
	a:setPassive("attack_disabled", 1);
	
	playSound("goop_ability_AtomicDiffusion");
end

function onInterrupt()
	kaiju = entityToAvatar(scriptAura:getOwner());
	endAbilityUse(kaiju, abilityData.name);
	kaiju:removePassive("attack_disabled", 0);
	kaiju:modStat("Speed", -bonusSpeed);
	scriptAura:getOwner():detachAura(scriptAura);
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		aura:removePassive("attack_disabled", 0);
		aura:modStat("Speed", -bonusSpeed);
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			aura:detachAura(aura);
		end
	end
end