require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

local roamrange = 300;
local pathchangedist = 50;
local dest = nil;
local initialSetup = false

function onSpawn(v)
	if not initialSetup then
		doSpawnSetup()
	end
end

function doSpawnSetup(v)
	initialSetup = true
	v:enablePhysicsEvents(false, 0);
	v:disablePhysicsBody();
end

function onHeartbeat(v)
	if not initialSetup then
		doSpawnSetup(v)
	end
	local pos = v:getWorldPosition();
	if not dest or getDistanceFromPoints(pos, dest) < pathchangedist then
		dest = offsetRandomDirection(pos, -roamrange, roamrange);
		local vc = v:getControl();
		vc:directMove(dest);
	end
end

function onDeath(self)
	removeEntity(self);
end

