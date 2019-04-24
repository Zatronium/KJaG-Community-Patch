--Active
require 'scripts/common'

-- control vars
local bonusSpeedPercent = -0.75;
local durationtime = 30;

--
local bonusSpeed = 0.0;
local kaiju = nil
local scriptAura = 0;

local healAmount = 0;

local clone = nil;
local cloneSpeed = 0;

function onUse(a)
	kaiju = a;
	hasUpdated = false;
	-- create aura that just calls an update to remove
	scriptAura = Aura.create(this, a);
	scriptAura:setTag('goop_repair_a_goop');
	scriptAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	scriptAura:setTickParameters(durationtime, 0);
	scriptAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("root", "effects/goop_regen.plist", durationtime, 0, 50, true, false);
	view:attachEffectToNode("root", "effects/goop_repair.plist", durationtime, 0, 50, true, false);
	
	startAbilityUse(kaiju, abilityData.name);
	
	healAmount = kaiju:getStat("MaxHealth") - kaiju:getStat("Health");
	
	bonusSpeed = a:getBaseStat("Speed") * bonusSpeedPercent;
	a:modStat("Speed", bonusSpeed);
		
	playSound("goop_ability_RepairAGoop");
end

function onInterrupt()
	clone = getPlayerAvatar()
	scriptAura:enableUpdate(true);
	if clone then
		cloneSpeed = clone:getBaseStat("Speed") * bonusSpeedPercent;
		clone:modStat("Speed", cloneSpeed);
	end
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		clone = getPlayerAvatar()
		if clone and not isSameEntity(clone, kaiju) then
			clone:modStat("Speed", -bonusSpeed);
			clone:gainHealth(healAmount);
		end
		kaiju:modStat("Speed", -bonusSpeed);
		kaiju:gainHealth(healAmount);
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			owner:detachAura(aura);
		end
	end
end