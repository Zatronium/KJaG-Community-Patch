require 'scripts/avatars/common'

-- Global values.
local avatar = 0;
local weaponDamage = "Meson1";
local weapon = "Meson1_track";

local weapon_node = "breath_node"

local target = nil;
local targetPos = nil;

local minDuration = 1;
local maxDuration = 3;

local aoeRange = 100;
local empower = 0;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) then
		if getEntityType(target) == EntityType.Zone then
			createFloatingText(target, "Invalid Target", 255, 0, 0);
		else
			local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
			avatar:setWorldFacing(facingAngle);	
			playAnimation(avatar, "ability_cast");
			registerAnimationCallback(this, avatar, "start");
		end
	end
end

function onAnimationEvent(a)
	target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) then
		local view = avatar:getView();
		local pos = getScenePosition(target:getWorldPosition());
		view:doBeamEffectFromNode('breath_node', pos, 'effects/destabilizer.plist', 0 );
		view:doEffectFromNode('breath_node', 'effects/eyeBeam_muzzleGlow.plist', 0);
		
		local stableAura = Aura.create(this, target);
		stableAura:setTag('destableizer');
		stableAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
		local duration = math.random(minDuration, maxDuration);
		stableAura:setTickParameters(duration, 0);
		stableAura:setTarget(target);
		
		target:attachEffect("effects/destabilizer_charge.plist", duration, true);
		
		--playSound("shrubby_ability_FangStrike");
		startCooldown(avatar, abilityData.name);	
		empower = avatar:hasPassive("enhancement");
		avatar:removePassive("enhancement", 0);
		playSound("Destabilizer");
	end
end

function onTick(aura)
	if aura:getElapsed() > 0 then
		explode(aura:getOwner():getWorldPosition());
		aura:getOwner():detachAura(aura);
	end
end

function explode(pos)
	avatar = getPlayerAvatar();
	local targets = getTargetsInRadius(pos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar, EntityType.Zone));
	abilityEnhance(empower);
	for t in targets:iterator() do
		if not isSameEntity(t, avatar) then
			applyDamageWithWeapon(avatar, t, weaponDamage);
		end
	end
	abilityEnhance(0);
	createEffectInWorld("effects/destabilizer_wave.plist", pos, 0);
end