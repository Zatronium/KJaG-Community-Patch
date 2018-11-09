require 'scripts/common'


function onSpawn(self)
	if self then
		local pos = self:getScenePosition();
		zoneAttachEffect(self, "effects/zoneEffect_hero2X2.plist", pos);
	end
end