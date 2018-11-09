require 'scripts/common'
function onDeath(self)
	if self then
		zoneApplyFire(self, 2);
	end
end
