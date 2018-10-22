require 'scripts/avatars/common'

local avatar = nil;
local Angle = 60;
local weapon = "weapon_shrubby_poisonSpray2"
local duration = 10;
local immumeTime = 10;
local infectRange = 50;

function onUse(a)
	avatar = a;
	playAnimation(a, "ability_breath");
	startCooldown(a, abilityData.name);
	playSound("shrubby_ability_InfectiousPlume");
	local view = a:getView();
	local worldPosition = a:getWorldPosition();
	local worldFacing = a:getWorldFacing();
	local sceneFacing = a:getSceneFacing();

	local targets = getTargetsInCone(worldPosition, getWeaponRange(weapon), Angle, worldFacing, EntityFlags(EntityType.Vehicle ,EntityType.Avatar));
	view:doEffectFromNode('breath_node', 'effects/infectiousPlume_core.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/infectiousPlume_range.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/infectiousPlume_center.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/infectiousPlume_main.plist', sceneFacing);
	for t in targets:iterator() do
		if canTarget(t) and isOrganic(t) and not isSameEntity(avatar, t) then
			Infect(t);
		end
	end
end

function onTick(aura)
	avatar = getPlayerAvatar();
	local target = aura:getTarget();
	local elapsed = aura:getElapsed();
	if elapsed > duration + immumeTime then
		target:detachAura(aura);
	else
		if elapsed > 0 and elapsed < duration then
			local targets = getTargetsInRadius(target:getWorldPosition(), infectRange, EntityFlags(EntityType.Vehicle ,EntityType.Avatar));
			for t in targets:iterator() do
				if canTarget(t) and isOrganic(t) and not isSameEntity(avatar, t) then
					if not t:hasAura("infectious_plume") then
						Infect(t);
					end
				end
			end
			applyDamageWithWeapon(avatar, target, weapon);
		end
	end
end

function Infect(t)
	t:attachEffect("effects/infectious_plume.plist", duration, true);
	local aura = createAura(this, t, 0);
	aura:setTag("infectious_plume");
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(t);
end