require 'scripts/common'
require 'scripts/zones/common'

function onDeath(self)
	if self then
		zoneFireSuppress(self, false);
	end
end
