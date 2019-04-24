require 'kaiju_goop/scripts/goop'
-- Global values.
local kaiju = nil
local weapon = "goop_Splork";
local weapon_node = "eyeball"
local angle = 75;

local targetPos = nil;

local dotTime = 10;
local dotMult = 1;

local minGoop = 0;
local maxGoop = 20;

function onUse(a)
	kaiju = a;
	dotMult = 1 + kaiju:hasPassive("goop_dot_bonus");
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	target = getAbilityTarget(kaiju, abilityData.name);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_roar");
	registerAnimationCallback(this, kaiju, "start");
	playSound("goop_ability_Splork"); -- SOUND
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local proj;
	local target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		targetPos = target:getWorldPosition();
	end
	startCooldown(kaiju, abilityData.name);	
	local worldPos = kaiju:getWorldPosition();
	local facing = getFacingAngle(worldPos, targetPos);
	local faceAngle = facing + 45;
	 
	view:doEffectFromNode(weapon_node, 'effects/goop_breath_long.plist', faceAngle);
	view:doEffectFromNode(weapon_node, 'effects/goop_breath2_long.plist', faceAngle);
	
	local targets = getTargetsInCone(worldPos, getWeaponRange(weapon), angle, facing, EntityFlags(EntityType.Zone));
	for t in targets:iterator() do
		local dotAura = Aura.create(this, t);
		dotAura:setTag("goop_splork");
		dotAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
		dotAura:setTickParameters(1, dotTime);
		dotAura:setTarget(t); -- required so aura doesn't autorelease	
	end
end

function onTick(aura)
	local own = aura:getOwner();
	if aura:getElapsed() < dotTime and canTarget(own) then
		local dotDamage = getWeaponDamage(weapon) * dotMult;
		applyDamageWithWeaponDamage(getPlayerAvatar(), own, weapon, dotDamage);
		if own:getStat("Health") <= 0 then
			CreateBlob(own:getWorldPosition(), minGoop, maxGoop);
		end
	else
		own:detachAura(aura);
	end
end
