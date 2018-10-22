require 'scripts/common'
require 'scripts/vehicles/common'

function onHeartbeat(v)
	a = getPlayerAvatar();
	vc = v:getControl();
	
	local distance = getDistance(v, a);
	
	if a:getStat("Health") > 0 then	
		local weaponRange = v:getMinWeaponRange();
		local target = nil;
		if distance < weaponRange * 1.5 then
			target = a;
		end
		
		setTarget(v, target);
	end
end
