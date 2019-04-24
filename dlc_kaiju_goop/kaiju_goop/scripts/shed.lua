require 'kaiju_goop/scripts/goop'

local durationtime = 10;

local thresholdPercent = 0.05;

local kaiju = nil
local healthThresh = 0;

function onSet(a)
	kaiju = a;
	healthThresh = thresholdPercent * kaiju:getStat("MaxHealth");
	kaiju:addPassiveScript(this);
end

function onAvatarDamageTaken(a, n, w)
	if n.y > healthThresh and healthThresh > 0 then
		local kaijuWorldPosition = kaiju:getWorldPosition()
		local step = n.y / healthThresh;
		kaiju = a;
		CreateBlob(kaijuWorldPosition, math.floor(step) * 10, step * 10);
		createEffectInWorld("effects/goopball_splortsplash.plist", kaijuWorldPosition, 0);
		createEffectInWorld("effects/goopball_splort.plist", kaijuWorldPosition, 0);
	end
end