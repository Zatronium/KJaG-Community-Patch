local bonusCDR = 0.25
local minOrganic = 0.75

function onSet(a)
	a:setPassive("wild_growth_cdr", bonusCDR);
	a:setPassive("wild_growth_organic", minOrganic);
end