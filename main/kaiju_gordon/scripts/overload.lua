local speedRatio = 1.0;
function onSet(a)
	kaiju = a;
	kaiju:addPassive("overload", speedRatio);
end
	