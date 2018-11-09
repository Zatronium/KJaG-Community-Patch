require 'scripts/common'

function doSpawnSetup(self)
	local pos = self:getScenePosition();
	zoneAttachEffect(self, "effects/light_core_small.plist",  offsetPosition(pos, -80, 70));
	zoneAttachEffect(self, "effects/light_coreSolid_small.plist",  offsetPosition(pos, -80,70));
	zoneAttachEffect(self, "effects/light_redFlare_medPulse.plist", offsetPosition(pos, -80,70));
	zoneAttachEffect(self, "effects/light_core_small.plist",  offsetPosition(pos, -158, 72));
	zoneAttachEffect(self, "effects/light_coreSolid_small.plist",  offsetPosition(pos, -158,72));
	zoneAttachEffect(self, "effects/light_redFlare_medPulse.plist", offsetPosition(pos, -158, 72));
	zoneAttachEffect(self, "effects/light_core_small.plist",  offsetPosition(pos, 45, 5));
	zoneAttachEffect(self, "effects/light_coreSolid_small.plist",  offsetPosition(pos, 45,5));
	zoneAttachEffect(self, "effects/light_redFlare_medPulse.plist", offsetPosition(pos, 45,5));
end

function onSpawn(self)
	if self then
		doSpawnSetup(self)
	end
end