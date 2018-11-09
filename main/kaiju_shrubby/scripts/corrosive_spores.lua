require 'scripts/avatars/common'

local kaiju = nil;
local weapon = "weapon_shrubby_acidCloud"

local aoeRange = 200;
local duration = 5;
local armorPerTick = -1;
local speedPerTick = -2;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

function onTargets(position)
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), position);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_channel");
	startCooldown(kaiju, abilityData.name);
	playSound("shrubby_ability_CorrosiveSpores");
--	local view = kaiju:getView();
	
	local targets = getTargetsInRadius(position, aoeRange, EntityFlags(EntityType.Vehicle ,EntityType.Avatar, EntityType.Zone));
	createEffectInWorld("effects/corrosiveSpores.plist", position, duration);
	
	for t in targets:iterator() do
		if canTarget(t) and not isSameEntity(kaiju, t) then
			t:attachEffect("effects/corrosiveSpores.plist", duration, true);
			local aura = createAura(this, t, 0);
			aura:setTickParameters(1, duration - 1);
			aura:setStat("Speed", 0);
			aura:setStat("Armor", 0);
			aura:setScriptCallback(AuraEvent.OnTick, "onTick");
			aura:setTarget(t);
		end
	end
end

function onTick(aura)
	if not aura then return end
	local target = aura:getTarget();
	aura:setStat("Armor", aura:getStat("Armor") + armorPerTick);
	aura:setStat("Speed", aura:getStat("Speed") + speedPerTick);
	applyDamageWithWeapon(kaiju, target, weapon);
end