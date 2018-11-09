require 'scripts/abstraction'

--Offloads all vehicle traffic control to a common file for easy maintence

local heartbeatCount 		= -1
local patrolChance			= 15
local patrolOrigin			= nil
local aimSoundName			= nil --Unit is stopped and taking aim. Not implemented.
local idleSound				= nil
local idleSoundName			= nil
local revSoundName			= nil
local moveSound				= nil
local moveSoundName			= nil
local spawnFlee 			= false
local soundRangeMultiplier	= 1.25
local vehicleWorldFacing	= 0.0
local isAvoiding			= false
local lastWaypoint			= nil
local currentPatrolWaypoint	= nil
local defaultSnapAngle		= 90.0
local initialSetup			= false
local setupFinished			= false
local target				= nil
local weaponRange			= nil
local closeRange			= nil
local idealRange			= nil
local limitRange			= nil
local farRange				= nil
local vehicleController		= nil
local vehicle				= nil
local vehiclePosition		= nil
local landUnit				= nil
local isSuper				= nil
local isStopped				= true
local distanceFromTarget	= 0.0
local lairAttack			= nil
local kaiju					= nil

function DoSpawnSetup(v, isLandUnit, idle, move, rev)
	initialSetup 		= true
	vehicle 			= v
	weaponRange			= vehicle:getMinWeaponRange()
	closeRange			= math.floor(weaponRange * 0.25)
	idealRange			= math.floor(weaponRange * 0.50)
	limitRange			= math.floor(weaponRange * 0.95)
	farRange			= math.floor(weaponRange * 1.5)
	landUnit			= isLandUnit
	idleSoundName		= idle
	moveSoundName		= move
	revSoundName		= rev
	vehicleController	= vehicle:getControl()
	isSuper				= vehicle:isSuper()
	lairAttack			= isLairAttack()
	kaiju				= getPlayerAvatar()
	setupFinished		= true
end

function InitialSetup()
	return initialSetup
end

function SetupFinished()
	return setupFinished
end

