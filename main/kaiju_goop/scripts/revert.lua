--Active
require 'scripts/common'

function onUse(a)
	local reAura = a:getAura("revert");
	if reAura ~= nil then
		reAura:triggerUpdate(999);
	end
end