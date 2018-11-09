require 'scripts/common'

damagePerStep = 5;
aoeRange = 150;
StepDamage = 1;

passiveThresh 		= "goop_splash_step";
passiveDamage 		= "goop_splash_damage";
passiveRange 		= "goop_splash_range";
passiveHitFlying 	= "goop_splash_flying";

kaiju = 0;

function onSet(a)
	kaiju = a;
	
	kaiju:setPassive(passiveThresh 		, damagePerStep);
	kaiju:setPassive(passiveDamage 		, StepDamage 		);
	kaiju:setPassive(passiveRange 			, aoeRange 		);
	
	kaiju:addPassiveScript(this);
end

function aoeDamage(step)
	local damage = step * kaiju:hasPassive(passiveDamage);
	local worldPos = kaiju:getWorldPosition();
	local targets = getTargetsInRadius(worldPos, kaiju:hasPassive(passiveRange), EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	
	createEffectInWorld("effects/goopball_detonate1.plist", worldPos, 0);
	createEffectInWorld("effects/goopball_detonate2.plist", worldPos, 0);
	createEffectInWorld("effects/goopball_detonate3.plist", worldPos, 0);
	
	for t in targets:iterator() do
		local flying = false;
		if kaiju:hasPassive(passiveHitFlying) == 0 and getEntityType(t) == EntityType.Vehicle then
			local veh = entityToVehicle(t);
			flying = veh:isAir();
		end
		if flying == false then
			applyDamage(kaiju, t, damage);
		end
	end
end

function onAvatarDamageTaken(a, n, w)
	if a:hasPassive(passiveThresh) > 0 and n.y > a:hasPassive(passiveThresh) and w ~= nil then
		local step = n.y / a:hasPassive(passiveThresh);
		if step > 0 then
			kaiju = a;
			step = math.floor(step);
			aoeDamage(step);
		end
	end
end