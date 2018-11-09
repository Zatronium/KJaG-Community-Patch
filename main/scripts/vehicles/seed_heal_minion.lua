require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

local kaiju = nil;
local rangeAmp = 1;

local initialSetup = false
local setupFinished = false

function doSpawnSetup(v)
	initialSetup = true
	kaiju = getPlayerAvatar()
	local maxHp = v:getStat("MaxHealth") * (1 + kaiju:hasPassive("seed_health_bonus"));
	v:setStat("MaxHealth", maxHp);
	v:setStat("Health", maxHp);
	rangeAmp = 1 + kaiju:hasPassive("seed_range_bonus");
	v:setStat("range_amplify", rangeAmp);	
	
	v:setStat("ExtraDamage_Fire", 1);
	v:setStat("ExtraDamage_Gas", -1);
	
	kaiju:addMinion(v);
	setupFinished = true
end

function onHeartbeat(v)
	if not initialSetup then
		doSpawnSetup(v)
	end
	if not setupFinished or combatEnded() then
		return
	end
	local minion = entityToMinion(v);
	local target = minion:getTarget();	
	
	local seedBaseRange = v:getMinWeaponRange() * (rangeAmp);

	if not canTarget(target) or not isLineOfSight(minion, target) or target:getStat("Health") == target:getStat("MaxHealth") then
		target = nil;
		if kaiju:getStat("Health") < kaiju:getStat("MaxHealth") then
			if getDistance(kaiju, minion) < seedBaseRange and isLineOfSight(minion, kaiju) then
				target = kaiju;
			end
		end
		if not target then
	--		local closest = seedBaseRange;
			local hpMissing = 0;
			local minions = kaiju:getMinions();
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
	local view = self:getView()
	view:setVisible(false);
	removeEntity(self);
	if not kaiju then
		return
	end
	local detonate = kaiju:hasPassive("seed_detonate_range");
	if detonate > 0 then
		local pos = view:getPosition();
		createEffect('effects/seedling_detonate1.plist', pos);
		createEffect('effects/seedling_detonate2.plist', pos);
		local targets = getTargetsInRadius(self:getWorldPosition(), detonate, EntityFlags(EntityType.Vehicle, EntityType.Avatar, EntityType.Zone));
		for t in targets:iterator() do
			if canTarget(t) and not isSameEntity(kaiju, t) then
				applyDamage(kaiju, t, kaiju:hasPassive("seed_detonate_damage"));
			end
		end
	end
end