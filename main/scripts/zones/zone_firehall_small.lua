require 'scripts/common'

function doSpawnSetup(self)
	local pos = self:getScenePosition();
	zoneAttachEffect(self, "effects/light_core_small.plist",  offsetPosition(pos, -52, 40));
	zoneAttachEffect(self, "effects/light_coreSolid_small.plist",  offsetPosition(pos, -52, 40));
	zoneAttachEffect(self, "effects/light_redFlare_medPulse.plist", offsetPosition(pos, -52, 40));
end

function onSpawn(self)
	if self then
		doSpawnSetup(self)
	end
end