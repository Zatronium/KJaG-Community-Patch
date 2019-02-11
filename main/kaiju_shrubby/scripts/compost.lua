local HealthOrganicRatio = 1.0 -- 100 hp = 100 Orgainc

function onSet(a)
	a:setPassive("compost", HealthOrganicRatio);
end