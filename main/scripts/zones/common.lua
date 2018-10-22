
function createUnitSpawner(self, interval, tickCallback)
	local initialDelay = randomInt(5, 15); -- in seconds, to stagger spawning
	local spawnAura = Aura.create(this, self);
	spawnAura:setTag('spawnAura');
	spawnAura:setScriptCallback(AuraEvent.OnTick, tickCallback);
	spawnAura:setTickParameters(interval, 0);
	spawnAura:setUpdateDelay(initialDelay);
	spawnAura:setTarget(self); -- required so aura doesn't autorelease
end

function createUnitHealer(self, interval, tickCallback)
	local initialDelay = randomInt(0, 5); -- in seconds, to stagger updates
	local aura = Aura.create(this, self);
	aura:setTag('healAura');
	aura:setScriptCallback(AuraEvent.OnTick, tickCallback);
	aura:setTickParameters(interval, 0);
	aura:setUpdateDelay(initialDelay);
	aura:setTarget(self); -- required so aura doesn't autorelease
end

function setTarget(self, target)
	local zone = entityToZone(self);
	if zone and zone:isDestroyed() then
		target = nil;
	end
	
	if target and target:getStat("Health") <= 0 then	
		target = nil;
	end

	local turrets = self:getAttachedEntities(EntityType.Turret);		
	for ent in turrets:iterator() do
		turret = entityToTurret(ent);
		turret:setTarget(target);
	end
end

