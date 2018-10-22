require 'kaiju_shrubby/scripts/shrubby'
local avatar = nil;
local lastPos = nil;

local distancePatch = 50;

function onSet(a)
	avatar = a;
	avatar:addPassiveScript(this);
end

function onAvatarMove(a)
	local worldPos = avatar:getWorldPosition();
	if not lastPos then
		lastPos = worldPos;
	end
	local dist = getDistanceFromPoints(lastPos, worldPos);
	if dist > distancePatch then
		ThornPatch(lastPos);
		lastPos = worldPos;
	end
end