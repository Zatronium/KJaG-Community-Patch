require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

local initialSetup = false
local setupFinished = false

function doSpawnSetup(v)
	initialSetup = true
	getPlayerAvatar():addMinion(v);
end

function onHeartbeat(v)
	if not initialSetup then
		doSpawnSetup(v)
	end
end

function onDeath(self)
	self:getView():setVisible(false);
	removeEntity(self);
end

