require 'scripts/common'

function doSpawnSetup(self)
	local pos = self:getScenePosition();
	zoneAttachEffect(self, "effects/light_core_small.plist",  offsetPosition(pos, -23, 118));
	zoneAttachEffect(self, "effects/light_coreSolid_small.plist",  offsetPosition(pos,-23,118));
	zoneAttachEffect(self, "effects/light_blueFlare_medPulse.plist", offsetPosition(pos,-23,118));
	zoneAttachEffect(self, "effects/light_core_small.plist",  offsetPosition(pos, 10, 40));
	zoneAttachEffect(self, "effects/light_coreSolid_small.plist",  offsetPosition(pos,10,40));
	zoneAttachEffect(self, "effects/light_blueFlare_medPulse.plist", offsetPosition(pos,10,40));
	zoneAttachEffect(self, "effects/light_core_small.plist",  offsetPosition(pos, 68, 65));
	zoneAttachEffect(self, "effects/light_coreSolid_small.plist",  offsetPosition(pos,68,65));
	zoneAttachEffect(self, "effects/light_blueFlare_medPulse.plist", offsetPosition(pos,68,65));
	zoneAttachEffect(self, "effects/light_core_small.plist",  offsetPosition(pos, -68, 75));
	zoneAttachEffect(self, "effects/light_coreSolid_small.plist",  offsetPosition(pos,-68,75));
	zoneAttachEffect(self, "effects/light_blueFlare_medPulse.plist", offsetPosition(pos,-68,75));
end

function onSpawn(self)
	if self then
		doSpawnSetup(self)
	end
end