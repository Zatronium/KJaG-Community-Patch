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
local isLandUnit			= nil
local isSuper				= nil
local isStopped				= true
local distanceFromTarget	= 0.0
local lairAttack			= nil
local kaiju					= nil
local worldSize 			= nil
local worldEdge 			= 20.0

function DoSpawnSetup(v, landUnit, idle, move, rev)
	initialSetup 		= true
	vehicle 			= v
	weaponRange			= vehicle:getMinWeaponRange()
	closeRange			= math.floor(weaponRange * 0.25)
	idealRange			= math.floor(weaponRange * 0.50)
	limitRange			= math.floor(weaponRange * 0.95)
	farRange			= math.floor(weaponRange * 1.5)
	isLandUnit			= landUnit
	idleSoundName		= idle
	moveSoundName		= move
	revSoundName		= rev
	vehicleController	= vehicle:getControl()
	isSuper				= vehicle:isSuper()
	lairAttack			= isLairAttack()
	kaiju				= getPlayerAvatar()
	worldSize			= getWorldSize()
	setupFinished		= true
end

function InitialSetup()
	return initialSetup
end

function SetupFinished()
	return setupFinished
end

function DoVehicleHeartbeat()
	vehiclePosition 	= vehicle:getWorldPosition()
	if not lairAttack then
		if isLandUnit then
			target 		= getTargetInEntityRadius(vehicle, nil, EntityFlags(EntityType.Avatar, EntityType.Minion), TargetFlags(TargetType.Player))
		else
			target 		= getPlayerTarget(vehicle)
		end
	else
		if isLandUnit and getDistance(vehicle, kaiju) < idealRange then
			target		= kaiju
		else
			target 		= getTargetInEntityRadius(vehicle, nil, EntityFlags(EntityType.Zone), TargetFlags(TargetType.Buildable))
			if not target or getDistance(vehicle, target) > limitRange then
				target 	= getPlayerTarget(vehicle)
			end
			if not target then
				target 	= kaiju
			end
		end
	end
	
	distanceFromTarget 	= getDistance(vehicle, target)
	targetPosition 		= target:getWorldPosition()
	
	if heartbeatCount == -1 then
		if distanceFromTarget and distanceFromTarget < idealRange then
			createEffect('effects/impact_sparksLots.plist', vehicle:getView():getPosition())
			spawnFlee = true
		end
		if patrolChance >= math.random(1, 100) and not isSuper or not isLandUnit then
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
	
	if not isAvoiding then
		if distanceFromTarget and (distanceFromTarget < closeRange or (distanceFromTarget < idealRange and spawnFlee)) then
			-- Too close. Flee!
			local direction 			= getFacingAngle(targetPosition, vehiclePosition)
			local desiredRange			= idealRange
			if spawnFlee then
				desiredRange 			= limitRange
			end
			local desiredPosition 		= getBeamEndWithFacing(targetPosition, desiredRange, direction)
			BeginMove(desiredPosition)
			target 						= nil
			isAvoiding 					= true
			heartbeatCount				= 0
		elseif patrolOrigin and (not lastWaypoint or not distanceFromTarget or getDistanceFromPoints(vehiclePosition, patrolOrigin) > farRange or distanceFromTarget > limitRange
		or (not isLandUnit and target and not waterCheckMidpoint(vehicle, targetPosition) and not isEntityOnWater(target))) then
			if not lastWaypoint or getDistanceFromPoints(lastWaypoint, vehiclePosition) < 1 then
				local patrolFacing 			= SnapToFacing(getFacingAngle(vehiclePosition, patrolOrigin) + 90.0, defaultSnapAngle)
				if not lastWaypoint then
					patrolFacing 			= patrolFacing + math.random(0, 360)
				end
				if patrolFacing > 360.0 then
					patrolFacing 			= patrolFacing % 360
				end
				local currentPatrolWaypoint	= getBeamEndWithFacing(patrolOrigin, weaponRange, patrolFacing)
				ForceMove(currentPatrolWaypoint)
			end
		elseif distanceFromTarget and distanceFromTarget < limitRange and isLineOfSight(vehicle, target) then
			-- Target in range and LoS, stop movement.
			local desiredFacing = getFacingAngle(vehiclePosition, targetPosition)
			StopMove(desiredFacing)
		elseif distanceFromTarget and distanceFromTarget < limitRange then
			-- Can't see the target, but there's no point continuing the approach.
			local direction 			= getFacingAngle(targetPosition, vehiclePosition)
			local offset				= 90.0
			if direction >= 180.0 then
				offset					= 270.0
			end
			local desiredPosition 		= getBeamEndWithFacing(targetPosition, idealRange, offset)
			BeginMove(desiredPosition)
		elseif targetPosition then
			-- Get closer to the target.
			BeginMove(targetPosition)
		end
		lastWaypoint = vehiclePosition
		setTarget(vehicle, target)
	end
end

function CheckForTraffic()
	local trafficRadius			= 100
	local targets 				= getTargetInEntityRadius(vehicle, trafficRadius, EntityFlags(EntityType.Vehicle), TargetFlags(TargetType.Land, TargetType.Sea)) 
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
					if isLandUnit then
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
						ForceMove(desiredPosition)
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
	desiredPosition = MapBounding(desiredPosition)
	vehicleWorldFacing = SnapToFacing(getFacingAngle(vehiclePosition, desiredPosition), defaultSnapAngle)
	vehicleController:seekToPosition(desiredPosition)
end

function ForceMove(desiredPosition)
	MoveSound()
	desiredPosition = MapBounding(desiredPosition)
	vehicleWorldFacing = SnapToFacing(getFacingAngle(vehiclePosition, desiredPosition), defaultSnapAngle)
	vehicleController:directMove(desiredPosition)
end

function MapBounding(coords)
	if coords.x > worldSize.x - worldEdge then
		coords.x = worldSize.x - worldEdge
	end
	if coords.y > worldSize.y - worldEdge then
		coords.y = worldSize.y - worldEdge
	end
	if coords.x < worldEdge then
		coords.x = worldEdge
	end
	if coords.y < worldEdge then
		coords.y = worldEdge
	end
	return coords
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
	vehicleController:moveTo(fakeFacingPosition)
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