----------
---Aura---
----------

----------------------------------
-----------Syntax Guide-----------
----------------------------------

--[===[

newAura({
-------------Required-------------
	script		= source script
	name		= aura name; must be a unique name. This is because this is automatically used as the aura's tag.
-------------Optional-------------
	event		= the AuraEvent to use when creating a new aura; defaults to AuraEvent.OnTick
	onEvent		= this function is called when the aura event occurs
	onRemove	= this function is called when the aura ends or is removed by removeAura()
	owner		= assigns an owner to the aura; defaults to the kaiju
	interval	= assigns an interval to the aura; must be a number larger than 0, otherwise event, onEvent, onRemove, and duration parameters will be ignored
	duration	= assigns a duration to the aura; defaults to 0, which means forever
	delay		= assigns a delay to the aura; defaults to 0, which means no delay before the aura triggers
	target		= assigns a target to the aura; defaults to the aura owner. Note: Apparently the aura is supposed to "autorelease" if the aura has no target, but the game never checks if the target is valid
})

------------An Example------------
local myNewAura = newAura({
	script		= this,
	name		= 'test_aura',
	onEvent		= onTick,
	interval	= 5,
})

We've created a new aura which:
	* uses the current script,
	* has the name 'test_aura' (the actual name doesn't include apostrophes, that is Lua's string syntax),
	* uses the onTick function as its event callback
	* creates an aura tag for scripts to reference
	* ticks every 5 seconds

It also automatically:
	* uses AuraEvent.OnTick
	* has no onRemove function
	* uses the kaiju as the owner
	* has infinite duration
	* uses the kaiju as the target

--]===]

----------------------------------
---------Syntax Guide End---------
----------------------------------

-- Init organizing array
local AuraBacker 				= {}

--Create a new aura; MUST follow syntax guide.
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
	
	local backer = {}
	
	backer.aura = Aura.create(data.script, data.owner)
	backer.data = data
	backer.ticks = 0
	
	backer = setupBacker(backer)
	AuraBacker[data.name] = backer
	
	return backer
end

-- Auras work by getting their data from the script they are assigned, which typically is a script attached to the owner
-- This convention isn't required but it helps keep the aura's callback consistent; a nil callback will crash the game
-- script is an optional parameter which allows you to either assign a new script or keep the original script when assigning a new owner
function changeAuraOwner(backer, owner, script)
	if not backer.isValid or not owner or not backer.name or (not backer.script and not script) then return end
	
	backer.isValid = nil
	
	local newBacker = {}
	if not script then
		newBacker.aura = Aura.create(backer.script, owner)
	else
		newBacker.aura = Aura.create(script, owner)
	end
	
	if isSameEntity(backer.target, backer.owner) then
		backer.target = owner
	end
	
	newBacker.data = backer.data
	newBacker.data.owner = owner
	newBacker.ticks = backer.ticks
	
	newBacker = setupBacker(newBacker)
	AuraBacker[newBacker.data.name] = newBacker
	
	return newBacker
end

