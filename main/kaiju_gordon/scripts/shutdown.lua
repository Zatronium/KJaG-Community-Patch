--require 'kaiju_gordon/scripts/gordon'
require 'scripts/avatars/common'

local avatar = nil;
local aoeRange = 300;
local disableDuration = 10;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_stomp");
	local view = a:getView();
	local worldPos = avatar:getWorldPosition();
		
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/shutdown.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/shutdownYellow.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/shutdownRing.plist",0, 0, 0, false, true);
	local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone));
	for t in targets:iterator() do
		local super = false;
		if getEntityType(t) == EntityType.Vehicle then
			local veh = entityToVehicle(t);
			super = veh:isSuper();
		end
		if not super then
			t:disabled(disableDuration);
		end
	end
		
	ToggleRanged(false);
	
	local rebootAura = Aura.create(this, a);
	rebootAura:setTag('shutdown_aura');
	rebootAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	rebootAura:setTickParameters(disableDuration, 0);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
	rebootAura:setTarget(a); -- required so aura doesn't autorelease
--	playSound("shrubby_ability_VineWave");
	startAbilityUse(avatar, abilityData.name);
end

function onTick(aura)
	if aura:getElapsed() >= disableDuration then
		ToggleRanged(true);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end

function ToggleRanged(enable)
	abilityEnabled(avatar, "ability_gordon_RadBeam", enable);
	abilityEnabled(avatar, "ability_gordon_NuclearPulse", enable);
	abilityEnabled(avatar, "ability_gordon_PulsedRads", enable);
	abilityEnabled(avatar, "ability_gordon_DeathArc", enable);
	abilityEnabled(avatar, "ability_gordon_BlastZone", enable);
	abilityEnabled(avatar, "ability_gordon_PiercingBeam", enable);
	abilityEnabled(avatar, "ability_gordon_Destabilizer", enable);
	abilityEnabled(avatar, "ability_gordon_BeamSweep", enable);
	abilityEnabled(avatar, "ability_gordon_Bolter", enable);
	abilityEnabled(avatar, "ability_gordon_IgnitionZone", enable);
	abilityEnabled(avatar, "ability_gordon_ReactorLeak", enable);
	abilityEnabled(avatar, "ability_gordon_HarmonicOverload", enable);
	abilityEnabled(avatar, "ability_gordon_Shockwave", enable);
	abilityEnabled(avatar, "ability_gordon_IgnitionBeam", enable);
	abilityEnabled(avatar, "ability_gordon_MesonBeam", enable);
	abilityEnabled(avatar, "ability_gordon_Radnado", enable);
	abilityEnabled(avatar, "ability_gordon_AtomoBolt", enable);
	abilityEnabled(avatar, "ability_gordon_RadioactiveCloud", enable);
	abilityEnabled(avatar, "ability_gordon_HavocOverload", enable);
end

