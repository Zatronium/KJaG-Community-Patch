require 'scripts/avatars/common'

local kaiju = nil;
local weapon = "weapon_shrubby_vinewave";
local aoeRange = 300;
local kbDistance = 200;
local kbPower = 400;

function setupNewVine()
	--vine = createRope("sprite", segments, strokeWidth);
	local vine = createRope("sprites/placehold_vine.png", 60, 160);
	-- uv setUV(tip, root, segments to divide the middle uv) default 1.0, 0.0, 1 
	vine:setUV(0.7, 0.3, 1);
	-- setNoise(min distance, max distance) default 0, 0
	vine:setNoise(0, 10);
	-- setRetract(delay between vert culling, lower = more culled per update) default  0.0, 30
	vine:setRetract(0.4, 30);
	vine:setPathSpeed(60);
	vine:setEndEntity(kaiju);
	return vine;
end

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_channel");
	local view = a:getView();
	local worldPos = kaiju:getWorldPosition();
		
	local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		if not isSameEntity(t, kaiju) then
			local otherPos = t:getWorldPosition();
			local dir = getDirectionFromPoints(worldPos, otherPos);
			t:displaceDirection(dir, kbPower, kbDistance);
			t:attachEffect("effects/roots_debris.plist", 1, true);
			t:attachEffect("effects/roots_shockwave.plist", 1, true);
			t:attachEffect("effects/leaves.plist", 1, true);
			applyDamageWithWeapon(kaiju, t, weapon);
		end
	end
	
	local vinerange = (0.5 * aoeRange) - 50;
	local randOff = math.random(0, 120);
	local vine1 = setupNewVine();
	vine1:setStartPoint(worldPos);
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(-20, 20), 0.25 * vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(70, 90), 0.5 * vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + 0, 0.75 * vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(-10, 10), vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(-90, -70), vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(-70, -50), 0.5 * vinerange));
	vine1:activate();
	
	randOff = randOff + 120;
	
	vine1 = setupNewVine();
	vine1:setStartPoint(worldPos);
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(-20, 20), 0.25 * vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(70, 90), 0.5 * vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + 0, 0.75 * vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(-10, 10), vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(-90, -70), vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(-70, -50), 0.5 * vinerange));
	vine1:activate();
	
	randOff = randOff + 120;
	
	vine1 = setupNewVine();
	vine1:setStartPoint(worldPos);
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(-20, 20), 0.25 * vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(70, 90), 0.5 * vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + 0, 0.75 * vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(-10, 10), vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(-90, -70), vinerange));
	vine1:addWorldPath(getEndOfBeamPosition(worldPos, randOff + math.random(-70, -50), 0.5 * vinerange));
	vine1:activate();
	
	playSound("shrubby_ability_VineWave");
	startCooldown(kaiju, abilityData.name);	
end

