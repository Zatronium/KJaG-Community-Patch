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
