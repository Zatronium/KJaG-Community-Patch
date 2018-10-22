require 'scripts/common'

local avatar = 0;
local weapon = "weapon_shrubby_entangle";
local targetPos = nil;
local aoeRange = 300;
local number_of_ticks = 5;
local immobileDuration = 5;
function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	local target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) then
		targetPos = target:getWorldPosition();
	end
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);	
	playAnimation(avatar, "ability_channel");
	registerAnimationCallback(this, avatar, "end");

end

function onAnimationEvent(a)
	local view = avatar:getView();

	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(1, number_of_ticks - 1);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);

	playSound("shrubby_ability_Entangle");
	startCooldown(avatar, abilityData.name);	
end

function onTick(aura)
	local targets = getTargetsInRadius(targetPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	avatar = getPlayerAvatar();
	for t in targets:iterator() do
		local fly = false;
		if getEntityType(t) == EntityType.Vehicle then
			local v = entityToVehicle(t);
			if v:isAir() == true then
				fly = true;
			end
		end
		if not isSameEntity(avatar, t) and not fly then
			if not t:hasAura("entangle") then
				t:attachEffect("effects/rootCluster.plist", immobileDuration, true);
				t:attachEffect("effects/entangleWave.plist", .2, true);
				t:setImmobile(true);
				local aura = createAura(this, t, 0);
				aura:setTag("entangle");
				aura:setTickParameters(immobileDuration, 0);
				aura:setScriptCallback(AuraEvent.OnTick, "ImmobileAura");
				aura:setTarget(t);
			end

			applyDamageWithWeapon(avatar, t, weapon); 
			t = nil; -- target may have been destroyed after damage

		end
	end
end

function ImmobileAura(aura)
	local elapsed = aura:getElapsed();
	if elapsed > immobileDuration then
		aura:getTarget():setImmobile(false);
		aura:getOwner():detachAura(aura);
	end
end