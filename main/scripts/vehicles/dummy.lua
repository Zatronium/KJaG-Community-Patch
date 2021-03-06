require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

local initialSetup = false

function onHeartbeat(v)
	if not initialSetup then
		doSpawnSetup(v)
	end
end

function doSpawnSetup(v)
	initialSetup = true
	v:enablePhysicsEvents(false, 0);
	v:disablePhysicsBody();
end