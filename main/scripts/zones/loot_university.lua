require 'scripts/common'
function onDeath(self)
	local odds = 20;
	local roll = randomInt(1, 100);
	if roll <= odds then
		spawnLootResource(self, "purple", 3, 5);
	end
end