function DoVehicleHeartbeat()
	vehiclePosition 		= vehicle:getWorldPosition()
	if not lairAttack then
		target 				= getTargetInEntityRadius(vehicle, nil, EntityFlags(EntityType.Avatar, EntityType.Minion), TargetFlags(TargetType.Player))
	else
		if isLandUnit and getDistance(vehicle, kaiju) < idealRange then
			target			= kaiju
		else
			target 			= getTargetInEntityRadius(vehicle, nil, EntityFlags(EntityType.Zone), TargetFlags(TargetType.Buildable))
			if not target or getDistance(vehicle, target) > limitRange then
				target 		= getPlayerTarget(vehicle)
			end
			if not target then
				target 		= kaiju
			end
		end
	end
	distanceFromTarget 		= getDistance(vehicle, target)
	local targetPosition 	= target:getWorldPosition()
	
	if heartbeatCount == -1 then
		if  distanceFromTarget < idealRange then
			createEffect('effects/impact_sparksLots.plist', vehicle:getView():getPosition())
			spawnFlee = true
		end
	
		local patrolValue 	= math.random(1, 100)
		if patrolChance >= patrolValue and not isSuper then
			patrolOrigin 	= vehiclePosition
		end
	end
	
	if heartbeatCount >= 6 then
		spawnFlee = false
		heartbeatCount = 0
		isAvoiding = false
		if not isSuper and CheckForTraffic() then
			isAvoiding = true
		end
	end
	heartbeatCount = heartbeatCount + 1
	
	if patrolOrigin and ((isLandUnit and isEntityOnWater(vehicle)) or (not isLandUnit and not isEntityOnWater(vehicle))) then
		patrolOrigin = nil
	end
	
	if canTarget(target) and not isAvoiding then
		local vehicleTarget				= nil
		if distanceFromTarget <= weaponRange and not spawnFlee then
			--If we're in range, target the enemy
			vehicleTarget 				= target
		end
		
		if distanceFromTarget < closeRange or (distanceFromTarget < idealRange and spawnFlee) then
			-- Too close. Flee!
			local direction 			= getFacingAngle(targetPosition, vehiclePosition)
			local desiredRange			= idealRange
			if spawnFlee then
				desiredRange 			= limitRange
			end
			local desiredPosition 		= getBeamEndWithFacing(targetPosition, desiredRange, direction)
			BeginMove(desiredPosition)
			vehicleTarget 				= nil
			isAvoiding = true
			heartbeatCount = 0
			return
		elseif patrolOrigin and (not lastWaypoint or (getDistanceFromPoints(vehiclePosition, patrolOrigin) > farRange or distanceFromTarget > limitRange)) then
			if not lastWaypoint or lastWaypoint == vehiclePosition then
				local patrolFacing 		= SnapToFacing(getFacingAngle(vehiclePosition, patrolOrigin), defaultSnapAngle) + 90.0
				if patrolFacing > 360.0 then
					patrolFacing = patrolFacing % 360
				end
				currentPatrolWaypoint	= getBeamEndWithFacing(patrolOrigin, weaponRange, patrolFacing)
				local worldSize 		= getWorldSize()
				local worldEdge 		= 20.0
				if currentPatrolWaypoint.x > worldSize.x - worldEdge then
					currentPatrolWaypoint.x = worldSize.x - worldEdge
				end
				if currentPatrolWaypoint.y > worldSize.y - worldEdge then
					currentPatrolWaypoint.y = worldSize.y - worldEdge
				end
				if currentPatrolWaypoint.x < worldEdge then
					currentPatrolWaypoint.x = worldEdge
				end
				if currentPatrolWaypoint.y < worldEdge then
					currentPatrolWaypoint.y = worldEdge
				end
				vehicleTarget 			= nil
				DirectMove(currentPatrolWaypoint)
			end
		elseif distanceFromTarget < limitRange and isLineOfSight(vehicle, target) then
			-- Target in range and LoS, stop movement.
			local desiredFacing = getFacingAngle(vehiclePosition, targetPosition)
			StopMove(desiredFacing)
		elseif distanceFromTarget < limitRange then
			-- Can't see the target, but there's no point continuing the approach.
			local direction 			= getFacingAngle(targetPosition, vehiclePosition)
			local offset				= 90.0
			if direction >= 180.0 then
				offset					= 270.0
			end
			local desiredPosition 		= getBeamEndWithFacing(targetPosition, idealRange, offset)
			BeginMove(desiredPosition)
		else
			-- Get closer to the target.
			local direction 			= getFacingAngle(targetPosition, vehiclePosition)
			local desiredPosition 		= getBeamEndWithFacing(targetPosition, idealRange, direction)
		
			BeginMove(desiredPosition)
		end
		
		lastWaypoint = vehiclePosition
		setTarget(vehicle, vehicleTarget)
	end
end

function CheckForTraffic()
	local trafficRadius			= 100
	local targets 				= getTargetsInRadius(vehiclePosition, trafficRadius, EntityFlags(EntityType.Vehicle)) 
	for t in targets:iterator() do
		if canTarget(t) then
			local tempVehicle 	= entityToVehicle(t)
			if not isSameEntity(vehicle, tempVehicle) and not tempVehicle:isAir() then
				local angleRelativeToVehicle 	= getFacingAngle(vehiclePosition, tempVehicle:getWorldPosition()) - vehicleWorldFacing
				if angleRelativeToVehicle < 0 then
					angleRelativeToVehicle		= 360.0 + angleRelativeToVehicle
				end
				if (angleRelativeToVehicle >= 135.0 and angleRelativeToVehicle <= 215.0) or (angleRelativeToVehicle <= 45.0 and angleRelativeToVehicle >= -45.0) then
					-- Land vehicles try to stay on the road and navigate a different direction. Otherwise try to go elsewhere. If all diversions are blocked then give up.
					local offset 				= nil
					local desiredPosition		= nil
					if landUnit then
						offset 				= 180.0
						desiredPosition 		= GetUnobstructedTravelRoute(angleRelativeToVehicle, trafficRadius, offset, defaultSnapAngle)
						if desiredPosition then
							BeginMove(desiredPosition)
							return true
						end
					end
					offset 						= 90.0
					if coinFlip() then
						offset 					= -90.0
					end
					desiredPosition 			= GetUnobstructedTravelRoute(angleRelativeToVehicle, trafficRadius, offset, defaultSnapAngle / 3.0)
					if desiredPosition then
						DirectMove(desiredPosition)
						return true
					end
				end
			end
		end
	end
