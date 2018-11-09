require 'scripts/common'

function onDeath(self)
	if not self then return end
	spawnLoot(self);
	--do death effects
	local duration = math.random(8.0, 12.0);
	local size = scaleSize(self:getView():getContentSize(), 1.0, 0.5);
	local pos = offsetPosition(self:getView():getPosition(), 0.0, 40.0 - size.height);
	createAttachedEffect(self, "effects/explosion_BoomLayer.plist", pos, -1);
	createAttachedEffect(self, "effects/explosion_SmokeLayer.plist", pos, -1);
	createAttachedEffect(self, "effects/explosion_SparkLayer.plist", pos, -1);
	createAttachedEffect(self, "effects/explosion_SparkFireLayer.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_boomRising.plist", pos, -1);
	createAttachedEffect(self, "effects/shippingContainer.plist", pos, -1);
	
end