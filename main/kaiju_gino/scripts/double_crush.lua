require 'scripts/avatars/common'
local count = 0;
local kaiju = nil;
function onUse(a)
	kaiju = a;
	playAnimation(a, "ability_doublecrush");
	registerAnimationCallback(this, a, "attack");
	startCooldown(a, abilityData.name);
	playSound("gino_claw");
	local view = a:getView();
	view:attachEffectToNode("palm_node_01", "effects/doubleCrush.plist", 1,  0, 0,false, false);
	view:attachEffectToNode("palm_node_02", "effects/doubleCrush.plist", 1, 0, 0, false, false);
	view:attachEffectToNode("palm_node_01", "effects/doubleCrush_sparks.plist", 1, 0, 0, false, false);
	view:attachEffectToNode("palm_node_02", "effects/doubleCrush_sparks.plist", 1,  0, 0,false, false);
end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar);
	local beamRange = 75;
	local beamWidth = 50;

	local beamOrigin = a:getWorldPosition();
	local beamFacing = a:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	dotSetTargets(a, targets, 1, 3, "onTick");
end

function onTick(aura)
	if not aura then
		return
	end
	applyDamageWithWeapon(kaiju, aura:getTarget(), "weapon_Plasmaclaw2");
	count = count + 1;
	if count >= 3 then
		
		local self = aura:getOwner()
		if not self then
			aura = nil
		else
			self:detachAura(aura);
		end
	end
end