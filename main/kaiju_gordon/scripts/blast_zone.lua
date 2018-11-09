require 'kaiju_gordon/scripts/gordon'
-- check gordon.lua
local kaiju = nil;
local weaponName = "BlastZone2";

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_stomp");
	registerAnimationCallback(this, kaiju, "attack");
end 

function onAnimationEvent(a, event)
	local empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	abilityEnhance(empower);
	BlastZone(a, weaponName);
	playSound("BlastZone");
	abilityEnhance(0);
	startCooldown(kaiju, abilityData.name);	
end

