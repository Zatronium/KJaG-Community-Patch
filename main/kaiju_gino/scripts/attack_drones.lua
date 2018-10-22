local numberOfDrones = 5;
local delayBetween = 0.5;
local droneLifetime = 30;

local avatar = nil;
local hasUpdated = false;
function onUse(a)
	avatar = a;
	local droneaura = createAura(this, a, "gino_attackdrone");
	droneaura:setTickParameters(delayBetween, 0);
	droneaura:setScriptCallback(AuraEvent.OnTick, "onTick");
	droneaura:setTarget(a);
	startAbilityUse(avatar, abilityData.name);
	
end

function onTick(aura)
	pos = avatar:getWorldPosition();
	local ent = spawnEntity(EntityType.Minion, "unit_DroneAttack", pos);
	setRole(ent, "Player");
	
	numberOfDrones = numberOfDrones - 1;
	if numberOfDrones <= 0 then
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end