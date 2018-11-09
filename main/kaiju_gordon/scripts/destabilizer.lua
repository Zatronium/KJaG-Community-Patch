require 'scripts/avatars/common'

-- Global values.
local kaiju = nil
local weaponDamage = "Meson1";
local weapon = "Meson1_track";

local weapon_node = "breath_node"

local minDuration = 1;
local maxDuration = 3;

local aoeRange = 100;
local empower = 0;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	local targetPos = position;
	local target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		if getEntityType(target) == EntityType.Zone then
			createFloatingText(target, "Invalid Target", 255, 0, 0);
		else
			local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
			kaiju:setWorldFacing(facingAngle);	
			playAnimation(kaiju, "ability_cast");
			registerAnimationCallback(this, kaiju, "start");
		end
	end
end

function onAnimationEvent(a)
	local target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		local view = kaiju:getView();
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
		startCooldown(kaiju, abilityData.name);	
		empower = kaiju:hasPassive("enhancement");
		kaiju:removePassive("enhancement", 0);
		playSound("Destabilizer");
	end
end

function onTick(aura)
	if aura:getElapsed() > 0 then
		explode(kaiju:getWorldPosition());
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end

function explode(pos)
	local targets = getTargetsInRadius(pos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar, EntityType.Zone));
	abilityEnhance(empower);
	for t in targets:iterator() do
		if not isSameEntity(t, kaiju) then
			applyDamageWithWeapon(kaiju, t, weaponDamage);
		end
	end
	abilityEnhance(0);
	createEffectInWorld("effects/destabilizer_wave.plist", pos, 0);
end