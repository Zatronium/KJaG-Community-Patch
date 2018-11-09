require 'scripts/common'
function onDeath(self)
	if not self then return end
	if not isDayTime() then
		self:setStat("MinOrganic", 0);
		self:setStat("MaxOrganic", 0);
	end
end