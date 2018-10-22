require 'scripts/avatars/common'

local avatar = nil;
local Angle = 55;
local weapon = "weapon_shrubby_poisonSpray1"
local number_of_ticks = 5;

function onUse(a)
	avatar = a;
	playAnimation(a, "ability_breath");
	registerAnimationCallback(this, a, "start");
end

function onAnimationEvent(a)
	startCooldown(a, abilityData.name);
	playSound("shrubby_ability_PoisonPlume");
	local view = a:getView();
	local worldPosition = a:getWorldPosition();
	local worldFacing = a:getWorldFacing();
	local sceneFacing = a:getSceneFacing();
	
	local targets = getTargetsInCone(worldPosition, 400, Angle, worldFacing, EntityFlags(EntityType.Vehicle));
	view:doEffectFromNode('breath_node', 'effects/poisonPlume_core.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/poisonPlume_range.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/poisonPlume_center.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/poisonPlume_main.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/poisonPlume_muzzle.plist', sceneFacing);
	for t in targets:iterator() do
		if canTarget(t) and isOrganic(t) then

			t:attachEffect("effects/poisonPlume_aura.plist", 2, true);

			local aura = createAura(this, t, 0);
			aura:setTickParameters(1, 0);
			aura:setScriptCallback(AuraEvent.OnTick, "onTick");
			aura:setTarget(t);
			t = nil; -- onTick may have killed target at this point

		end
	end
end

function onTick(aura)
	if aura:getElapsed() >= number_of_ticks then
		aura:getOwner():detachAura(aura);
	else
		avatar = getPlayerAvatar();
		applyDamageWithWeapon(avatar, aura:getTarget(), weapon);
	end
end