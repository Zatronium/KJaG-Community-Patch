require 'scripts/avatars/common'

local kaiju = nil;
local weapon = "BlastZone1";
local aoeRange = 130;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_cast");
	
	registerAnimationCallback(this, kaiju, "start");
end 

function onAnimationEvent(a, event)
	kaiju = a;
	local view = a:getView();
	local worldPos = kaiju:getWorldPosition();

	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/nuclearPulseFireBack.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/nuclearPulseFireFront.plist",0, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/nuclearPulseRingBack.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/nuclearPulseRingFront.plist",0, 0, 0, true, false);
		
	local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	local empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	abilityEnhance(empower);
	for t in targets:iterator() do
		applyDamageWithWeapon(kaiju, t, weapon);
	end
	abilityEnhance(0);
		
	playSound("NuclearPulse");
	startCooldown(kaiju, abilityData.name);	
end

