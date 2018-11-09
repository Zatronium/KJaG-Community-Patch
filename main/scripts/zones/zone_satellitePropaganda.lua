require 'scripts/common'

function doSpawnSetup(self)
	local pos = Point(0, 0);
	zoneAttachEffect2(self, "effects/satellitePropaganda.plist",  offsetPosition(pos, 110, 150));
end


function onSpawn(self)
	if self then
		doSpawnSetup(self)
	end
end