end

-- returns a position if travel is not obstructed, nil otherwise
function GetUnobstructedTravelRoute(angleRelativeToVehicle, trafficRadius, offset, snapFactor)
	angleRelativeToVehicle = (angleRelativeToVehicle + offset) % 360
	local desiredPosition = getBeamEndWithFacing(vehiclePosition, trafficRadius, angleRelativeToVehicle)
	local closestTarget = getClosestTargetInBeam(vehiclePosition, desiredPosition, trafficRadius / 5, EntityFlags(EntityType.Vehicle, EntityType.Zone), vehicle)
	if not canTarget(closestTarget) then
		return desiredPosition
	end
	if coinFlip() then
		offset = 360.0
		while offset >= 0.0 do
			desiredPosition = getBeamEndWithFacing(vehiclePosition, trafficRadius, offset)
			closestTarget = getClosestTargetInBeam(vehiclePosition, desiredPosition, trafficRadius / 5, EntityFlags(EntityType.Vehicle, EntityType.Zone), vehicle)
			if not closestTarget then
				return desiredPosition
			end
			offset = offset - snapFactor
		end
	else
		offset = 0.0
		while offset <= 360.0 do
			desiredPosition = getBeamEndWithFacing(vehiclePosition, trafficRadius, offset)
			closestTarget = getClosestTargetInBeam(vehiclePosition, desiredPosition, trafficRadius / 5, EntityFlags(EntityType.Vehicle, EntityType.Zone), vehicle)
			if not closestTarget then
				return desiredPosition
			end
			offset = offset + snapFactor
		end
	end
	return nil
end

function BeginMove(desiredPosition)
	MoveSound()
	vehicleWorldFacing = SnapToFacing(getFacingAngle(vehiclePosition, desiredPosition), defaultSnapAngle)
	vehicleController:seekToPosition(desiredPosition)
end

function DirectMove(desiredPosition)
	MoveSound()
	vehicleWorldFacing = SnapToFacing(getFacingAngle(vehiclePosition, desiredPosition), defaultSnapAngle)
	vehicleController:directMove(desiredPosition)
end

function MoveSound()
	if not moveSound and distanceFromTarget < weaponRange * soundRangeMultiplier then
		if revSoundName and isStopped then
			playSound(revSoundName)
		end
		if moveSoundName then
			moveSound = loopSound(moveSoundName)
		end
	end
	if moveSound and distanceFromTarget >= weaponRange * soundRangeMultiplier then
		stopSound(moveSound)
		moveSound = nil
	end
	if idleSound then
		stopSound(idleSound)
		idleSound = nil
	end
	isStopped = false
end

function StopMove(desiredFacing)
	if idleSoundName and not idleSound and distanceFromTarget < weaponRange * soundRangeMultiplier then
		idleSound = loopSound(idleSoundName)
	end
	if idleSound and distanceFromTarget >= weaponRange * soundRangeMultiplier then
		stopSound(idleSound)
		idleSound = nil
	end
	if moveSound then
		stopSound(moveSound)
		moveSound = nil
	end
	if aimSoundName then
		playSound(aimSoundName)
	end
	isStopped = true
	vehicleWorldFacing = SnapToFacing(desiredFacing, defaultSnapAngle / 4.0)
	local fakeFacingPosition = getBeamEndWithFacing(vehiclePosition, 5, desiredFacing)
	vehicleController:seekToPosition(fakeFacingPosition)
	vehicleController:stop()
end

function HaltSound()
	if moveSound then
		stopSound(moveSound)
		moveSound = nil
	end
	if idleSound then
		stopSound(idleSound)
		idleSound = nil
	end
end

function SnapToFacing(inputFacing, facingSnapFactor)
	--Snaps us to the closest specified angle
	return ((inputFacing % facingSnapFactor) - (inputFacing % (facingSnapFactor / 2))) * 2 + math.floor(inputFacing / facingSnapFactor) * facingSnapFactor
end