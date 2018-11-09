require 'scripts/avatars/common'
local life_per_drain = 25;
local damage_per_tick = 25;
local number_of_ticks = 3;
local weapon = "weapon_shrubby_devour";
local kaiju = nil;
local target = nil;
function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

function onTargets(position)
	target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		local facingAngle = getFacingAngle(kaiju:getWorldPosition(), position);
		kaiju:setWorldFacing(facingAngle);	
		playAnimation(kaiju, "ability_multibite");
		registerAnimationCallback(this, kaiju, "attack");
	end
end

function onAnimationEvent(a)
	target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then	
		local aura = createAura(this, target, 0);
		aura:setTickParameters(1, number_of_ticks - 1);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(target);
	end

	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", .25, 0, 0, true, false);
	view:attachEffectToNode("breath_node", "effects/devour_lower.plist", .25, 0, 0, true, false);
	view:attachEffectToNode("breath_node", "effects/devour_upper.plist", .25, 0, 0, true, false);
	playSound("shrubby_ability_Devour");
	startCooldown(kaiju, abilityData.name);	
end

function onTick(aura)
	if not aura then return end
	local t = aura:getTarget();
	local lifeleft = t:getStat("Health");
	if lifeleft < life_per_drain then
		life_per_drain = lifeleft;
	end
	kaiju:gainHealth(life_per_drain);
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", .25, 0, 0, true, false);
	applyDamageWithWeapon(kaiju, t, weapon);
end
