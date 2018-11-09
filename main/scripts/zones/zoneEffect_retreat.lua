require 'scripts/common'

function doSpawnSetup(self)
	local pos = self:getScenePosition();
	zoneAttachEffect(self, "effects/zone_retreat.plist", pos);
	self:getView():setVisible(false);
end

function onSpawn(self) 
	if self then
		doSpawnSetup(self)
	end
end