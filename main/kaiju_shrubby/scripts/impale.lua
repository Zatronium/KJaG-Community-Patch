require 'scripts/avatars/common'

local kaiju = 0;
local weapon = "weapon_shrubby_airVine2";
local weapon_node = "root"
local number_targets = 3;

function setupVine()
	local vine = createRope("sprites/placehold_vine.png", 20, 45);
	-- uv setUV(tip, root, segments to divide the middle uv) default 1.0, 0.0, 1 
	vine:setUV(0.7, 0.3, 1);
	-- setNoise(min distance, max distance) default 0, 0
	vine:setNoise(0, 10);
	-- setRetract(delay between vert culling, lower = more culled per update) default  0.0, 30
	vine:setRetract(0.0, 100);
	vine:setEndEntity(kaiju);
	return vine;
end

function onUse(a)
	kaiju = a;
	
	local worldPos = kaiju:getWorldPosition();
	local targets = getTargetsInRadius(worldPos, getWeaponRange(weapon), EntityFlags(EntityType.Vehicle));
	local view = kaiju:getView();
	local attacked = false;
	for t in targets:iterator() do
		if number_targets > 0 then
			local v = entityToVehicle(t);
			if v:isAir() then
				proj = avatarFireAtTarget(kaiju, weapon, weapon_node, t, 90 - view:getFacingAngle());
				proj:setCallback(this, 'onHit');
				attacked = true;
				number_targets = number_targets - 1;
				
				local v = setupVine();
				v:setStartEntity(proj);
				v:activate();
			end
		end
	end
	if attacked then
		playSound("shrubby_ability_Impale");
		startCooldown(kaiju, abilityData.name);
		playAnimation(kaiju, "stomp");
	else
		NoTargetText(kaiju);
	end
end

function onHit(proj)
	local pos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), pos);
	--playSound("explosion");
end