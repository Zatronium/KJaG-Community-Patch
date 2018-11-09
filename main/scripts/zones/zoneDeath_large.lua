require 'scripts/common'
function onDeath(self)
	if not self then return end
	spawnLoot(self);
	--do death effects
	--local duration = math.random(8.0, 12.0);
	local pos = self:getScenePosition();
	createAttachedEffect(self, "effects/impact_smokeRingBack_small.plist", pos, -1);
	createAttachedEffect(self, "effects/collapseSmoke_med.plist", pos, -1);
	createAttachedEffect(self, "effects/explosion_SmokeLayer.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_shockwave.plist", pos, -1);
	createAttachedEffect(self, "effects/explosion_SparkFireLayer.plist", pos, -1);
	createAttachedEffect(self, "effects/debris.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_BoomRisingLrg.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_boomCore.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_dustCloud_medLong.plist", pos, -1);
	createAttachedEffect(self, "effects/debris_tall.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_dustCloud_med.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_smokeRingFront_med.plist", pos, -1);
end