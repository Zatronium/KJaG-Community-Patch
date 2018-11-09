require 'scripts/common'
function onDeath(self)
	if not self then return end
	spawnLoot(self);
	--do death effects
	--local duration = math.random(8.0, 12.0);
	local pos = self:getScenePosition();
	createAttachedEffect(self, "effects/impactElectric_spike.plist", pos, -1);
	createAttachedEffect(self, "effects/impactElectric_shockwave.plist", pos, -1);
	createAttachedEffect(self, "effects/impactElectric_boom.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_flash.plist", pos, -1);
	createAttachedEffect(self, "effects/impactSparks_blue.plist", pos, -1);
	createAttachedEffect(self, "effects/impactElectric_rising.plist", pos, -1);
	createAttachedEffect(self, "effects/impactElectric_shockwaveDot.plist", pos, -1);
end