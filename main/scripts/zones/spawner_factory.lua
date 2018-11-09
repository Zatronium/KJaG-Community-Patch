require 'scripts/common'

function doSpawnSetup(self)
	self:getView():setVisible(false);
	enableCollision(self, false);
end

function onSpawn(self) 
	if self then
		doSpawnSetup(self)
	end
end