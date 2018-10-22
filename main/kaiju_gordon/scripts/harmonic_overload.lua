require 'kaiju_gordon/scripts/gordon'
local avatar = nil;

local freezeDuration = 2;

local weaponName = "BlastZone2"

local blastNumber = 5;
local blastDelay = 2;

local blastTotal = blastDelay * blastNumber;
local empower = 0;
function onUse(a)
	avatar = a;
	
	empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
	
	playSound("HarmonicOverload");
	
	local rebootAura = Aura.create(this, a);
	rebootAura:setTag('harmonic_overflow_tick');
	rebootAura:setScriptCallback(AuraEvent.OnTick, 'onBlast');
	rebootAura:setTickParameters(blastDelay, 0);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
	rebootAura:setTarget(a); -- required so aura doesn't autorelease
	startAbilityUse(avatar, abilityData.name);
	
end

function onAnimationEvent(a)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/powerDown_back.plist", freezeDuration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/powerDown_front.plist", freezeDuration, 0, 0, true, false);
	view:pauseAnimation(freezeDuration);
	
	local rebootAura = Aura.create(this, a);
	rebootAura:setTag('harmonic_overflow_freeze');
	rebootAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	rebootAura:setTickParameters(freezeDuration, 0);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
	rebootAura:setTarget(a); -- required so aura doesn't autorelease
	
	a:loseControl();
end

function onTick(aura)
	if aura:getElapsed() > freezeDuration then
		avatar:regainControl();
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end

function onBlast(aura)
	abilityEnhance(empower);
	BlastZone(avatar, weaponName);
	abilityEnhance(0);
	if aura:getElapsed() > blastTotal then
		playAnimation(avatar, "ability_jump");
		registerAnimationCallback(this, avatar, "start");
		aura:getOwner():detachAura(aura);
	end
end
