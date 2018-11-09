require 'scripts/common'

function doSpawnSetup(self)
	self:getView():setVisible(false);
	self:setSpawnable(true);
	enableCollision(self, false);
end

function onSpawn(self) 
	if self then
		doSpawnSetup(self)
	end
end