require 'scripts/common'

function onTick(aura)
	if not aura then return end
	local self = aura:getOwner()
	if not self then
		aura = nil return;
	end
	applyDamageWithWeapon(nil, self, aura:getTag());
end
