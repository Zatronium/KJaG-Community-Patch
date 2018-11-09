require 'scripts/common'


function doSpawnSetup(self)
	local pos = self:getScenePosition();
	zoneAttachEffect(self, "effects/volcanoSmoke_upperRing.plist",  offsetPosition(pos, 70, 850));
	zoneAttachEffect(self, "effects/volcanoSmoke.plist",  offsetPosition(pos, 50, 730));
	zoneAttachEffect(self, "effects/volcanoSparks.plist",  offsetPosition(pos, 50, 750));
	zoneAttachEffect(self, "effects/volcanoSmoke_lowerRing.plist",  offsetPosition(pos, 70, 850));
end

function onSpawn(self)
	if self then
		doSpawnSetup(self)
	end
end