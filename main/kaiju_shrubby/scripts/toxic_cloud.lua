require 'scripts/avatars/common'

local kaiju = nil;
local targetPos = nil;
local weapon = "weapon_shrubby_poisonCloud2"
local weaponProtect = "weapon_shrubby_poisonCloud2_protected"
local poisoncheck = 1;
local poisonduration = 10;
local cloudaoe = 100;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end 
	
function onTargets(position)
	targetPos = position;
	
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_breath");
	registerAnimationCallback(this, kaiju, "start");
end

function onAnimationEvent(a)
	startCooldown(kaiju, abilityData.name);	
	playSound("shrubby_ability_ToxicCloud");
	local cloud = spawnEntity(EntityType.Minion, "unit_shrubby_cloud", targetPos);
	setRole(cloud, "Player");
	cloud:attachEffect("effects/toxiccloud.plist", -1, true);
	local aura = createAura(this, cloud, 0);
	aura:setTickParameters(poisoncheck, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(cloud);
end

function onTick(aura)
	local targets = getTargetsInRadius(aura:getTarget():getWorldPosition(), cloudaoe, EntityFlags(EntityType.Vehicle, EntityType.Avatar));
	for t in targets:iterator() do
		local targetable = true;
		if not canTarget(t) or isSameEntity(kaiju, t) then
			targetable = false;
		end
		if getEntityType(t) == EntityType.Vehicle then
			local veh = entityToVehicle(t);
			if veh:isAir() then
				targetable = false;
			end
		end
		if targetable then		
			if t:hasAura("toxic_cloud_dot") then
				t:getAura("toxic_cloud_dot"):resetElapsed();
			else
				local aura = createAura(this, t, 0);
				aura:setTag("toxic_cloud_dot");
				aura:setTickParameters(1, 0);
				if isOrganic(t) then
					aura:setScriptCallback(AuraEvent.OnTick, "onTickUnProtected");
				else
					aura:setScriptCallback(AuraEvent.OnTick, "onTickProtected");
				end
				aura:setTarget(t);
			end
		end
	end
end

function onTickProtected(aura)
	if not aura then return end
	if aura:getElapsed() > poisonduration then
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	else
		applyDamageWithWeapon(kaiju, aura:getTarget(), weaponProtect);
	end
end

function onTickUnProtected(aura)
	if not aura then return
	if aura:getElapsed() > poisonduration then
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	else
		applyDamageWithWeapon(kaiju, aura:getTarget(), weapon);
	end
end