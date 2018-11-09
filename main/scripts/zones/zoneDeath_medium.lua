require 'scripts/common'
function onDeath(self)
	if not self then return end
	spawnLoot(self);
	--do death effects
	--local duration = math.random(8.0, 12.0);
	local pos = self:getScenePosition();
	createAttachedEffect(self, "effects/impact_smokeRingBack_small.plist", pos, -1);
	createAttachedEffect(self, "effects/explosion_SmokeLayer.plist", pos, -1);
	createAttachedEffect(self, "effects/explosion_SparkLayer.plist", pos, -1);
	createAttachedEffect(self, "effects/explosion_SparkFireLayer.plist", pos, -1);
	createAttachedEffect(self, "effects/debris.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_boomRising_small.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_boomCore.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_smokeRingFront_small.plist", pos, -1);
end