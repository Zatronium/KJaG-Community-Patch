require 'scripts/common'

-- Global values.
local kaiju = 0;
local weapon = "weapon_shrubby_entangle";
local targetPos = nil;
local aoeRange = 300;
local number_of_ticks = 5;
local immobileDuration = 5;
function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	local target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		targetPos = target:getWorldPosition();
	end
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_channel");
	registerAnimationCallback(this, kaiju, "end");

end

function onAnimationEvent(a)
	local view = kaiju:getView();

	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(1, number_of_ticks - 1);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);

	playSound("shrubby_ability_Entangle");
	startCooldown(kaiju, abilityData.name);	
end

function onTick(aura)
	local targets = getTargetsInRadius(targetPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	kaiju = getPlayerAvatar();
	for t in targets:iterator() do
		local fly = false;
		if getEntityType(t) == EntityType.Vehicle then
			local v = entityToVehicle(t);
			if v:isAir() then
				fly = true;
			end
		end
		if not isSameEntity(kaiju, t) and fly then
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

			applyDamageWithWeapon(kaiju, t, weapon); 
			t = nil; -- target may have been destroyed after damage

		end
	end
end

function ImmobileAura(aura)
	if not aura then return end
	local elapsed = aura:getElapsed();
	if elapsed > immobileDuration then
		aura:getTarget():setImmobile(false);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end