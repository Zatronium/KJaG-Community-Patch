require 'scripts/common'
require 'scripts/zones/common'

function doSpawnSetup(self)
	if not self then return end
	zoneFireSuppress(self, true);

	local sizeClass = self:getStat("FireSuppressClass");

	local effectName = "effects/firehall_areaSml.plist";
	if sizeClass == 1 then effectName = "effects/firehall_areaSml.plist";
	elseif sizeClass == 2 then effectName = "effects/firehall_areaMed.plist";
	elseif sizeClass >= 3 then effectName = "effects/firehall_areaLrg.plist";
	end

	local pos = self:getScenePosition();
	zoneAttachEffectBottom(self, effectName,  pos);
end

function onSpawn(self) 
	doSpawnSetup(self)
end
