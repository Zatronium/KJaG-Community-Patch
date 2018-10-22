local reducedarmorPen = 0.33
function onSet(a)
	if a:hasStat("reduce_armor_pen_percent") then
		a:modStat("reduce_armor_pen_percent", reducedarmorPen);
	else
		a:addStat("reduce_armor_pen_percent", reducedarmorPen);
	end
end