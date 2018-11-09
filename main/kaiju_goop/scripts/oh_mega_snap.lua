require 'scripts/avatars/common'

local kaiju = nil;
local angle = 45;
local weapon = "goop_Snap2"
local weapon_node = "palm_node_01"
local anim = "ability_triplesnap"
local attackChance = 100;
local attackDecay = 10;

local lastAttack1 = 2;
local Attack1 = "attack";
local Attack2 = "attack_02";

function onUse(a)
	kaiju = a;
	local v = a:getView();
	v:setAnimation(anim, true);
	registerAnimationCallbackContinuous(this, kaiju, Attack1);
	startAbilityUse(kaiju, abilityData.name);
	playSound("goop_ability_OhMegaSnap");
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local worldPosition = kaiju:getWorldPosition();
	local worldFacing = kaiju:getWorldFacing();

	local damaged = false;
	local targets = getTargetsInCone(worldPosition, getWeaponRange(weapon), angle, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		if not damaged and not isSameEntity(t, kaiju) then
			damaged = true;
		end
		applyDamageWithWeapon(kaiju, t, weapon);
	end	

	local effectsPos = getBeamEndWithFacing(worldPosition, getWeaponRange(weapon) * 0.5, worldFacing);
	
--	createEffectInWorld("effects/snap.plist", effectsPos, 0);
--	createEffectInWorld("effects/snap_erratic.plist", effectsPos, 0);	
--	createEffectInWorld("effects/snap_erratic_vorpal.plist", effectsPos, 0);

	view:doEffectFromNode('palm_node_01', 'effects/snap_impact.plist', 0);
	view:doEffectFromNode('palm_node_01', 'effects/snap_impact_splash.plist', 0);
--	view:doEffectFromNode('palm_node_01', 'effects/snap.plist', 0);
	view:doEffectFromNode('palm_node_01', 'effects/snap_erratic_vorpal.plist', 0);
--	view:doEffectFromNode('palm_node_02', 'effects/snap.plist', 0);
	view:doEffectFromNode('palm_node_02', 'effects/snap_erratic_vorpal.plist', 0);

		
	lastAttack1 = lastAttack1 + 1;
	if damaged and attackChance >= math.random(0, 100) then
		if lastAttack1 > 2 then	
			registerAnimationCallbackContinuous(this, kaiju, Attack2);
			lastAttack1 = 1;
		else
			registerAnimationCallbackContinuous(this, kaiju, Attack1);
		end
	else
		view:setAnimation(anim, false);
		view:addAnimation("idle", true);
		endAbilityUse(kaiju, abilityData.name);
		removeAnimationCallback(this, kaiju);
	end
	attackChance = attackChance - attackDecay;
end