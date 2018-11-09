require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

require 'scripts/vehicles/trafficcontrol_common'

function onHeartbeat(vehicle)
	if vehicle and not InitialSetup() then
		DoSpawnSetup(vehicle, true, "tank_idle", "tank_move", nil)
	end
	if not SetupFinished() then
		return
	end
	DoVehicleHeartbeat()
end

--[===[local backer = {}

myRand = math.random(1,100)
myRand2 = nil
local v = nil
isSet = nil

initialSetup = false

function onHeartbeat(vehicle)
	v = vehicle
	if not initialSetup then
		--Test 1: set a global function via string for aura creation
		local b = backer
		b.func = {}
		b.func[1] = [[return function(vehicle, str)]]
		b.func[2] = [[createFloatingText(vehicle, str, 0, 0, 0)]]
		b.func[3] = [[end]]
		_G['f'] = select(2, pcall(load(table.concat(b.func))))
		local aura = Aura.create(this, vehicle)
		aura:setTag('myRand')
		aura:setScriptCallback(AuraEvent.OnTick, 'retMyRand1')
		aura:setTarget(vehicle)
		aura:setTickParameters(1, 0)
		initialSetup = true
	end
	if not SetupFinished() then
		return
	end
end

function retMyRand()
	local blah = nil
	if not isSet then
		local closestVehicle = getClosestTargetInRadius(v:getWorldPosition(), 1000, EntityFlags(EntityType.Vehicle), v)
		if canTarget(closestVehicle) and closestVehicle:hasAura('myRand') then
			blah = closestVehicle:getAura('myRand')
			blah:setScriptCallback(AuraEvent.OnTick, 'retMyRand2')
			blah:setTarget(v)
		end
	end
end

function onTick(aura)

end

function retMyRand1()
	_G['f'](v, 'blah')
end

function retMyRand2()
	_G['f'](v, tostring(myRand) .. ' -=- ' .. tostring(myRand2))
end--]===]

function onDeath(self)
	spawnLoot(self);
	
	local view = self:getView()
	local pos = view:getPosition();	
	view:setVisible(false);
	removeEntity(self);
	
	HaltSound()
	
	playSound("explosion");
	createEffect('effects/explosion_SparkLayer.plist', pos);
	createEffect('effects/explosion_SparkFireLayer.plist', pos);
	createEffect('effects/impact_smokeCloud.plist', pos);
	createEffect('effects/impact_fireCloud_glow.plist', pos);
	createEffect('effects/impact_boom.plist', pos);
	createEffect('effects/impact_sparksLots.plist', pos);
	createEffect('effects/impact_flash.plist', pos);
	createEffect('effects/impact_shockwave.plist', pos);
end