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

--Everything past this line is test code
--[==[

local iS = false
local whoAmI = nil
local sentCrap = nil

function onHeartbeat(vehicle)
	if not iS then
		iS = true
		whoAmI = vehicle
		local func = {}
		func[1] = [[return function(vehicle, str)]]
		func[2] = [[createFloatingText(vehicle, str, 0, 0, 0)]]
		func[3] = [[end]]
		_G['f'] = select(2, pcall(load(table.concat(func))))
		
		local ZeroMQ = enableCommunication()
		--[[local aura = Aura.create(this, vehicle)
		aura:setTag('test')
		aura:setTickParameters(1, 0)
		aura:setScriptCallback(AuraEvent.OnTick, 'fakeCallback')
		aura:setTarget(vehicle)
		aura:setStat('ExtraAbilitySlot', -1)]]
	end
	if sentCrap then
		retMyRand1(sentCrap)
	else
		retMyRand1("nil")
	end
end

function retMyRand1(data)
	_G['f'](whoAmI, tostring(data))
end]==]

