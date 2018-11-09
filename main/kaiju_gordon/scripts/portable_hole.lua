local pickupRatio = 0.1;
function onSet(a)
	kaiju = a;
	kaiju:addPassive("portable_hole", pickupRatio);
end
	