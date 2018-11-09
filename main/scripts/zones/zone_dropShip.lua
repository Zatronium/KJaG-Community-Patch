require 'scripts/common'

function doSpawnSetup(self)
	local pos = Point(0, 0);
	zoneAttachEffect2(self, "effects/dropShip.plist",  offsetPosition(pos, 32, 150));
	self:getView():setVisible(false);
end

function onSpawn(self)
	if self then
		doSpawnSetup(self)
	end
end