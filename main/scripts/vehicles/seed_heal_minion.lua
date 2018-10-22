require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

local target = nil;
local avatar = nil;
local rangeAmp = 1;
function onSpawn(v)
	target = nil;
	avatar = getPlayerAvatar();
	local maxHp = v:getStat("MaxHealth") * (1 + avatar:hasPassive("seed_health_bonus"));
	v:setStat("MaxHealth", maxHp);
	v:setStat("Health", maxHp);
	rangeAmp = 1 + avatar:hasPassive("seed_range_bonus");
	v:setStat("range_amplify", rangeAmp);	
	
	v:setStat("ExtraDamage_Fire", 1);
	v:setStat("ExtraDamage_Gas", -1);
	
	avatar:addMinion(v);
end

function onHeartbeat(v)
	if combatEnded() then
		return;
	end
	local minion = entityToMinion(v);
	target = minion:getTarget();	
	
	local seedBaseRange = v:getMinWeaponRange() * (rangeAmp);

	if not canTarget(target) or not isLineOfSight(minion, target) or target:getStat("Health") == target:getStat("MaxHealth") then
		target = nil;
		avatar = getPlayerAvatar();
		if avatar:getStat("Health") < avatar:getStat("MaxHealth") then
			if getDistance(avatar, minion) < seedBaseRange and isLineOfSight(minion, avatar) then
				target = avatar;
			end
		end
		if not target then
	--		local closest = seedBaseRange;
			local hpMissing = 0;
			local minions = avatar:getMinions();
			for t in minions:iterator() do
				local m = entityToMinion(t);
				local dist = getDistance(m, minion);
				local maxh = m:getStat("MaxHealth");
				local curh = m:getStat("Health");
				local hpDiff =  maxh - curh;
				if m:isHealable() and dist < seedBaseRange and isLineOfSight(minion, m) and hpMissing < hpDiff then
	--				closest = dist;
					hpMissing = hpDiff;
					target = m;
				end
			end
		end
	end
	
	setTarget(v, target);
	if target then
		local distanceFromTarget = getDistance(v, target);
		if distanceFromTarget > seedBaseRange then
			setTarget(v, nil);
		end
	end
end

function onDeath(self)
	self:getView():setVisible(false);
	removeEntity(self);
	avatar = getPlayerAvatar();
	if not avatar then
		return;
	end
	local detonate = avatar:hasPassive("seed_detonate_range");
	if detonate > 0 then
		local pos = self:getView():getPosition();
		createEffect('effects/seedling_detonate1.plist', pos);
		createEffect('effects/seedling_detonate2.plist', pos);
		local targets = getTargetsInRadius(self:getWorldPosition(), detonate, EntityFlags(EntityType.Vehicle, EntityType.Avatar, EntityType.Zone));
		for t in targets:iterator() do
			if canTarget(t) and not isSameEntity(avatar, t) then
				applyDamage(avatar, t, avatar:hasPassive("seed_detonate_damage"));
			end
		end
	end
end