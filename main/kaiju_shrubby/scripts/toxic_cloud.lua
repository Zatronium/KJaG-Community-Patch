require 'scripts/avatars/common'

local avatar = nil;
local targetPos = nil;
local weapon = "weapon_shrubby_poisonCloud2"
local weaponProtect = "weapon_shrubby_poisonCloud2_protected"
local poisoncheck = 1;
local poisonduration = 10;
local cloudaoe = 100;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end 
	
function onTargets(position)
	targetPos = position;
	
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);	
	playAnimation(avatar, "ability_breath");
	registerAnimationCallback(this, avatar, "start");
end

function onAnimationEvent(a)
	startCooldown(avatar, abilityData.name);	
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
		if not canTarget(t) or isSameEntity(avatar, t) then
			targetable = false;
		end
		if getEntityType(t) == EntityType.Vehicle then
			local veh = entityToVehicle(t);
			if veh:isAir() then
				targetable = false;
			end
		end
		if targetable == true then		
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
	if aura:getElapsed() > poisonduration then
		aura:getOwner():detachAura(aura);
	else
		avatar = getPlayerAvatar();
		applyDamageWithWeapon(avatar, aura:getTarget(), weaponProtect);
	end
end

function onTickUnProtected(aura)
	if aura:getElapsed() > poisonduration then
		aura:getOwner():detachAura(aura);
	else
		avatar = getPlayerAvatar();
		applyDamageWithWeapon(avatar, aura:getTarget(), weapon);
	end
end