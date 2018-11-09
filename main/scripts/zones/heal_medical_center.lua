require 'scripts/common'
require 'scripts/zones/common'

function doSpawnSetup(self)
	local interval = 1; -- in seconds
	createUnitHealer(self, interval, "onTick");

	local pos = self:getScenePosition();
	zoneAttachEffectBottom(self, "effects/hospital_areaMed.plist",  offsetPosition(pos, 40, 20));
end

function onSpawn(self) 
	if self then
		doSpawnSetup(self)
	end
end

function onTick(aura)
	if not aura then
		return
	end
	local self = aura:getOwner();
	if not self then
		aura = nil return
	end
	-- Special: All adjacent defence ground units are healed one point every second 
	local withinTiles = 4;
	local healAmount = 3;
	zoneHealGroundUnits(self, withinTiles, healAmount);
end