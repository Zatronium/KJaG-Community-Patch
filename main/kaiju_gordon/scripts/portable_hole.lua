local pickupRatio = 0.1;
function onSet(a)
	avatar = a;
	avatar:addPassive("portable_hole", pickupRatio);
end
	