local function setupBacker(backer)
	local data = backer.data
	backer.aura:setTag(data.name)
	backer.eventCallbackName = nil
	if data.onEvent and data.interval and data.interval > 0 and data.duration then
		backer.eventCallbackName = table.concat({data.name, "_scriptCallback"})
	
			-- Inject error-checking code into aura callbacks
			-- This obviates the need to explicitly error-check every single aura and prevents the game from crashing due to nil callbacks;
			-- The aura's callback will always at least contain error-checking code even if the onEvent callback is somehow nil.
			
		local func = {}
		func[1] = [[return function() local auraName = ]]
			-- We assemble the name here because this dumps the aura's name directly into the function
			-- The game normally cannot pass more than the aura itself via setScriptCallback() because it's looking for a function name rather than executable code (stupid)
			-- This bypasses the problem of every invalid aura returning a nil table reference
		func[2] = data.name
		func[3] = [=[ 	local backer = AuraBacker[auraName] 
						local aura = backer.aura
						if not aura or not aura:getOwner() then
							backer.isValid = false 
							logError('Aura ', auraName, ' terminated abnormally at onEvent.\n\tAssigned owner: ', tostring(backer.data.owner), '\n\tAssigned target: ', tostring(backer.data.target), '\n\tAura dump:\n\n', tostring(aura))
							return 
						end 
						backer.ticks = backer.ticks + 1
						if _G[]=]
		func[4] = 		data.onEvent
		func[5] =		[=[] then ]=]
		func[6] =			data.onEvent
		func[7] = 		[[(aura) else
							backer.isValid = false 
							logError('Aura ', auraName, ' encountered a nil onEvent function. \n\tAssigned owner: ', tostring(backer.data.owner), '\n\ttAssigned target: ', tostring(backer.data.target))
							return 
						end
					end]]
		_G[backer.eventCallbackName] = select(2, pcall(load(table.concat(func))))
		backer.aura:setScriptCallback(data.event, backer.eventCallbackName)
		if data.duration > 0 then
			if backer.ticks > 0 then
				data.duration = data.duration - backer.ticks * data.interval
			end
			backer.aura:setTickParameters(data.interval, data.duration + 1)
			backer.terminationAura = Aura.create(data.script, data.owner)
			
			backer.eventTerminationName = table.concat({data.name, "_terminationCallback"})
			-- yup, all we do is tack on 'removeAura(aura)' and recompile the table
			-- This is why I prefer table.concat
			func[7] = 		[[(aura) else
							backer.isValid = false 
							logError('Aura ', auraName, ' encountered a nil onEvent function. \n\tAssigned owner: ', tostring(backer.data.owner), '\n\tAssigned target: ', tostring(backer.data.target))
							return 
						end
						removeAura(aura)
					end]]
			_G[backer.eventTerminationName] = select(2, pcall(load(table.concat(func))))
			backer.terminationAura:setScriptCallback(data.event, backer.eventTerminationName)
			backer.terminationAura:setTickParameters(data.interval, data.duration)
			backer.terminationAura:setTarget(data.target)
		else
			backer.aura:setTickParameters(data.interval, 0)
		end
	end
	backer.removeCallbackName = nil
	if data.onRemove then
		backer.removeCallbackName = table.concat({data.name, "_removeCallback"})
		local func = {}
		func[1] = [[return function() local auraName = ]]
		func[2] = data.name
		func[3] = [=[ 	local backer = AuraBacker[auraName] 
						local aura = backer.aura 
						if not aura or not aura:getOwner() then 
							backer.isValid = false 
							logError('Aura ', auraName, ' terminated abnormally at onRemove.\n\tAssigned owner: ', backer.data.owner, '\n\tAssigned target: ', backer.data.target)
							return 
						end 
						backer.ticks = backer.ticks + 1]=]
		func[4] = 		data.onRemove
		func[5] =		[[(aura)
					end]]
		_G[backer.removeCallbackName] = select(2, pcall(load(table.concat(func))))
	end
	backer.aura:setTarget(data.target)
	backer.isValid = true
	return backer
end

--Can remove aura by passing the aura, passing the aura's name, or by passing the aura's backer table.
function removeAura(aura)
	local backer = nil
	if aura and aura.getTag then
		auraName = aura:getTag()
	elseif type(aura) == "string" and AuraBacker[aura] then 
		backer = AuraBacker[aura]
	elseif aura and aura.data and aura.data.name then
		backer = AuraBacker[aura.data.name]
	end
	if not auraName then
		logError('The data is not a valid aura or aura backer table.\n\tData passed to the removeAura() function:\n\n', tostring(aura))
		return
	end
	
	backer.isValid = nil
	
	if backer.aura then
		--Swap with empty callback to avoid nil callback
		backer.aura:setScriptCallback(backer.data.event, 'fakeCallback')
		backer.aura:setTickParameters(1, 1) -- Expire on next tick in case of nil owner
		if backer.owner then
			owner:detachAura(backer.aura)
		end
	end

	if backer.removeCallbackName then
		if not _G[backer.removeCallbackName] then
			logError('Aura ', auraName, ' encountered a nil onRemove() function. \n\tOwner: ', backer.owner, '\n\tTarget: ', backer.target)
		else
			_G[backer.removeCallbackName]()
		end
		_G[backer.removeCallbackName] = nil --cleanup global table
	end
	if backer.eventCallbackName then
		_G[backer.eventCallbackName] = nil --cleanup global table
		
		--Swap with empty callback to avoid nil callback
		if backer.terminationAura then
			backer.terminationAura:setScriptCallback(backer.data.event, 'fakeCallback')
			if backer.eventTerminationName then
				_G[backer.eventTerminationName] = nil --cleanup global table
			end
		end
	end
	
	backer = nil --cleanup AuraBacker table (beware, this sets the table indice to nil)
