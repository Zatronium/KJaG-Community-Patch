require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'
local avatar = nil;

function onSpawn(v)
	avatar = getPlayerAvatar();
	avatar:addMinion(v);
end

function onHeartbeat(v)
	
end

function onDeath(self)
	self:getView():setVisible(false);
	removeEntity(self);
end

