require 'scripts/avatars/common'

local avatar = nil;
local freezeDuration = 5;


function onUse(a)
	avatar = a;
	playAnimation(a, "ability_duck");
	
	local rootAura = Aura.create(this, a);
	rootAura:setTag('duck');
	rootAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	rootAura:setTickParameters(1, 0);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
	rootAura:setTarget(a); -- required so aura doesn't autorelease

	avatar:setImmobile(true);
	avatar:setInvulnerable(true);
	avatar:setInvulnerableTime(freezeDuration);
	avatar:loseControl();
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/armorPolarization_back.plist", freezeDuration, 0,0, false, true);
	view:attachEffectToNode("root", "effects/armorPolarization_front.plist", freezeDuration, 0,0, true, false);
	
	startAbilityUse(avatar, abilityData.name);
end

function onTick(aura)
	if aura:getElapsed() >= 1 then
		avatar:getView():togglePauseAnimation(true);
	end
	if aura:getElapsed() >= freezeDuration then
	_log("inv break");
		endAbilityUse(avatar, abilityData.name);
		avatar:getView():togglePauseAnimation(false);
		avatar:setImmobile(false);
		avatar:regainControl();
		avatar:setInvulnerable(false);
		aura:getOwner():detachAura(aura);
	end
end

