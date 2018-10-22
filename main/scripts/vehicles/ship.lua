require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

local heartbeatCount 		= -1
local patrolChance			= 30
local patrolOrigin			= nil
local moveSound				= -1
local moveSoundName			= "smallship"
local spawnFlee 			= false
local soundRangeMultiplier	= 1.5
local vehicleWorldFacing	= 0.0
local isStopped				= false
local isAvoiding			= false
local lastPatrolWaypoint	= nil
local currentPatrolWaypoint	= nil
local facingSnapAngle		= 90.0
local initialSetup			= false
local setupFinished			= false

function onSpawn(vehicle)
	if not initialSetup then
		doSpawnSetup(vehicle)
	end
end

function doSpawnSetup(vehicle)
	initialSetup 	= true
	kaiju 			= getPlayerAvatar()
	weaponRange		= vehicle:getMinWeaponRange()
	closeRange		= math.floor(weaponRange * 0.25)
	idealRange		= math.floor(weaponRange * 0.50)
	limitRange		= math.floor(weaponRange * 0.95)
	farRange		= math.floor(weaponRange * 1.5)
	setupFinished	= true
end

function onHeartbeat(vehicle)
	if not initialSetup then
		doSpawnSetup(vehicle)
	end
	if not setupFinished then
		return
	end
	
	local vehicleController = vehicle:getControl()
	local vehiclePosition 	= vehicle:getWorldPosition()
	local kaijuPosition 	= kaiju:getWorldPosition()
	local distanceFromKaiju = getDistance(vehicle, kaiju)
	
	if heartbeatCount == -1 then
		if canTarget(kaiju) and getDistance(vehiclePosition, kaijuPosition) < limitRange then
			createEffect('effects/impact_sparksLots.plist', vehicle:getView():getPosition()) -- probably superfluous
			spawnFlee = true
		end
	
		local patrolValue 	= math.random(1, 100)
		if patrolChance >= patrolValue then
			patrolOrigin 	= vehiclePosition
		end
	end
	
	if heartbeatCount >= 6 then
		spawnFlee = false
		heartbeatCount = 0
		isAvoiding = false
		if not vehicle:isSuper() and CheckForTraffic(vehicle, vehicleController) then
			isAvoiding = true
		end
	end
	
	heartbeatCount = heartbeatCount + 1
	
	if canTarget(kaiju) and not isAvoiding then --Probably break this into seperate method calls at some point
		local vehicleTarget				= nil
		if distanceFromKaiju <= weaponRange and not spawnFlee then
			--If we're in range, target the Kaiju
			vehicleTarget 				= kaiju
		end
		
		if distanceFromKaiju < closeRange or (distanceFromKaiju < idealRange and spawnFlee) then
			-- Too close. Flee!
			local direction 			= getFacingAngle(kaijuPosition, vehiclePosition)
			local desiredRange			= idealRange
			if spawnFlee then
				desiredRange 			= farRange
			end
			local desiredPosition 		= getBeamEndWithFacing(kaijuPosition, desiredRange, direction)
			BeginMove(vehiclePosition, vehicleController, desiredPosition, distanceFromKaiju, weaponRange)
			vehicleTarget 				= nil
			isAvoiding = true
			heartbeatCount = 0
		elseif patrolOrigin and getDistance(vehicle, patrolOrigin) > farRange then
			--Return to patrol route.
			if currentPatrolWaypoint then
				BeginMove(vehiclePosition, vehicleController, currentPatrolWaypoint, distanceFromKaiju, weaponRange)
			else
				BeginMove(vehiclePosition, vehicleController, patrolOrigin, distanceFromKaiju, weaponRange)
			end
			lastPatrolWaypoint = nil
		elseif patrolOrigin and distanceFromKaiju > weaponRange then
			--Setup new patrol route, else exit the block without doing anything.
			if not lastPatrolWaypoint or getDistance(vehiclePosition, lastPatrolWaypoint) >= limitRange then
				lastPatrolWaypoint		= vehiclePosition
				local patrolFacing 		= SnapToFacing(getFacingAngle(vehiclePosition, lastPatrolWaypoint), facingSnapAngle)
				local patrolOffset		= 90.0
				if getFacingAngle(patrolOrigin, vehiclePosition) < 180 then
					patrolOffset		= -90.0
				end
				currentPatrolWaypoint	= getBeamEndWithFacing(patrolOrigin, weaponRange, patrolFacing + patrolOffset)
				BeginMove(vehiclePosition, vehicleController, currentPatrolWaypoint, distanceFromKaiju, weaponRange)
			end
		elseif distanceFromKaiju < limitRange and isLineOfSight(vehicle, kaiju) then
			-- Kaiju in range and LoS, stop movement.
			if not isStopped then
				local desiredFacing = getFacingAngle(vehiclePosition, kaijuPosition)
				StopMove(vehicle, vehiclePosition, desiredFacing)
			end
		elseif distanceFromKaiju < limitRange then
			-- Can't see the kaiju, but there's no point continuing the approach.
			local direction 			= getFacingAngle(kaijuPosition, vehiclePosition)
			local offset				= 90.0
			if direction >= 180.0 then
				offset					= 270.0
			end
			local desiredPosition 		= getBeamEndWithFacing(kaijuPosition, idealRange, offset)
			BeginMove(vehiclePosition, vehicleController, desiredPosition, distanceFromKaiju, weaponRange)
		else
			-- Get closer to the Kaiju.
			local direction 			= getFacingAngle(kaijuPosition, vehiclePosition)
			local desiredPosition 		= getBeamEndWithFacing(kaijuPosition, idealRange, direction)
		
			BeginMove(vehiclePosition, vehicleController, desiredPosition, distanceFromKaiju, weaponRange)
		end
		setTarget(vehicle, vehicleTarget)
	end
