require 'scripts/abstraction'

-- Play animation then return to idle.
function playAnimation(a, anim)
	local v = a:getView();
	v:setAnimation(anim, false);
	v:addAnimation("idle", true);
end

-- Convenience construction of EntityFlags.
function EntityFlags(...)
	local entityFlags = kaiju.EntityFlags();
	for i,v in ipairs({...}) do
		entityFlags:add(v);
	end
	return entityFlags;
end

-- Check for resource amount.
function hasResource(a, stat, val)
	if a:hasStat(stat) then
		local res = a:getStat(stat);
		return res >= val;
	end
	
	return false;
end

-- Returns true if resource avail and deducts the amount.
function consumeResource(a, stat, val)
	if a:hasStat(stat) then
		local res = a:getStat(stat);
		res = res - val;
		a:setStat(stat, res);
		return true;
	end
	
	return false;
end

-- Returns true if resource gained
function gainResource(a, stat, val)
	if a:hasStat(stat) then
		local res = a:getStat(stat);
		res = res + val;
		a:setStat(stat, res);
		return true;
	end
	
	return false;
end

