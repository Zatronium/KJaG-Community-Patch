require 'kaiju_shrubby/scripts/shrubby'

local kaiju = nil;
local pos1 = nil;
local pos2 = nil;
local pos3 = nil;
local pos4 = nil;
local distancePatch = 100;
local number_zones = 10;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_cast");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	playSound("shrubby_ability_Briarwire");
	startCooldown(kaiju, abilityData.name);
	pos1 = kaiju:getWorldPosition();
	pos2 = kaiju:getWorldPosition();
	pos3 = kaiju:getWorldPosition();
	pos4 = kaiju:getWorldPosition();
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onBriarwire");
	aura:setTarget(kaiju);
end

function onBriarwire(aura)
	if not aura then return end
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
		local self = aura:getOwner()
		if not self then
			aura = nil return
		else
			self:detachAura(aura)
		end
	end
end