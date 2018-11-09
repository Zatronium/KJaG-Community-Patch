local numberOfDrones = 5;
local delayBetween = 0.5;

local kaiju = nil;
function onUse(a)
	kaiju = a;
	local droneaura = createAura(this, a, "gino_attackdrone");
	droneaura:setTickParameters(delayBetween, 0);
	droneaura:setScriptCallback(AuraEvent.OnTick, "onTick");
	droneaura:setTarget(a);
	startAbilityUse(kaiju, abilityData.name);
	
end

function onTick(aura)
	if not aura then
		return
	end
	pos = kaiju:getWorldPosition();
	local ent = spawnEntity(EntityType.Minion, "unit_DroneAttack", pos);
	setRole(ent, "Player");
	
	numberOfDrones = numberOfDrones - 1;
	if numberOfDrones <= 0 then
		endAbilityUse(kaiju, abilityData.name);
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end