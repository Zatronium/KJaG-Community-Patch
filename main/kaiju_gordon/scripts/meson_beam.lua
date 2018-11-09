require 'scripts/avatars/common'

-- Global values.
local kaiju = nil
local weapon = "Meson1_track";

local weapon_node = "breath_node"

local target = nil;
local targetPos = nil;

local minDuration = 1;
local maxDuration = 3;

local aoeRange = 150;

local empower = 0;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		local entType = getEntityType(target);
		local invalid = false;
		if entType == EntityType.Zone or entType == EntityType.Avatar then
			invalid = true;
		end
		if entType == EntityType.Vehicle then
			local veh = entityToVehicle(target);
			invalid = veh:isSuper();
		end
		if invalid then
			createFloatingText(target, "Invalid Target", 255, 0, 0);
		else
			local facingAngle = getFacingAngle(kaiju:getWorldPosition(), position);
			kaiju:setWorldFacing(facingAngle);	
			playAnimation(kaiju, "ability_cast");
			registerAnimationCallback(this, kaiju, "start");
		end
	end
end

function onAnimationEvent(a)
	if canTarget(target) then
		local view = kaiju:getView();
		local pos = getScenePosition(target:getWorldPosition()):add( getSceneOffset(target));
		view:doBeamEffectFromNode('breath_node', pos, 'effects/beam_meson.plist', 0 );
		view:doEffectFromNode('breath_node', 'effects/eyeBeam_muzzleGlow.plist', 0);
		
		local stableAura = Aura.create(this, target);
		stableAura:setTag('meson_beam');
		stableAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
		local duration = math.random(minDuration, maxDuration);
		stableAura:setTickParameters(duration, 0);
		stableAura:setTarget(target);
		
		target:attachEffect("effects/destabilizer_charge.plist", duration, true);
		
		playSound("MesonBeam");
		startCooldown(kaiju, abilityData.name);		
		empower = kaiju:hasPassive("enhancement");
		kaiju:removePassive("enhancement", 0);
	end
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() > 0 then
		explode(kaiju:getWorldPosition(), kaiju);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end

function explode(pos, targ)
	if targ then
		local targets = getTargetsInRadius(pos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar, EntityType.Zone));
		local health = targ:getStat("Health");
		abilityEnhance(empower);
		for t in targets:iterator() do
			if not isSameEntity(t, kaiju) then
				local entType = getEntityType(t)
				if entType == EntityType.Avatar or (entType == EntityType.Vehicle and entityToVehicle(t):isSuper()) then
					applyDamage(kaiju, t, math.floor(health * 0.35))
				else
					applyDamage(kaiju, t, health)
				end
			end
		end
		abilityEnhance(0);
	end
	createEffectInWorld("effects/destabilizer_wave.plist", pos, 0);
end