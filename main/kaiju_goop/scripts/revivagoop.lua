reviveTime = 15;
reviveHealthThresh = 0.25;

function onSet(a)
	a:setPassive("goop_revive_active", 0);
	a:setPassive("goop_revive_timer", reviveTime);
	a:setPassive("goop_revive_min_health", reviveHealthThresh);
end