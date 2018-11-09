require 'scripts/avatars/common'

local kaiju = nil;

local weapon = "Pummel2"
local attackAnim1 = "ability_punchone"
local attackAnim2 = "ability_punchtwo"

local weaponEffect = "ForcePunch2"

local animBool = false;

local initialChance = 1.0;
local chanceDecay = 0.05;

local spinAngle = -30;
local startingAngle = 0;

local fx1 = 0;
local fx2 = 0;

function onUse(a)
	kaiju = a;
	local v = a:getView();
	v:setAnimation(attackAnim1, false);
	--registerAnimationCallback(this, kaiju, "attack");
	registerAnimationCallbackContinuous(this, kaiju, "attack");
	startAbilityUse(kaiju, abilityData.name);
	
	startingAngle = a:getWorldFacing();
	playSound("AtomicCyclone");

	local view = a:getView();
	fx1 = view:attachEffectToNode("palm_node_01", "effects/atomicCyclone.plist", -1,  0, 0,false, false);
	fx2 = view:attachEffectToNode("palm_node_02", "effects/atomicCyclone.plist", -1, 0, 0, false, false);
	local empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	abilityEnhance(empower);
end

function onAnimationEvent(a, event)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local beamRange = 200;
	local beamWidth = 25;

	local beamOrigin = a:getWorldPosition();
	local beamFacing = startingAngle;
	kaiju:setWorldFacing(beamFacing);
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	local dir = getDirectionFromPoints(beamOrigin, beamEnd);
	
	local offset = beamOrigin;
	offset = offset:add(Point(25, 25));

	fireProjectileAtPoint(nil, offset, beamEnd, weaponEffect);
	
	for t in targets:iterator() do
		if not isSameEntity(t, kaiju) then
			applyDamageWithWeapon(kaiju, t, weapon);
		end
	end
	
	local v = kaiju:getView();
	if randomFloat(0, 1) < initialChance then
	--	v:setAnimation("idle", false);
		if animBool then
			animBool = false;
			v:addAnimation(attackAnim2, false);
		else
			animBool = true;
			v:addAnimation(attackAnim1, false);
		end
		initialChance = initialChance - chanceDecay;
		startingAngle = startingAngle + spinAngle;
		if startingAngle <= -180 then
			startingAngle = startingAngle + 360;
		end
	else
		v:addAnimation("idle", true);
		v:endEffect(fx1);
		v:endEffect(fx2);
		abilityEnhance(0);
		removeAnimationCallback(this, a);
		endAbilityUse(kaiju, abilityData.name);
	end
end
