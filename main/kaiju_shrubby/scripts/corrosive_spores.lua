require 'scripts/avatars/common'

local avatar = nil;
local weapon = "weapon_shrubby_acidCloud"

local aoeRange = 200;
local duration = 5;
local armorPerTick = -1;
local speedPerTick = -2;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

function onTargets(position)
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), position);
	avatar:setWorldFacing(facingAngle);	
	playAnimation(avatar, "ability_channel");
	startCooldown(avatar, abilityData.name);
	playSound("shrubby_ability_CorrosiveSpores");
--	local view = avatar:getView();
	
	local targets = getTargetsInRadius(position, aoeRange, EntityFlags(EntityType.Vehicle ,EntityType.Avatar, EntityType.Zone));
	createEffectInWorld("effects/corrosiveSpores.plist", position, duration);
	
	for t in targets:iterator() do
		if canTarget(t) and not isSameEntity(avatar, t) then
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
	avatar = getPlayerAvatar();
	local target = aura:getTarget();
	aura:setStat("Armor", aura:getStat("Armor") + armorPerTick);
	aura:setStat("Speed", aura:getStat("Speed") + speedPerTick);
	applyDamageWithWeapon(avatar, target, weapon);
end