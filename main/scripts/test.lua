require 'scripts/common'

---- Get all zones in radius around kaiju.
--flags = EntityFlags(EntityType.Zone);
--a = getPlayerAvatar();
--targets = getTargetsInRadius(a:getWorldPosition(), 250, flags);
--for t in targets:iterator() do
--	applyDamage(a, t, 100);
--end

function onKeyX()
	--                    L						 DL						D					DR					R					 UR					U					UL
--	_forceBarrelOffsets("(-25,10,0)(-15,3,0) (0,0,0)(15,3,0) (25,10,0)(18,20,0) (0,25,0)(-18,20,0)");
	_forceBarrelOffsets("(-14,-16,0)(-12,-20,0) (-10,-23,0)(-5,-20,0) (-3,-22,0)(5,-25,0) (10,-22,0)(12,-20,0) (15,-17,0)(12,-12,0) (10,-10,0)(8,-7,0) (0,-7,0)(-7,-8,0) (-12,-11,0)(-15,-15,0)");
end