require 'kaiju_goop/scripts/goop_common'

local kaiju = nil
local dead = false

local pickupDelay = 3;
local updateRate = 0.5;
local pickupRange = 100;

local initialSetup = false
local setupFinished = false

function doSpawnSetup()
	initialSetup = true
	kaiju = getPlayerAvatar()
	setupFinished = true
end

function onHeartbeat(v)
	if not initialSetup then 
		doSpawnSetup()
	end
	if not setupFinished or combatEnded() then
		return
	end
	
	if pickupDelay > 0 then
		pickupDelay = pickupDelay - updateRate;
		return;
	end
	
	if not kaiju then
		return
	end
	
	local dist = getDistance(v, kaiju);
	if dist <= pickupRange and kaiju:getStat("Health") < kaiju:getStat("MaxHealth") then
		dead = true
		kaiju:gainHealth(10);
		GoopPickedUp();
		v:getView():setVisible(false);
		removeEntity(v);
	end
end

function onStatChanged(e, stat, prev, val)
	if stat == "Health" then
		local maxHealth = e:getStat("MaxHealth");
		if val > maxHealth then
			e:setStat("Health", maxHealth);
		end
	end
end

function onDeath(self)
	if not dead then
		dead = true
		self:getView():setVisible(false);
		removeEntity(self);
	end
end