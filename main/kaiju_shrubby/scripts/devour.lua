require 'scripts/avatars/common'
local life_per_drain = 25;
local damage_per_tick = 25;
local number_of_ticks = 3;
local weapon = "weapon_shrubby_devour";
local avatar = nil;
local target = nil;
function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

function onTargets(position)
	target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) then
		local facingAngle = getFacingAngle(avatar:getWorldPosition(), position);
		avatar:setWorldFacing(facingAngle);	
		playAnimation(avatar, "ability_multibite");
		registerAnimationCallback(this, avatar, "attack");
	end
end

function onAnimationEvent(a)
	target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) then	
		local aura = createAura(this, target, 0);
		aura:setTickParameters(1, number_of_ticks - 1);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(target);
	end

	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", .25, 0, 0, true, false);
	view:attachEffectToNode("breath_node", "effects/devour_lower.plist", .25, 0, 0, true, false);
	view:attachEffectToNode("breath_node", "effects/devour_upper.plist", .25, 0, 0, true, false);
	playSound("shrubby_ability_Devour");
	startCooldown(avatar, abilityData.name);	
end

function onTick(aura)
	avatar = getPlayerAvatar();
	local t = aura:getTarget();
	local lifeleft = t:getStat("Health");
	if lifeleft < life_per_drain then
		life_per_drain = lifeleft;
	end
	avatar:gainHealth(life_per_drain);
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", .25, 0, 0, true, false);
	applyDamageWithWeapon(avatar, t, weapon);
end
