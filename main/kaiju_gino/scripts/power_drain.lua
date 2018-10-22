 require 'scripts/common'
local range = 400;
local disableTime = 10;

function onUse(a)
	local total = 0;
	local worldPos = a:getWorldPosition();
	local targets = getTargetsInRadius(worldPos, range, EntityFlags(EntityType.Vehicle, EntityType.Zone));
	local view = a:getView();
	local scenePos = view:getAnimationNodePositionOffset("pelvis");
	view:attachEffectToNode("root", "effects/powerDrain_energyDraw.plist", 0,  0, 0,false, true);
	for t in targets:iterator() do
		if getEntityType(t) == EntityType.Vehicle then
			local veh = entityToVehicle(t);
			if veh:hasWeaponClass(WeaponClass.Energy) == true then
				veh:disabled(disableTime);
				t:attachEffect("effects/onEmp.plist", disableTime, true);
			end
		else
			local minpow = t:getStat("MinPower");
			local maxpow = t:getStat("MaxPower");
			if minpow > 0 or maxpow > 0 then
				local proj = fireProjectileAtTarget(t, a, Point(0,0), scenePos, "weapon_electricShard");
				if maxpow > 0 and minpow < maxpow then
					total = total + math.random(minpow, maxpow);
				else
					total = total + minpow;
				end
			end
			t:setStat("MinPower", 0);
			t:setStat("MaxPower", 0);
			local zone = entityToZone(t);
			zone:disableEmission();	
		end
	end
	if total > 0 then
		_log(total);
		a:gainPower(total);
	end
	startCooldown(a, abilityData.name);
end