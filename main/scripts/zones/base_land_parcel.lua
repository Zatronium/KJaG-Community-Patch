require 'scripts/common'

function doSpawnSetup(self)
	if self and isLairAttack() then
		enableCollision(self, false);
	end
end

function onSpawn(self)
	doSpawnSetup(self)
end