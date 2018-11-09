require 'kaiju_shrubby/scripts/shrubby'
local kaiju = nil;
local lastPos = nil;

local distancePatch = 50;

function onSet(a)
	kaiju = a;
	kaiju:addPassiveScript(this);
end

function onAvatarMove(a)
	local worldPos = kaiju:getWorldPosition();
	if not (lastPos) then
		lastPos = worldPos;
	end
	local dist = getDistanceFromPoints(lastPos, worldPos);
	if dist > distancePatch then
		ThornPatch(lastPos);
		lastPos = worldPos;
	end
end