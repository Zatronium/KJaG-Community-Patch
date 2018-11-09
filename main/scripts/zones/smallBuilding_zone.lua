require 'scripts/common'

function onStatChanged(self, stat, prev, val)
	if not self then return end
	if stat == 'Health' and prev == self:getStat('MaxHealth') then
		local randCivChance = 30; -- may need to be a stat?
		if math.random(1, 100) < randCivChance then
			spawnCivilians(self:getWorldPosition());
		end
	end
end