end

--------------
---End Aura---
--------------

-------------------
---Value Passing---
-------------------

---
--- Framework to pass values among units
---

local ZeroMQ = nil

function enableCommunication()
	if not ZeroMQ then
		ZeroMQ = require "zmq"
		print(tostring(ZeroMQ))
		--print("Current 0MQ version is " .. table.concat(ZeroMQ.version(), '.'))
	end
	return ZeroMQ
end


--[=[--Essentially we just attach useless stats to the aura to ensure we aren't altering anything important in-game.
local auraStream = {}



function requestInteger(entity)
	
end

function requestString(entity)

end

function sendString(entity)

end--]=]


-----------------------
---End Value Passing---
-----------------------

---------------
---Targeting---
---------------

---
--- Automated target scanning for only the most refined warmongers.
---

function getTargetInEntityRadius(scannerEntity, radius, entityFlags, targetFlags, firingArc)
	local canTarget_L		= canTarget
	local isSameEntity_L	= isSameEntity
	local getEntityType_L	= getEntityType
	local getFacingAngle_L	= getFacingAngle
	local isEntityOnWater_L	= isEntityOnWater

	local location 			= scannerEntity:getWorldPosition()
	local kaiju 			= getPlayerAvatar()
	local scannerIsKaiju 	= isSameEntity_L(scannerEntity, kaiju)
	local lairAttack		= isLairAttack()
	local scannerEntityType = getEntityType_L(scannerEntity)
	if not radius then
		radius = 10000.0
	end
	local newTargets = getTargetsInRadius(location, radius, entityFlags)
	for t in newTargets:iterator() do
		if t and canTarget(t) and not isSameEntity_L(t, scannerEntity) then
			local targetEntityType	= getEntityType_L(t)
			local isOnWater			= isEntityOnWater_L(t)
			local targetIsKaiju		= isSameEntity_L(t, kaiju)
			local isAirUnit			= (targetEntityType == EntityType.Vehicle and entityToVehicle(t):isAir())
			if not (not targetFlags.Player and targetIsKaiju) and ((targetFlags.Player and (targetIsKaiju or targetEntityType == TargetType.Minion)) or (targetFlags.Sea and isOnWater) or (targetFlags.Land and not isAirUnit) or (targetFlags.Air and isAirUnit) or (targetFlags.Buildable and t:hasStat('BuildTime'))) then
				local targetAngleRelativeToEntity = nil
				if firingArc and scannerEntityType == EntityType.Avatar then
					targetAngleRelativeToEntity = getFacingAngle_L(location, t:getWorldPosition()) - kaiju:getWorldFacing()
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

-----------------------
---End Weapon Firing---
-----------------------

---------------------
---Stat Management---
---------------------

-- Moved here centralize stats; previously buildings could be infinitely overhealed due to the way common scripts were assigned.
-- This makes it easier to add new features.
function defaultStatChanged(e, stat, prev, val)
	local entityType = getEntityType(e)
	if stat == 'Health' then
		local maxHealth = e:getStat("MaxHealth")
		if val > maxHealth then
			e:setStat("Health", maxHealth)
		elseif entityType == EntityType.Avatar and prev > 0 and val <= 0 then
			e:getView():doDeathEffect()
			print 'Kaiju Dead'
		end
	end
end

function onStatChanged(e, stat, prev, val)
	defaultStatChanged(e, stat, prev, val)
end

-------------------------
---End Stat Management---
-------------------------

--------------------
---Misc Functions---
--------------------

function getFormattedDate()
	local currentDate = os.date("*t")
	local formattedDate = {}
	formattedDate[1] = '[ '
	formattedDate[2] = currentDate.day
	formattedDate[3] = '/'
	formattedDate[4] = currentDate.month
	formattedDate[5] = '/'
	formattedDate[6] = currentDate.year
	formattedDate[7] = ' ]  '
	formattedDate[8] = currentDate.hour
	formattedDate[9] = ':'
	formattedDate[10] = currentDate.min
	formattedDate[11] = ':'
	formattedDate[12] = currentDate.sec
	return table.concat(formattedDate)
end

function logError(...)
	local file = io.open("ScriptError.log", "a")
	io.output(file)
	io.write('\n\n\n--- ', getFormattedDate(), ' ---\n\n', ...)
	io.close(file)
end

function fakeCallback()
end

------------------------
---End Misc Functions---
------------------------