----------------------------------
---THIS SECTION IS NOT FINISHED---
----------------------------------

----------------------------------
-----------Syntax Guide-----------
----------------------------------

--newAura({
-------------Required-------------
--	script		= source script
--  name		= aura name; must be a unique name
-------------Optional-------------
--	event		= the AuraEvent to use when creating a new aura; defaults to AuraEvent.OnTick
--	onEvent		= this function is called when the aura event occurs
--	onRemove	= this function is called when the aura ends or is removed by removeAura()
--	useName		= if true, uses the name field to create a tag which can be searched in other scripts via entity:getAura('name')
--	owner		= assigns an owner to the aura; defaults to the kaiju
--	interval	= assigns an interval to the aura; must be a number larger than 0, otherwise event, onEvent, onRemove, and duration parameters will be ignored
--	duration	= assigns a duration to the aura; defaults to 0, which means forever
--	target		= assigns a target to the aura; apparently the aura is supposed to "autorelease" if the aura has no target, but the game never checks if the target is valid
--})

------------An Example------------
--local myNewAura = newAura({
--	script		= this,
--	name		= 'test_aura',
--	onEvent		= onTick,
--	useName		= true,
--	interval	= 5,
--})

-- We've created a new aura which
---- uses the current script,
---- has the name 'test_aura' (the actual name doesn't include apostrophes, that is Lua's string syntax),
---- uses the onTick function as its event callback
---- creates an aura tag for scripts to reference
---- ticks every 5 seconds

-- It also automatically
---- uses AuraEvent.OnTick
---- has no onRemove function
---- uses the kaiju as the owner
---- has infinite duration
---- uses the kaiju as the target

----------------------------------
---------Syntax Guide End---------
----------------------------------

local AuraBacker 				= {}

function newAura(data)
	if not data.owner then
		data.owner = getPlayerAvatar()
	end
	if not data.event then
		data.event = AuraEvent.OnTick
	end
	if not data.duration then
		data.duration = 0 -- forever
	end
	if not data.target then
		data.target = data.owner
	end
	
	AuraBacker[data.name] = {}
	local backer = AuraBacker[data.name]
	
	backer.aura = Aura.create(data.script, data.owner)
	
	backer.data = {
		script		= data.script, 
		owner		= data.owner,
		name		= data.name,
		event		= data.event,
		onEvent		= data.onEvent,
		onRemove	= data.onRemove,
		duration	= data.duration,
		interval	= data.interval,
		target		= data.target
	}
	
	backer.isValid = true
	
	if data.useName and data.name then
		backer.aura:setTag(data.name)
	end
	if data.onEvent and data.interval and data.interval > 0 then
		backer.aura:setScriptCallback(data.event, data.name)
		backer.aura:setTickParameters(data.interval, data.duration)
	end
	backer.aura:setTarget(data.target)
	backer.changeOwner = changeOwner
	return backer
end

function removeAura(aura)
	
end

local function changeOwner(backer, owner)
	if not backer.isValid then return end
	
end

local function doEvent(backer)
	if not backer.isValid then return end
	if not backer.aura:getOwner() or not backer.aura:getTarget() then
		backer.isValid = nil
		return
	end
	AuraBacker.onEvent()
end

-------------------------
---END UNFINISHED CODE---
-------------------------

---------------
---Targeting---
---------------

---
--- Automated target scanning for only the most refined warmongers.
---

