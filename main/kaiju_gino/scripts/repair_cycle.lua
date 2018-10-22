local avatar = 0;
local maxHealth = 0;
local healpertick = 20;
local durationtime = 10;
local ticktime = 1;
function onUse(a)
	avatar = a;
	maxHealth = avatar:getStat("MaxHealth");
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/repairCycle_core.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", durationtime, 0, 0, true, false);
	local aura = createAura(this, avatar, "gino_repaircycle");
	aura:setTickParameters(ticktime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
	startAbilityUse(avatar, abilityData.name);
end

function onTick(aura)
	local curHealth = avatar:getStat("Health");
	if hasResources(avatar, abilityData.name) and curHealth < maxHealth then
		useResources(avatar, abilityData.name);
		avatar:gainHealth(healpertick);
	elseif not hasResources(avatar, abilityData.name) then
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end