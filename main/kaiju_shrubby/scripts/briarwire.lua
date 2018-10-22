require 'kaiju_shrubby/scripts/shrubby'

local avatar = nil;
local pos1 = nil;
local pos2 = nil;
local pos3 = nil;
local pos4 = nil;
local distancePatch = 100;
local number_zones = 10;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_cast");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	playSound("shrubby_ability_Briarwire");
	startCooldown(avatar, abilityData.name);
	pos1 = avatar:getWorldPosition();
	pos2 = avatar:getWorldPosition();
	pos3 = avatar:getWorldPosition();
	pos4 = avatar:getWorldPosition();
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onBriarwire");
	aura:setTarget(avatar);
end

function onBriarwire(aura)
	pos1.x = pos1.x + distancePatch;
	ThornPatch(pos1);
	
	pos2.x = pos2.x - distancePatch;
	ThornPatch(pos2);
	
	pos3.y = pos3.y + distancePatch;
	ThornPatch(pos3);
	
	pos4.y = pos4.y - distancePatch;
	ThornPatch(pos4);
	
	number_zones = number_zones - 1;
	
	if number_zones < 1 then
		aura:getTarget():detachAura(aura);
	end
end