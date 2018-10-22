local speedRatio = 1.0;
function onSet(a)
	avatar = a;
	avatar:addPassive("overload", speedRatio);
end
	