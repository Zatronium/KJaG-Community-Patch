require 'scripts/avatars/common'
local kaiju = nil;

local zoneRange = 100;
local durationtime = 5;

local weapon = "weapon_Nuke1"
local healthThreshold = 50;

local explosioncd = false;

function onUse(a)
	kaiju = a;
	explosioncd = false;
	
	local buffAura = createAura(this, kaiju, 0);
	buffAura:setTickParameters(1, 0);
	buffAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	buffAura:setTarget(kaiju);
	
	startAbilityUse(kaiju, abilityData.name);
	
	a:addPassiveScript(this);
end

function onZoneDestroyed(a, zone)
	if not explosioncd then
		local dist = getDistance(kaiju, zone);
		if dist < zoneRange and zone:getStat("MaxHealth") > healthThreshold then
			explosioncd = true;
			local zonePos = zone:getWorldPosition();
			fireProjectileAtPoint(kaiju, kaiju:getWorldPosition(), zonePos, weapon);
		end
	end
end
	
function onTick(aura)
	if not aura then
		return
	end
	explosioncd = false;
	if aura:getElapsed() >= durationtime then
		kaiju:removePassiveScript(this);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end	
