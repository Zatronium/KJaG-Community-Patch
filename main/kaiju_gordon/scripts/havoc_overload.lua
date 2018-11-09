require 'kaiju_gordon/scripts/gordon'
local kaiju = nil;

local freezeDuration = 2;

local weaponName = "BlastZone4"

local blastNumber = 5;
local blastDelay = 2;

blastTotal = blastDelay * blastNumber;

local empower = 0;

function onUse(a)
	kaiju = a;
	
	local rebootAura = Aura.create(this, a);
	rebootAura:setTag('harmonic_overflow_tick');
	rebootAura:setScriptCallback(AuraEvent.OnTick, 'onBlast');
	rebootAura:setTickParameters(blastDelay, 0); --Zat: This line was corrupted
	rebootAura:setTarget(a); -- required so aura doesn't autorelease
	
	startAbilityUse(kaiju, abilityData.name);
	empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);

end

function onAnimationEvent(a)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/powerDown_back.plist", 0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/powerDown_front.plist", 0, 0, 0, true, false);
	view:pauseAnimation(freezeDuration);
	
	local rebootAura = Aura.create(this, a);
	rebootAura:setTag('harmonic_overflow_freeze');
	rebootAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	rebootAura:setTickParameters(freezeDuration, 0); --Zat: this line was corrupted
	rebootAura:setTarget(a); -- required so aura doesn't autorelease
	
	a:loseControl();
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() > freezeDuration then
		kaiju:regainControl();
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end

function onBlast(aura)
	if not aura then
		return
	end
	abilityEnhance(empower);
	BlastZone(kaiju, weaponName);
	abilityEnhance(0);
	if aura:getElapsed() > blastTotal then
		playAnimation(kaiju, "ability_jump");
		registerAnimationCallback(this, kaiju, "start");
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end
