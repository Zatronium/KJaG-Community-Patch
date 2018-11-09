require 'scripts/common'
function onDeath(self)
	if self then
		zoneApplyFire(self, 1);
	end
end
