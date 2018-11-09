require 'scripts/common'
function onDeath(self)
	if not self then return end
	spawnLoot(self);
	--do death effects
	--local duration = math.random(8.0, 12.0);
	local pos = self:getScenePosition();
	createAttachedEffect(self, "effects/impact_fireRingBack_large.plist", pos, -1);
	createAttachedEffect(self, "effects/collapseSmokeDark_large.plist", pos, -1);
	--createAttachedEffect(self, "effects/impact_BoomRisingXlrg.plist", pos, -1);
	--createAttachedEffect(self, "effects/impact_fireCloud_linger.plist", pos, -1);
	--createAttachedEffect(self, "effects/impact_dustCloud_med.plist", pos, -1);
	--createAttachedEffect(self, "effects/impact_boomCore_xlrg.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_fireRingFront_large.plist", pos, -1);
	--createAttachedEffect(self, "effects/impact_boomXlrg.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_mushCloud_medium.plist", pos, -1);
end