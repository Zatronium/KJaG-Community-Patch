require 'scripts/avatars/common'

kaiju = nil;
angle = 45;
weapon = "goop_Snap2"
weapon_node = "palm_node_01"
anim = "ability_triplesnap"
attacks = 3;

lastAttack1 = true;
Attack1 = "attack";
Attack2 = "attack_02";

function onUse(a)
	kaiju = a;
	local v = a:getView();
	v:setAnimation(anim, false);
	lastAttack1 = true;
	registerAnimationCallbackContinuous(this, kaiju, Attack1);
	startAbilityUse(kaiju, abilityData.name);
	playSound("goop_ability_VorpalSnap");
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local worldPosition = kaiju:getWorldPosition();
	local worldFacing = kaiju:getWorldFacing();
	local sceneFacing = kaiju:getSceneFacing();

	local targets = getTargetsInCone(worldPosition, getWeaponRange(weapon), angle, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		applyDamageWithWeapon(kaiju, t, weapon);
	end		
	
	local effectsPos = getBeamEndWithFacing(worldPosition, getWeaponRange(weapon) * 0.5, worldFacing);
	
--	createEffectInWorld("effects/snap.plist", effectsPos, 0);
--	createEffectInWorld("effects/snap_erratic_vorpal.plist", effectsPos, 0);

	view:doEffectFromNode('palm_node_01', 'effects/snap_impact.plist', 0);
	view:doEffectFromNode('palm_node_01', 'effects/snap_impact_splash.plist', 0);
--	view:doEffectFromNode('palm_node_01', 'effects/snap.plist', 0);
	view:doEffectFromNode('palm_node_01', 'effects/snap_erratic_vorpal.plist', 0);
--	view:doEffectFromNode('palm_node_02', 'effects/snap.plist', 0);
	view:doEffectFromNode('palm_node_02', 'effects/snap_erratic_vorpal.plist', 0);
	
	attacks = attacks - 1;
	
	if attacks > 0 then
		if lastAttack1 then	
			registerAnimationCallbackContinuous(this, kaiju, Attack2);
			lastAttack1 = false;
		else
			registerAnimationCallbackContinuous(this, kaiju, Attack1);
			lastAttack1 = true;
		end
	else
		view:addAnimation("idle", true);
		endAbilityUse(kaiju, abilityData.name);
		removeAnimationCallback(this, kaiju);
	end
end