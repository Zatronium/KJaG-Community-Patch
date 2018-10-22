local momentumbonus = 0.05
local momentumcap = 0.25
function onSet(a)
	a:setPassive("momentum", momentumbonus);
	a:setPassive("momentum_cap", momentumcap);
end