end

function CheckForTraffic(vehicle, vehicleController)
	local vehiclePosition 		= vehicle:getWorldPosition()
	local trafficRadius			= 100
	local targets 				= getTargetsInRadius(vehiclePosition, trafficRadius, EntityFlags(EntityType.Vehicle)) 
	local tempVehiclePosition 	= nil
	for t in targets:iterator() do
		if canTarget(t) then
			local tempVehicle 	= entityToVehicle(t)
			if not isSameEntity(vehicle, tempVehicle) and not tempVehicle:isAir() then
				tempVehiclePosition 			= tempVehicle:getWorldPosition()
				
				local angleRelativeToVehicle 	= getFacingAngle(vehiclePosition, tempVehiclePosition) - vehicleWorldFacing
				if angleRelativeToVehicle < 0 then
					angleRelativeToVehicle		= 360.0 + angleRelativeToVehicle
				end
				if angleRelativeToVehicle >= 135.0 and angleRelativeToVehicle <= 215.0) or (angleRelativeToVehicle <= 45.0 and angleRelativeToVehicle >= -45.0 then --It's in front or in back
					-- Slower vehicles will just go offroad to let faster vehicles pass. This way we're not trying to fight the AI's road-snap routing.
					local offset 				= 90.0
					if coinFlip() then
						offset = -90.0
					end
					local desiredPosition 		= GetUnobstructedTravelRoute(vehicle, vehiclePosition, angleRelativeToVehicle, trafficRadius, offset, 30.0)
					if desiredPosition then
						BeginMove(vehiclePosition, vehicleController, desiredPosition, trafficRadius, weaponRange)
						return true
					end
				end
			end
		end
	end
end

function BeginMove(vehiclePosition, vehicleController, desiredPosition, targetDistance, weaponRange)
	MoveSound(targetDistance, weaponRange)
	vehicleWorldFacing = SnapToFacing(getFacingAngle(vehiclePosition, desiredPosition), facingSnapAngle)
	vehicleController:seekToPosition(desiredPosition)
end

-- returns a position if travel is not obstructed, nil otherwise
function GetUnobstructedTravelRoute(vehicle, vehiclePosition, angleRelativeToVehicle, trafficRadius, offset, snapFactor)
	angleRelativeToVehicle = (angleRelativeToVehicle + offset) % 360
	local desiredPosition = getBeamEndWithFacing(vehiclePosition, trafficRadius, angleRelativeToVehicle)
	if not canTarget(getClosestTargetInBeam(vehiclePosition, desiredPosition, trafficRadius, EntityFlags(EntityType.Vehicle, EntityType.Zone), vehicle)) then
		return desiredPosition
	end
	offset = 0.0
	while offset <= 360.0 do
		if not canTarget(getClosestTargetInBeam(vehiclePosition, desiredPosition, trafficRadius, EntityFlags(EntityType.Vehicle, EntityType.Zone), vehicle)) then
			return desiredPosition
		end
		offset = offset + snapFactor
	end
	return nil
end

function MoveSound(targetDistance, weaponRange)
	if moveSound < 0 and targetDistance < weaponRange * soundRangeMultiplier then
		moveSound = loopSound(moveSoundName)
	end
	if moveSound >= 0 and targetDistance >= weaponRange * soundRangeMultiplier then
		stopSound(moveSound)
		moveSound = -1
	end
	isStopped = false
end

function StopMove(vehicleController, vehiclePosition, desiredFacing)
	if moveSound >= 0 then
		stopSound(moveSound)
		moveSound = -1
	end
	isStopped = true
	vehicleWorldFacing = SnapToFacing(desiredFacing, facingSnapAngle)
	local fakeFacingPosition = getBeamEndWithFacing(vehiclePosition, 5, desiredFacing)
	vehicleController:seekToPosition(fakeFacingPosition)
end

function SnapToFacing(inputFacing, facingSnapFactor)
	--Snaps us to the closest specified angle
	return ((inputFacing % facingSnapFactor) - (inputFacing % (facingSnapFactor / 2))) * 2 + math.floor(inputFacing / facingSnapFactor) * facingSnapFactor
end

function onDeath(self)
	spawnLoot(self);
	
	stopSound(moveSound)
	
	local view = self:getView() 
	local pos = view:getPosition();	
	view:setVisible(false);
	removeEntity(self);
	
	playSound("explosion");
	createEffect('effects/impact_fireRingBack_large.plist',pos);
	createEffect('effects/collapseSmokeDark_large.plist',pos);
	createEffect('effects/impact_BoomRisingXlrg.plist',pos);
	createEffect('effects/impact_fireCloud_linger.plist',pos);
	createEffect('effects/impact_dustCloud_med.plist',pos);
	createEffect('effects/impact_boomCore_xlrg.plist',pos);
	createEffect('effects/impact_fireRingFront_large.plist',pos);
	createEffect('effects/impact_boomXlrg.plist',pos);
	createEffect('effects/impact_mushCloud_small.plist',pos);
end