require 'scripts/avatars/common'
local buffAura = nil;
local avatar = nil;

local zoneRange = 100;
local durationtime = 5;

local weapon = "weapon_Nuke1"
local healthThreshold = 50;

local explosioncd = false;

function onUse(a)
	avatar = a;
	explosioncd = false;
	
	local buffAura = createAura(this, avatar, 0);
	buffAura:setTickParameters(1, 0);
	buffAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	buffAura:setTarget(avatar);
	
	startAbilityUse(avatar, abilityData.name);
	
	a:addPassiveScript(this);
end

function onZoneDestroyed(a, zone)
	if not explosioncd then
		local dist = getDistance(avatar, zone);
		if dist < zoneRange and zone:getStat("MaxHealth") > healthThreshold then
			explosioncd = true;
			local zonePos = zone:getWorldPosition();
			fireProjectileAtPoint(avatar, avatar:getWorldPosition(), zonePos, weapon);
		end
	end
end
	
function onTick(aura)
	explosioncd = false;
	if aura:getElapsed() >= durationtime then
		avatar:removePassiveScript(this);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end	
