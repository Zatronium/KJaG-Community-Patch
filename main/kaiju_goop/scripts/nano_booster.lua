cooldownPercent = 0.15
function onSet(a)
	if(a:hasStat("CoolDownReductionPercent"))then
		a:modStat("CoolDownReductionPercent", cooldownPercent);
	else
		a:addStat("CoolDownReductionPercent", cooldownPercent);
	end
end