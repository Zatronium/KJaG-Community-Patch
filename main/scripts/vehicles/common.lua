local kVisibilityRange = 1000.0;
local kVisibilityRangeFuzzy = 200.0;
local kAttackRange = 600.0;


function setTarget(v, t)
	local target = t;
	if v:isDisabled() then
		target = nil;
	end
	
	if not canTarget(target) then	
		target = nil;
	end

	if not v:hasAura("BLIND") then
		local turrets = v:getAttachedEntities(EntityType.Turret);		
		for tur in turrets:iterator() do
			turret = entityToTurret(tur);
			turret:setTarget(target);
		end
	end
end

function defaultStatChanged(e, stat, prev, val)
	if stat == "Health" then
		local maxHealth = e:getStat("MaxHealth");
		if val > e:getStat("MaxHealth") then
			e:setStat("Health", maxHealth);
		end
	end
end

function onStatChanged(e, stat, prev, val)
	defaultStatChanged(e, stat, prev, val);
end
