local kaiju = nil
local maxHealth = 0;
local healpertick = 20;
local durationtime = 10;
local ticktime = 1;
function onUse(a)
	kaiju = a;
	maxHealth = kaiju:getStat("MaxHealth");
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/repairCycle_core.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", durationtime, 0, 0, true, false);
	local aura = createAura(this, kaiju, "gino_repaircycle");
	aura:setTickParameters(ticktime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
	startAbilityUse(kaiju, abilityData.name);
end

function onTick(aura)
	if not aura then
		return
	end
	local curHealth = kaiju:getStat("Health");
	if hasResources(kaiju, abilityData.name) and curHealth < maxHealth then
		useResources(kaiju, abilityData.name);
		kaiju:gainHealth(healpertick);
	elseif not hasResources(kaiju, abilityData.name) then
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end