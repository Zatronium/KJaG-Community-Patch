require 'scripts/avatars/common'

local avatar = nil;
local weapon = "BlastZone1";
local aoeRange = 130;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_cast");
	
	registerAnimationCallback(this, avatar, "start");
end 

function onAnimationEvent(a, event)
	avatar = a;
	local view = a:getView();
	local worldPos = avatar:getWorldPosition();

	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/nuclearPulseFireBack.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/nuclearPulseFireFront.plist",0, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/nuclearPulseRingBack.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/nuclearPulseRingFront.plist",0, 0, 0, true, false);
		
	local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	local empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
	abilityEnhance(empower);
	for t in targets:iterator() do
		applyDamageWithWeapon(avatar, t, weapon);
	end
	abilityEnhance(0);
		
	playSound("NuclearPulse");
	startCooldown(avatar, abilityData.name);	
end

