require 'kaiju_goop/scripts/goop_common'

local target = nil;
local kaiju = nil;
local reviveChance = 0;
local spawnGoop = 0;
local regen = 0;

local initialSetup = false
local setupFinished = false

-- Entity control logic goes in here. Heartbeats happen every
-- 0.5 seconds, so we have to create an attack aura that ticks
-- faster so we can spam shots.
function doSpawnSetup(v)
	initialSetup = true
	target = nil;
	kaiju = getPlayerAvatar();
	local maxHp = v:getStat("MaxHealth") + (kaiju:hasPassive("minion_health_bonus_flat"));
	v:setStat("MaxHealth", maxHp);
	v:setStat("Health", maxHp);
	
	v:setStat("ExtraDamage_Fire", 0.2);
	v:setStat("ExtraDamage_Cold", 0.2);
	
	regen = kaiju:hasPassive("minion_health_regen");
	if regen > 0 then
		scriptAura = Aura.create(this, v);
		scriptAura:setTag('goopling_heal');
		scriptAura:setScriptCallback(AuraEvent.OnTick, 'onHealTick');
		scriptAura:setTickParameters(1, 0); --updates at time 0 then at time 20
		scriptAura:setTarget(v); -- required so aura doesn't autorelease
	end
	
	reviveChance = kaiju:hasPassive("minion_revive_chance");
	spawnGoop = kaiju:hasPassive("minion_spawn_goop");
	
	kaiju:addMinion(v);
	setupFinished = true
end

function onHealTick(aura)
	if not aura then
		return
	end
	local self = aura:getOwner();
	if not self then
		scriptAura = nil return
	end
	self:modStat("Health", regen);
end

function onHeartbeat(v)
	if not initialSetup then
		doSpawnSetup(v)
	end
	if not setupFinished or combatEnded() then
		return
	end
		
	local minion = entityToMinion(v);
	target = minion:findTarget(1000);
	setTarget(v, target);
	local pdChance = v:getStat("PD_Tracking");
	local vc = v:getControl();
	if canTarget(target) then
		local distance = getDistance(v, target);
		local weaponRange = v:getMinWeaponRange();
		if distance < weaponRange * 0.75 and isLineOfSight(v, target ) then
			-- kaiju in range and LoS, stop movement and create attack aura.
			vc:stop();
		else
			-- Try to get in range.
			vc:directMove(target:getWorldPosition());
		end
	else
		vc:stop();
	end
end


function setTarget(v, t)
	local ftarget = t;
	if v:isDisabled() then
		ftarget = nil;
	end
	
	if not canTarget(ftarget) then	
		ftarget = nil;
	end

	local turrets = v:getAttachedEntities(EntityType.Turret);		
	for tur in turrets:iterator() do
		turret = entityToTurret(tur);
		turret:setTarget(ftarget);
	end

end

function onStatChanged(e, stat, prev, val)
	if stat == "Health" then
		local maxHealth = e:getStat("MaxHealth");
		if val <= 0 and reviveChance > 0 and reviveChance > randomFloat(0, 1) then
			e:setStat("Health", maxHealth);
			local pos = e:getWorldPosition()
			-- revive effects here
			createEffectInWorld("effects/goopball_splortsplash.plist", pos, 0);
			createEffectInWorld("effects/goopball_splort.plist", pos, 0);
			--reviveBlob = CreateBlob(pos, spawnGoop, spawnGoop);	
		elseif val > maxHealth then
			e:setStat("Health", maxHealth);
		end
	end
end

function onDeath(self)
	local view = self:getView()
	local pos = view:getPosition();	
	local worldpos = self:getWorldPosition();
	view:setVisible(false);
	removeEntity(self);
	
	playSound("explosion");
	createEffect('effects/explosion_BoomLayer.plist', pos);
	createEffect('effects/explosion_SmokeLayer.plist', pos);
	createEffect('effects/explosion_SparkLayer.plist', pos);
	createEffect('effects/explosion_SparkFireLayer.plist', pos);
	
	if spawnGoop > 0 then
		createEffectInWorld("effects/goopball_splortsplash.plist", worldpos, 0);
		createEffectInWorld("effects/goopball_splort.plist", worldpos, 0);
		CreateBlob(worldpos, spawnGoop, spawnGoop);
	end
end