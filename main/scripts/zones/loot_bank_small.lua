require 'scripts/common'
function onDeath(self)
	local odds = 10;
	local roll = randomInt(1, 100);
	if roll <= odds then
		local choice = randomInt(1, 3);
		if choice == 1 then spawnLootResource(self, "money", 50000, 50000) end;
		if choice == 2 then spawnLootResource(self, "know",  50,  50) end;
		if choice == 3 then spawnLootResource(self, "purple", 1, 1) end;
	end
end