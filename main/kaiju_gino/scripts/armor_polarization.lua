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

local avatar = nil;
local freezeDuration = 10;

function onUse(a)
	avatar = a;
	playAnimation(a, "ability_channel");
	
	local invulnerableAura = Aura.create(this, a);
	invulnerableAura:setTag('armor_polar');
	invulnerableAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	invulnerableAura:setTickParameters(freezeDuration, 0);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
	invulnerableAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("root", "effects/armorPolarization_back.plist", freezeDuration, 0,0, false, true);
	view:attachEffectToNode("root", "effects/armorPolarization_front.plist", freezeDuration, 0,0, true, false);
	
	avatar:setImmobile(true);
	avatar:setInvulnerable(true);
	startAbilityUse(avatar, abilityData.name);
	
end

function onTick(aura)
	if aura:getElapsed() >= freezeDuration then
		avatar:setImmobile(false);
		avatar:setInvulnerable(false);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end

