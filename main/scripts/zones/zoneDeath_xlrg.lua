require 'scripts/common'
function onDeath(self)
	if not self then return end
	spawnLoot(self);
	--do death effects
	local duration = math.random(8.0, 12.0);
	local pos = self:getScenePosition();
	createAttachedEffect(self, "effects/fireGlowLayer.plist", pos, duration * 3.0);
	createAttachedEffect(self, "effects/smokeLayer.plist", pos, duration * 3.0);
	createAttachedEffect(self, "effects/impact_smokeCloudRising.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_boomRisingLrg.plist", pos, -1);
	createAttachedEffect(self, "effects/collapseSmokeRing_large.plist", pos, -1);
	createAttachedEffect(self, "effects/collapseSmoke_large.plist", pos, -1);	
end