require 'scripts/avatars/common'

local kaiju = nil;
local freezeDuration = 5;


function onUse(a)
	kaiju = a;
	playAnimation(a, "ability_duck");
	
	local rootAura = Aura.create(this, a);
	rootAura:setTag('duck');
	rootAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	rootAura:setTickParameters(1, 0) -- Zat: This line was corrupted
	rootAura:setTarget(a); -- required so aura doesn't autorelease

	kaiju:setImmobile(true);
	kaiju:setInvulnerable(true);
	kaiju:setInvulnerableTime(freezeDuration);
	kaiju:loseControl();
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/armorPolarization_back.plist", freezeDuration, 0,0, false, true);
	view:attachEffectToNode("root", "effects/armorPolarization_front.plist", freezeDuration, 0,0, true, false);
	
	startAbilityUse(kaiju, abilityData.name);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= 1 then
		kaiju:getView():togglePauseAnimation(true);
	end
	if aura:getElapsed() >= freezeDuration then
	--_log("inv break");
		endAbilityUse(kaiju, abilityData.name);
		kaiju:getView():togglePauseAnimation(false);
		kaiju:setImmobile(false);
		kaiju:regainControl();
		kaiju:setInvulnerable(false);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end

