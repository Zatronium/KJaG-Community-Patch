require 'scripts/common'
function onDeath(self)
	local odds = 20;
	local roll = randomInt(1, 100);
	if roll <= odds then
		local choice = randomInt(1, 3);
		if choice == 1 then spawnLootResource(self, "money"	,80000	,80000) end;
		if choice == 2 then spawnLootResource(self, "know"	,80		,80) end;
		if choice == 3 then spawnLootResource(self, "purple"	,2		,4) end;
	end
end