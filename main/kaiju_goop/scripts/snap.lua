require 'scripts/avatars/common'

local kaiju = nil;
local angle = 45;
local weapon = "goop_Snap"
local weapon_node = "palm_node_01"
local anim = "ability_snap"

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, anim);
	registerAnimationCallback(this, kaiju, "attack");
	startCooldown(a, abilityData.name);
	playSound("goop_ability_Snap");	
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local worldPosition = kaiju:getWorldPosition();
	local worldFacing = kaiju:getWorldFacing();

	local targets = getTargetsInCone(worldPosition, getWeaponRange(weapon), angle, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		applyDamageWithWeapon(kaiju, t, weapon);
	end
	
	local effectsPos = getBeamEndWithFacing(worldPosition, getWeaponRange(weapon) * 0.5, worldFacing);
	
--	createEffectInWorld("effects/snap.plist", effectsPos, 0);
--	createEffectInWorld("effects/snap_erratic.plist", effectsPos, 0);
	view:doEffectFromNode('palm_node_01', 'effects/snap_impact.plist', 0);
	view:doEffectFromNode('palm_node_01', 'effects/snap_impact_splash.plist', 0);
	view:doEffectFromNode('palm_node_01', 'effects/snap.plist', 0);
--	view:doEffectFromNode('palm_node_01', 'effects/snap_erratic.plist', 0);
--	view:doEffectFromNode('palm_node_02', 'effects/snap.plist', 0);
--	view:doEffectFromNode('palm_node_02', 'effects/snap_erratic.plist', 0);
end