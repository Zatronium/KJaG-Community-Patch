require 'scripts/common'
require 'scripts/zones/common'

local weaponAA 		= 'weapon_MissileGuidedAA'
local weaponGround 	= 'weapon_MissileGuidedAAGround'
local initialSetup	= false
local kaiju 		= nil

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
	local self = aura:getOwner();
	if not self then
		aura = nil return
	end
	
	local weaponRange = getWeaponRange(weaponAA)
	local worldPosition = self:getWorldPosition()
	
	local targetEnt = getTargetInEntityRadius(self, weaponRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar), TargetFlags(TargetType.Air))
	if targetEnt then
		fireWeaponWithTarget(self, targetEnt, weaponAA, 'onHit')
		return
	end
	
	weaponRange = getWeaponRange(weaponGround)
	targetEnt = getTargetInEntityRadius(self, weaponRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar), TargetFlags(TargetType.Land, TargetType.Sea))
	if targetEnt then
		fireWeaponWithTarget(self, targetEnt, weaponGround, 'onHit')
	end
	
	if targetEnt then
		setTarget(self, targetEnt);
	end
end

function onHit(proj)
	local scenePos = proj:getView():getPosition();
	local weapon = proj:getWeapon();
	playSound("impact_missile");
	createImpactEffect(weapon, scenePos);
end
