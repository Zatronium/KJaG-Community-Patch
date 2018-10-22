require 'kaiju_gordon/scripts/gordon'
-- check gordon.lua
local avatar = nil;
local weaponName = "BlastZone2";

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_stomp");
	registerAnimationCallback(this, avatar, "attack");
end 

function onAnimationEvent(a, event)
	local empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
	abilityEnhance(empower);
	BlastZone(a, weaponName);
	playSound("BlastZone");
	abilityEnhance(0);
	startCooldown(avatar, abilityData.name);	
end

