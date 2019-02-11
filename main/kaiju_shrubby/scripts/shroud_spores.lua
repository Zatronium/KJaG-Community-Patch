local pointdefenserate = 25
local bonusSensory = -10

function onSet(a)
	if a:hasStat("PD_Tracking") then
		a:modStat("PD_Tracking", pointdefenserate)
	else
		a:addStat("PD_Tracking", pointdefenserate)
	end
	local view = a:getView()
	view:attachEffectToNode("root", "effects/sporeShroud.plist", -1, 0, 0, true, false)
	view:attachEffectToNode("root", "effects/sporeShroudCloud.plist", -1, 0, 0, true, false)
end

function bonusStats(s)
	s:modStat("SensorsSignature", bonusSensory)
end