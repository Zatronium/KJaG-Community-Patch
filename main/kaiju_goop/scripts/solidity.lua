--Active
require 'scripts/common'

-- control vars
local bonusSpeedPercent = -0.8;
local bonusArmor = 10;
local durationtime = 30;

--
local bonusSpeed = 0.0;
local kaiju = nil
local scriptAura = nil

function onUse(a)
	kaiju = a;
	hasUpdated = false;
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
	kaiju = entityToAvatar(scriptAura:getOwner());
	endAbilityUse(kaiju, abilityData.name);
	kaiju:modStat("Speed", -bonusSpeed);
	kaiju:modStat("Armor", -bonusArmor);
	scriptAura:getOwner():detachAura(scriptAura);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		kaiju = entityToAvatar(aura:getOwner());
		endAbilityUse(kaiju, abilityData.name);
		local a = aura:getOwner();
		a:modStat("Speed", -bonusSpeed);
		a:modStat("Armor", -bonusArmor);
		a:detachAura(aura);
	end
end