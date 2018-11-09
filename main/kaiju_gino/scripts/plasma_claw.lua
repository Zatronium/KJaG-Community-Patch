require 'kaiju_gino/scripts/gino'

local kaiju = nil;

local beamRange = 75;
local beamWidth = 25;

function onUse(a)
	kaiju = a;
	playAnimation( a, "punch_onetwo");
	registerAnimationCallback(this, a, "attack");
	startCooldown(a, abilityData.name);
	playSound("gino_claw");
	local view = a:getView();

	view:attachEffectToNode("palm_node_01", "effects/PlasmaClaw.plist",  1.6, 0, 0, false, false);
	view:attachEffectToNode("palm_node_02", "effects/plasmaClaw.plist",  1.6, 0, 0, false, false);
    view:attachEffectToNode("palm_node_01", "effects/PlasmaClaw2.plist", 1.6, 0, 0, false, false);
	view:attachEffectToNode("palm_node_02", "effects/plasmaClaw2.plist", 1.6, 0, 0, false, false);

end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);

	local beamOrigin = a:getWorldPosition();
	local beamFacing = a:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		if not isSameEntity(t, a) then
			t:attachEffect("effects/PlasmaClaw.plist", 3, true);
			applyDamage(a, t, calcAttackDamage());
		end
	end
	targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		if not isSameEntity(t, a) then
			local aura = createAura(this, t, "gino_plasmaclaw");
			aura:setTickParameters(1, 3);
			aura:setScriptCallback(AuraEvent.OnTick, "onTick");
			aura:setTarget(t);
		end
	end
end

function onTick(aura)
	if not aura then
		return
	end
	applyDamageWithWeapon(kaiju, aura:getTarget(), "weapon_Plasmaclaw1");
end