require 'kaiju_gino/scripts/gino'
local count = 0;
local kaiju = nil;
function onUse(a)
	kaiju = a;
	playAnimation(a, "punch_crit");
	registerAnimationCallback(this, a, "attack");
	startCooldown(a, abilityData.name);
	playSound("gino_claw");
	local view = a:getView();
	local avatarFacing = a:getSceneFacing();
	
	view:attachEffectToNode("palm_node_01", "effects/gigaClaw.plist", 1,  0, 0,false, false);
	view:attachEffectToNode("palm_node_02", "effects/gigaClaw.plist", 1,  0, 0,false, false);

end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar);
	local beamRange = 100;
	local beamWidth = 25;

	local beamOrigin = a:getWorldPosition();
	local beamFacing = a:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		applyDamage(a, t, calcAttackDamage());
	end
	targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	dotSetTargets(a, targets, 1, 5, "onTick");
end

function onTick(aura)
	if not aura then
		return
	end
	applyDamageWithWeapon(kaiju, aura:getTarget(), "weapon_Plasmaclaw4");
	count = count + 1;
	if count >= 5 then
		
		local self = aura:getOwner()
		if not self then
			aura = nil
		else
			self:detachAura(aura);
		end
	end
end