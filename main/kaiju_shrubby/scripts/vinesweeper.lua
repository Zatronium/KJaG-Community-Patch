require 'scripts/common'

-- Global values.
local kaiju = 0;
local weapon = "weapon_shrubby_Sweeper";

local vine1 = nil;
local vine2 = nil;
local pos1 = nil;
local pos2 = nil;
function setupNewVine()
	--vine = createRope("sprite", segments, strokeWidth);
	local vine = createRope("sprites/placehold_vine.png", 60, 150);
	-- uv setUV(tip, root, segments to divide the middle uv) default 1.0, 0.0, 1 
	vine:setUV(0.7, 0.3, 1);
	-- setNoise(min distance, max distance) default 0, 0
	vine:setNoise(0, 0);
	-- setRetract(delay between vert culling, lower = more culled per update) default  0.0, 30
	vine:setRetract(0.4, 30);
	vine:setPathSpeed(20);
	vine:setEndEntity(kaiju);
	return vine;
end

function onUse(a)
	kaiju = a;

	--playAnimation(kaiju, "ability_project_2H");
	playAnimation(kaiju, "ability_bite");
	
	registerAnimationCallback(this, kaiju, "attack");

end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local weapRange = getWeaponRange(weapon);
	local beamRange = weapRange;

	local beamOrigin = kaiju:getWorldPosition();
	local beamFacing = kaiju:getWorldFacing();
	local beamWidth = 200;
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamRange);
	
	local angle = math.deg( math.atan(beamWidth /  weapRange));

	vine1 = setupNewVine();
	vine1:setStartPoint(beamOrigin);
	vine1:addWorldPath(getEndOfBeamPosition(beamOrigin, beamFacing + angle, 0.25 * beamRange));
	vine1:addWorldPath(getEndOfBeamPosition(beamOrigin, beamFacing - angle, 0.5 * beamRange));
--	vine1:addWorldPath(beamOrigin);
	vine1:activate();
	
	vine2 = setupNewVine();
	vine2:setStartPoint(beamOrigin);
	vine2:addWorldPath(getEndOfBeamPosition(beamOrigin, beamFacing - angle, 0.25 * beamRange));
	vine2:addWorldPath(getEndOfBeamPosition(beamOrigin, beamFacing + angle, 0.5 * beamRange));
--	vine2:addWorldPath(beamOrigin);
	vine2:activate();
		
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		applyDamageWithWeapon(kaiju, t, weapon);
	end
	playSound("shrubby_ability_VineSweeper");
	startCooldown(kaiju, abilityData.name);	
end
