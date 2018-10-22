local pointdefenserate = 15;
function onSet(a)
	if a:hasStat("PD_Tracking") then
		a:modStat("PD_Tracking", pointdefenserate);
	else
		a:addStat("PD_Tracking", pointdefenserate);
	end
end