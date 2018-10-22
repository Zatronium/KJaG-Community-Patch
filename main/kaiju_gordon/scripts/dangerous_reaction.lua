local damageRatio = 1;

function onSet(a)
	a:addPassive("dangerous_reaction", damageRatio);
end
	