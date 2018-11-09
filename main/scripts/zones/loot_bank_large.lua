require 'scripts/common'
function onDeath(self)
	if not self then return end
	local odds = 30;
	local roll = randomInt(1, 100);
	if roll <= odds then
		local choice = randomInt(1, 3);
		if choice == 1 then spawnLootResource(self, "money"  ,150000 ,150000) end;
		if choice == 2 then spawnLootResource(self, "know"   ,100    ,100) end;
		if choice == 3 then spawnLootResource(self, "purple" ,3      ,6) end;
	end
end