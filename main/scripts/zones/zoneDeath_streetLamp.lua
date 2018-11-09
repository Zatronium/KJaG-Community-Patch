require 'scripts/common'
function onDeath(self)
	if not self then return end
	spawnLoot(self);
	--do death effects
	--local duration = math.random(8.0, 12.0);
	local pos = self:getScenePosition();
	createAttachedEffect(self, "effects/impact_sparksBlue_small.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_flash.plist", pos, -1);
	createAttachedEffect(self, "effects/impact_dustCloud_small.plist", pos, -1);
end