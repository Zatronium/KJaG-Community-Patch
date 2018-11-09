local thresh = 0.75;
local cdrBonus = 0.2;

function onSet(a)
	a:addPassive("goop_energoop_thresh", thresh);
	a:addPassive("goop_energoop_cdr", cdrBonus);
end