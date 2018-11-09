--require 'kaiju_gordon/scripts/gordon'
require 'scripts/avatars/common'

local kaiju = nil;
local aoeRange = 300;
local disableDuration = 10;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_stomp");
	local view = a:getView();
	local worldPos = kaiju:getWorldPosition();
		
	local view = kaiju:getView();
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
	startAbilityUse(kaiju, abilityData.name);
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= disableDuration then
		ToggleRanged(true);
		endAbilityUse(kaiju, abilityData.name);
		local self = aura:getOwner()
		if not self then
			aura = nil return
		else
			self:detachAura(aura);
		end
	end
end

function ToggleRanged(enable)
	abilityEnabled(kaiju, "ability_gordon_RadBeam", enable);
	abilityEnabled(kaiju, "ability_gordon_NuclearPulse", enable);
	abilityEnabled(kaiju, "ability_gordon_PulsedRads", enable);
	abilityEnabled(kaiju, "ability_gordon_DeathArc", enable);
	abilityEnabled(kaiju, "ability_gordon_BlastZone", enable);
	abilityEnabled(kaiju, "ability_gordon_PiercingBeam", enable);
	abilityEnabled(kaiju, "ability_gordon_Destabilizer", enable);
	abilityEnabled(kaiju, "ability_gordon_BeamSweep", enable);
	abilityEnabled(kaiju, "ability_gordon_Bolter", enable);
	abilityEnabled(kaiju, "ability_gordon_IgnitionZone", enable);
	abilityEnabled(kaiju, "ability_gordon_ReactorLeak", enable);
	abilityEnabled(kaiju, "ability_gordon_HarmonicOverload", enable);
	abilityEnabled(kaiju, "ability_gordon_Shockwave", enable);
	abilityEnabled(kaiju, "ability_gordon_IgnitionBeam", enable);
	abilityEnabled(kaiju, "ability_gordon_MesonBeam", enable);
	abilityEnabled(kaiju, "ability_gordon_Radnado", enable);
	abilityEnabled(kaiju, "ability_gordon_AtomoBolt", enable);
	abilityEnabled(kaiju, "ability_gordon_RadioactiveCloud", enable);
	abilityEnabled(kaiju, "ability_gordon_HavocOverload", enable);
end

