--Active
require 'scripts/common'

-- control vars
local bonusSpeedPercent = -0.5;
local bonusArmor = 5;
local durationtime = 30;

--
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
	view:attachEffectToNode("root", "effects/harden.plist", 0, 0, 50, true, false);
	view:attachEffectToNode("root", "effects/harden_shield.plist", 0, 0, 50, true, false);
	
	view:attachEffectToNode("root", "effects/harden_sparkles.plist", durationtime, 0, 50, true, false);
	
	startAbilityUse(kaiju, abilityData.name);
	
	a:modStat("Armor", bonusArmor);
	bonusSpeed = a:getBaseStat("Speed") * bonusSpeedPercent;
	a:modStat("Speed", bonusSpeed);
	
	playSound("goop_ability_Harden");
end

function onInterrupt()
	endAbilityUse(kaiju, abilityData.name);
	kaiju:modStat("Speed", -bonusSpeed);
	kaiju:modStat("Armor", -bonusArmor);
	
	kaiju:detachAura(scriptAura);
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:modStat("Speed", -bonusSpeed);
		kaiju:modStat("Armor", -bonusArmor);
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			kaiju:detachAura(aura);
		end
	end
end