require 'scripts/common'
require 'scripts/zones/common'

local weaponLaser = 'weapon_lair_AnnihilatorRay'
local initialSetup = false

function onSpawn(self)
	if not initialSetup then
		doSpawnSetup(self)
	end
end

function doSpawnSetup(self)
	initialSetup = true
	if isLairScene() then
		return;
	end

	local interval = 0.5; -- in seconds
	local initialDelay = randomInt(1, 5); -- in seconds, to stagger updates
	local aura = createAura(this, self, 'towerAura');
	aura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	aura:setTickParameters(interval, 0);
	aura:setUpdateDelay(initialDelay);
	aura:setTarget(self); -- required so aura doesn't autorelease
end

function onTick(aura)
	if not aura then
		return
	end
	local self = aura:getOwner()
	if not self then
		aura = nil return
	end
	local weaponRange = getWeaponRange(weaponLaser)
	local worldPosition = self:getWorldPosition();
	
	local targetEnt = getTargetInEntityRadius(self, weaponRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar), TargetFlags(TargetType.Air, TargetType.Land, TargetType.Sea))
	if targetEnt then
		setTarget(self, targetEnt);
	end
end
