require 'scripts/avatars/common'

local kaiju = nil;
local targetPos = nil;
local weapon = "goop_Glare"
local weapon_node = "eyeball"
local pulses = 5;
local beamWidth = 50;
local pulseDelay = 0.5;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

function onTargets(position)
	targetPos = position;
	local target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		targetPos = target:getWorldPosition();
	end
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), position);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_breath");
	registerAnimationCallback(this, kaiju, "start");
	startAbilityUse(kaiju, abilityData.name);
	playSound("goop_ability_ShockGlare");
end

function onAnimationEvent(a)
	local beamAura = Aura.create(this, kaiju);
	beamAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	beamAura:setTickParameters(pulseDelay, 0);
	beamAura:setTarget(kaiju); -- required so aura doesn't autorelease
	local view = kaiju:getView();
	view:togglePauseAnimation(true);
end

function onTick(aura)
	if not aura then return end
	kaiju = getPlayerAvatar();
	local view = kaiju:getView();
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	
	local range = getWeaponRange(weapon);
	local beamOrigin = kaiju:getWorldPosition();
	local beamDir = getDirectionFromPoints(beamOrigin, targetPos);
	local beamEnd = getBeamEndWithDir(beamOrigin, range, beamDir);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
		
	view:doBeamWeaponFromNode('eyeball', getScenePosition(beamEnd), weapon, Point(0, 0));

	for t in targets:iterator() do	
		local flying = false;
		if getEntityType(t) == EntityType.Vehicle then
			local veh = entityToVehicle(t);
			flying = veh:isAir();
		end
		if not flying then
			applyDamageWithWeapon(kaiju, t, weapon);
		end
	end
	
	pulses = pulses - 1;
	if pulses <= 0 then
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			owner:detachAura(aura);
		end
		view:togglePauseAnimation(false);
		endAbilityUse(kaiju, abilityData.name);
	end
end