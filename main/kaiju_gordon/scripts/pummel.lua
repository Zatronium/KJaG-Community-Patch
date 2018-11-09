require 'scripts/avatars/common'

local kaiju = nil;

local weapon = "Pummel1"
local attackAnim1 = "ability_punchone"
local attackAnim2 = "ability_punchtwo"

local animBool = false;

local initialChance = 0.9;
local chanceDecay = 0.05;

local fx1 = 0;
local fx2 = 0;

local empower = 0;

function onUse(a)
	kaiju = a;
	local v = a:getView();
	v:setAnimation(attackAnim1, false);
	--registerAnimationCallback(this, kaiju, "attack");
	registerAnimationCallbackContinuous(this, kaiju, "attack");
	startAbilityUse(kaiju, abilityData.name);
	empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	local view = a:getView();
	fx1 = view:attachEffectToNode("palm_node_01", "effects/pummel.plist", -1,  0, 0,false, false);
	fx2 = view:attachEffectToNode("palm_node_02", "effects/pummel.plist", -1, 0, 0, false, false);
end

function onAnimationEvent(a, event)
	kaiju = a;
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local beamRange = 100;
	local beamWidth = 25;
	playSound("Pummel");
	local beamOrigin = a:getWorldPosition();
	local beamFacing = a:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	local dir = getDirectionFromPoints(beamOrigin, beamEnd);
	abilityEnhance(empower);
	for t in targets:iterator() do
		if not isSameEntity(t, kaiju) then
			applyDamageWithWeapon(kaiju, t, weapon);
		end
	end
	abilityEnhance(0);
	
	local v = kaiju:getView();
	if randomFloat(0, 1) < initialChance then
	--	v:setAnimation("idle", false);
		animBool = not animBool;
		if animBool then
			v:addAnimation(attackAnim2, false);
		else
			v:addAnimation(attackAnim1, false);
		end
		initialChance = initialChance - chanceDecay;
	else
		v:addAnimation("idle", true);
		v:endEffect(fx1);
		v:endEffect(fx2);
		endAbilityUse(kaiju, abilityData.name);
		removeAnimationCallback(this, a);
	end
end
