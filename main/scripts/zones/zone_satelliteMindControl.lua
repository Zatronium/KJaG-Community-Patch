require 'scripts/common'

function doSpawnSetup(self)
	local pos = Point(0, 0);
	zoneAttachEffect2(self, "effects/satelliteMindControl.plist",  offsetPosition(pos, 64, 150));
end

function onSpawn(self)
	if self then
		doSpawnSetup(self)
	end
end