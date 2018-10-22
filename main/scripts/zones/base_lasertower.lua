require 'scripts/common'
require 'scripts/zones/common'

local weaponLaser = 'weapon_lair_AnnihilatorRay'
local initialSetup = false
local kaiju = nil

function onSpawn(self)
	if not initialSetup then
		doSpawnSetup(self)
	end
end

function onHeartbeat(self)
	if not initialSetup then
		doSpawnSetup(self)
	end
end

function doSpawnSetup(self)
	initialSetup = true
	if isLairScene() then
		return;
	end

	kaiju = getPlayerAvatar()
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
		aura:setScriptCallback(AuraEvent.OnTick, nil)
		return
	end
	
	local targetRange = getWeaponRange(weaponLaser)
	local worldPosition = self:getWorldPosition();
	local newTargets = getTargetsInRadius(worldPosition, targetRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar));
	for t in newTargets:iterator() do
		if canTarget(t) and not isSameEntity(t, kaiju) then
			target = t
			break
		end
	end
	if target then
		setTarget(self, target);
	end
end
