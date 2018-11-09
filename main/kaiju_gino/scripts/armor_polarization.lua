--- Desc:        An intense EM field locks the KAIJU into an invulnerable armoured statue for a few moments.
--- Type:        Active
--- Kaiju:      Gino
--- Tier:        5
--- Cost:        70 E
--- Cooldown:    60 s
--- Weapon:      --
--- Effect:      KAIJU is invulnerable but immobile for 10 s

---Can I loop this animation? It should have a start and an end callback.
require 'scripts/common'

local kaiju = nil;
local freezeDuration = 10;

function onUse(a)
	kaiju = a;
	playAnimation(a, "ability_channel");
	
	local invulnerableAura = Aura.create(this, a);
	invulnerableAura:setTag('armor_polar');
	invulnerableAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	invulnerableAura:setTickParameters(freezeDuration, 0);
	invulnerableAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("root", "effects/armorPolarization_back.plist", freezeDuration, 0,0, false, true);
	view:attachEffectToNode("root", "effects/armorPolarization_front.plist", freezeDuration, 0,0, true, false);
	
	kaiju:setImmobile(true);
	kaiju:setInvulnerable(true);
	startAbilityUse(kaiju, abilityData.name);
	
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= freezeDuration then
		kaiju:setImmobile(false);
		kaiju:setInvulnerable(false);
		endAbilityUse(kaiju, abilityData.name);
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end

