require 'scripts/common'
function onDeath(self)
	if not self then return end
	spawnLoot(self);
	--do death effects
	--local duration = math.random(8.0, 12.0);
	local pos = self:getScenePosition();
	createAttachedEffect(self, "effects/impact_fireRingBack_med.plist", pos, -1);
	createAttachedEffect(self, "effects/collapseSmoke_med.plist", pos, -1);
	createAttachedEffect(self, "effects/explosion_SmokeLayer.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_shockwave.plist", pos, -1);
	createAttachedEffect(self, "effects/explosion_SparkFireLayer.plist", pos, -1);
	createAttachedEffect(self, "effects/debris.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_BoomRisingLrg.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_fireCloud_linger.plist", pos, -1);
	createAttachedEffect(self, "effects/debris_tall.plist", pos, -1);
	--flaming debris, not up to snuff yet
	--createAttachedEffect(self, "effects/fireTrail_small_45.plist", pos, -1);
	--createAttachedEffect(self, "effects/glowTrail_small_45.plist", pos, -1);
	--createAttachedEffect(self, "effects/debrisSingle_45.plist", pos, -1);
	--createAttachedEffect(self, "effects/fireTrail_small_130.plist", pos, -1);
	--createAttachedEffect(self, "effects/glowTrail_small_130.plist", pos, -1);
	--createAttachedEffect(self, "effects/debrisSingle_130.plist", pos, -1);

	createAttachedEffect(self, "effects/impact_dustCloud_med.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_boomCore_large.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_fireRingFront_med.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_boomLarge.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_mushCloud_small.plist", pos, -1);
end