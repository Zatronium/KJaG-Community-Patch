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
	local damageAmp = 1 + avatar:hasPassive("seed_damage_bonus");
	v:setStat("damage_amplify", damageAmp);
	local damageZone = 1 + avatar:hasPassive("seed_damage_zone_bonus");
	v:setStat("damage_zone_amplify", damageZone);
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
	target = minion:findTarget(0);
	setTarget(v, target);
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

