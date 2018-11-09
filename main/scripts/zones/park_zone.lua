require 'scripts/common'

function onDeath(self)
	if not self then return end
	spawnLoot(self);
	--do death effects
	local duration = math.random(8.0, 12.0);
	local pos = self:getScenePosition();
	createAttachedEffect(self, "effects/explosion_SmokeLayer.plist", pos, -1);
	createAttachedEffect(self, "effects/crows.plist", pos, -1);
end