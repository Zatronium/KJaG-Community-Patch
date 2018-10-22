
function onUse(a)
	if a:resetLowestCooldown() then 
		abilityEnabled(a, "Overclock", false);
		local view = a:getView();
		view:attachEffectToNode("root", "effects/forcedPriority_pulseBackUp.plist", 0, 0,0, false, true);
		view:attachEffectToNode("root", "effects/forcedPriority_pulseBackDown.plist", 0, 0,0, false, true);
		view:attachEffectToNode("root", "effects/forcedPriority_auraBackUp.plist", 0, 0,0, false, true);
		view:attachEffectToNode("root", "effects/forcedPriority_auraBackDown.plist", 0, 0,0, false, true);
		view:attachEffectToNode("root", "effects/forcedPriority_pulseFrontUp.plist", 0, 0,0, true, false);
		view:attachEffectToNode("root", "effects/forcedPriority_pulseFrontDown.plist", 0, 0,0, true, false);
		view:attachEffectToNode("root", "effects/forcedPriority_auraFrontUp.plist", 0, 0,0, true, false);
		view:attachEffectToNode("root", "effects/forcedPriority_auraFrontDown.plist", 0, 0,0, true, false);
		startCooldown(a, abilityData.name);
	end
end
