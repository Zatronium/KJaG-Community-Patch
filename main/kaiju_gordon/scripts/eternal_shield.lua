require 'kaiju_gordon/scripts/personal_shield'

local kaiju = nil;

local shieldCooldown = 40;
local onCD = false;

function onSet(a)
	kaiju = a;
	kaiju:addPassiveScript(this);
end

function bonusStats(s)
	setAbilityToPassive("ability_gordon_PersonalShield");
end

function onAvatarAbsorb(a, n, w)
	if not onCD and n.y > 0 then
		onCD = true;
		cdAura = createAura(this, kaiju, 0);
		cdAura:setTag("personal_shield");
		cdAura:setTickParameters(shieldCooldown, 0);
		cdAura:setScriptCallback(AuraEvent.OnTick, "onCooldown");
		cdAura:setTarget(kaiju);
		onOn();
	end
end

function onCooldown(aura)
	if not aura then return end
	local elapsed = aura:getElapsed();
	if elapsed >= shieldDuration then
		--kaiju:endShield(false);
		onCD = false;
		local self = aura:getOwner()
		if not self then
			aura = nil return
		else
			self:detachAura(aura);
		end
	end
end


