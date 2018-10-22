require 'scripts/avatars/common'

local avatar = nil;
local weapon = "weapon_shrubby_bloodvine";
local bWidth = 120;
local heal_per_target = 30;
local weaponRange = 0;
local startPos = nil;
local targetsSet = false;
function onUse(a)
	avatar = a;
	--playAnimation(avatar, "ability_project_2H");
	playAnimation(avatar, "stomp");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	weaponRange = getWeaponRange(weapon);
	local beamWidth = bWidth;

	local view = avatar:getView();

	startPos = avatar:getWorldPosition();
	local beamFacing = avatar:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(startPos, weaponRange, beamFacing);
	local targets = getTargetsInBeam(startPos, beamEnd, beamWidth, targetFlags);
	local hastargets = false;
	for t in targets:iterator() do
		if not isSameEntity(t, avatar) then
			local aura = createAura(this, t, 0);
			aura:setTickParameters(0.2, 0);
			aura:setScriptCallback(AuraEvent.OnTick, "onTick");
			aura:setTarget(t);
			hastargets = true;
		end
	end
	if hastargets then
		playSound("shrubby_ability_BloodVine_explosion");
	end
	targetsSet = true;
	playSound("shrubby_ability_BloodVine");
	startCooldown(avatar, abilityData.name);	
end

function onTick(aura)
	if targetsSet then
		avatar = getPlayerAvatar();
		local t = aura:getTarget();
		local pos = t:getWorldPosition();
		local d = getDistanceFromPoints(pos, startPos);
		local e = weaponRange * aura:getElapsed();
		if d < e then
			createImpactEffectFromPage(weapon,pos,0);
			if canTarget(t) then
				if not getEntityType(t) == EntityType.Zone then
					local lifeleft = t:getStat("Health");
					local heal = heal_per_target;
					if heal > lifeleft then
						heal = lifeleft;
					end
					avatar:gainHealth(heal);
				end
				applyDamageWithWeapon(avatar, t, weapon);
			end
			aura:getOwner():detachAura(aura);
		end
	end
end