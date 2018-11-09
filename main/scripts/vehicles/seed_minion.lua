require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

local kaiju = nil
local rangeAmp = 1;

local initialSetup = false
local setupFinished = false

function doSpawnSetup(v)
	initialSetup = true
	kaiju = getPlayerAvatar()
	local maxHp = v:getStat("MaxHealth") * (1 + kaiju:hasPassive("seed_health_bonus"));
	v:setStat("MaxHealth", maxHp);
	v:setStat("Health", maxHp);
	local damageAmp = 1 + kaiju:hasPassive("seed_damage_bonus");
	v:setStat("damage_amplify", damageAmp);
	local damageZone = 1 + kaiju:hasPassive("seed_damage_zone_bonus");
	v:setStat("damage_zone_amplify", damageZone);
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
	local target = minion:findTarget(0);
	setTarget(v, target);
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