function getTargetInEntityRadius(scannerEntity, radius, entityFlags, targetFlags, firingArc)
	local location 			= scannerEntity:getWorldPosition()
	local kaiju 			= getPlayerAvatar()
	local scannerIsKaiju 	= isSameEntity(scannerEntity, kaiju)
	local lairAttack		= isLairAttack()
	local scannerEntityType = getEntityType(scannerEntity)
	if not radius then
		radius = 10000.0
	end
	local newTargets = getTargetsInRadius(location, radius, entityFlags)
	for t in newTargets:iterator() do
		if t and canTarget(t) and not isSameEntity(t, scannerEntity) then
			local targetEntityType	= getEntityType(t)
			local isOnWater			= isEntityOnWater(t)
			local targetIsKaiju		= isSameEntity(t, kaiju)
			local isAirUnit			= (targetEntityType == EntityType.Vehicle and entityToVehicle(t):isAir())
			if not (not targetFlags.Player and targetIsKaiju) and ((targetFlags.Player and (targetIsKaiju or targetEntityType == TargetType.Minion)) or (targetFlags.Sea and isOnWater) or (targetFlags.Land and not isAirUnit) or (targetFlags.Air and isAirUnit) or (targetFlags.Buildable and t:hasStat('BuildTime'))) then
				local targetAngleRelativeToEntity = nil
				if firingArc and scannerEntityType == EntityType.Avatar then
					targetAngleRelativeToEntity = getFacingAngle(location, t:getWorldPosition()) - kaiju:getWorldFacing()
					if targetAngleRelativeToEntity < 0 then
						targetAngleRelativeToEntity = 0 - targetAngleRelativeToEntity
					end
				end
				
				if (not targetAngleRelativeToEntity or targetAngleRelativeToEntity <= firingArc / 2)
				and not (lairAttack and scannerIsKaiju and targetEntityType == EntityType.Zone) then
					return t
				end
			end
		end
	end
end

function getTargetInPointRadius(location, radius, entityFlags, targetFlags)
	if not radius then
		radius = 10000.0
	end
	local newTargets = getTargetsInRadius(location, radius, entityFlags)
	for t in newTargets:iterator() do
		if t and canTarget(t) then
			local targetEntityType	= getEntityType(t)
			local isOnWater			= isEntityOnWater(t)
			local isAirUnit			= (targetEntityType == EntityType.Vehicle and entityToVehicle(t):isAir())
			if (targetFlags.Player and isSameEntity(t, getPlayerAvatar())) or (targetFlags.Sea and isOnWater) or (targetFlags.Land and not isAirUnit) or (targetFlags.Air and isAirUnit) or (targetFlags.Buildable and t:hasStat('BuildTime')) then
				return t
			end
		end
	end
end

--Mimics EntityFlags
TargetType = {Land = 'Land', Sea = 'Sea', Air = 'Air', Player = 'Player', Buildable = 'Buildable'}
function TargetFlags(...)
	local arr = {}
	for i=1,5 do
		local var = select(i, ...)
		if var then
			arr[var] = true
		end
	end
	return arr
end

-------------------
---End Targeting---
-------------------

-------------------
---Weapon Firing---
-------------------

---
--- The built-in projectile gens are fairly arbitrary, especially "fireProjectileAtTarget," which always uses Point(0,0) for some reason.
--- I guess it's an offset for the firing unit but none of the code ever uses said offset. More importantly, why doesn't the target have an offset?
--- I could see a target offset being more useful, such as for a bomb that explodes overhead and rains down shrapnel.
---
--- fireFromTarget/fireFromPoint is an optional boolean parameter. You can pass only the first four parameters and the function will still work.
---
--- These functions assume your code has already validated the target. Do not pass nil targets!
---

function fireWeaponWithTarget(self, target, weapon, callback, fireFromTarget)
	local targetPos = target:getWorldPosition()
	local proj = nil
	if fireFromTarget then
		proj = fireProjectileAtTarget(target, self, Point(0,0), targetPos, weapon);
	else
		proj = fireProjectileAtTarget(self, target, targetPos, Point(0,0), weapon);
	end
	proj:setCallback(this, callback);
	return proj
end

function fireWeaponWithPoint(self, point, weapon, callback, fireFromPoint)
	local firePos = self:getWorldPosition()
	local proj = nil
	if fireFromPoint then
		proj = fireProjectileAtPoint(self, point, firePos, weapon);
	else
		proj = fireProjectileAtPoint(self, firePos, point, weapon);
	end
	proj:setCallback(this, callback);
	return proj
end

function waterCheckMidpoint(self, point)
	local firePos = self:getWorldPosition()
	firePos.x = (firePos.x + point.x) / 2
	firePos.y = (firePos.y + point.y) / 2
	proj = fireProjectileAtPoint(self, firePos, point, 'nullweapon')
	proj:setCallback(this, 'fakeCallback') -- ... Seriously?
	return isEntityOnWater(proj)
end

function fakeCallback()
end

-----------------------
---End Weapon Firing---
-----------------------