require 'scripts/avatars/common'

local kaiju = nil;
local angle = 45.0;
local weapon = "goop_Snap"
local weapon_node = "palm_node_01"
local anim = "ability_doublesnap"
local attacks = 2;

function onUse(a)
	kaiju = a;
	local v = a:getView();
	v:setAnimation(anim, false);
	registerAnimationCallbackContinuous(this, kaiju, "attack");
	startAbilityUse(kaiju, abilityData.name);
	playSound("goop_ability_DoubleSnap");
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local worldPosition = kaiju:getWorldPosition();
	local worldFacing = kaiju:getWorldFacing();

	local targets = getTargetsInCone(worldPosition, getWeaponRange(weapon), angle, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		applyDamageWithWeapon(kaiju, t, weapon);
	end
--	view:doEffectFromNode('root', 'effects/plasmaFire_core.plist', sceneFacing);
--	view:doEffectFromNode('root', 'effects/plasmaFire_sparks.plist', sceneFacing);
	local effectsPos = getBeamEndWithFacing(worldPosition, getWeaponRange(weapon) * 0.5, worldFacing);
	
	view:doEffectFromNode('palm_node_01', 'effects/snap_impact.plist', 0);
	view:doEffectFromNode('palm_node_01', 'effects/snap_impact_splash.plist', 0);
	view:doEffectFromNode('palm_node_01', 'effects/snap.plist', 0);
	view:doEffectFromNode('palm_node_01', 'effects/snap_erratic.plist', 0);
	view:doEffectFromNode('palm_node_02', 'effects/snap.plist', 0);
	view:doEffectFromNode('palm_node_02', 'effects/snap_erratic.plist', 0);
	
	attacks = attacks - 1;
	
	if attacks > 0 then
		registerAnimationCallbackContinuous(this, kaiju, "attack_02");
	else
		view:addAnimation("idle", true);
		endAbilityUse(kaiju, abilityData.name);
		removeAnimationCallback(this, kaiju);
	end
end