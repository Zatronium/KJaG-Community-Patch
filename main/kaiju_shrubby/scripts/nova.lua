require 'scripts/avatars/common'

local kaiju = nil
local aoeRange = 200;
local damage = 50;
local blindDuration = 10;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_cast");
	startCooldown(kaiju, abilityData.name);
	playSound("shrubby_ability_Nova");
	kaiju:misdirectMissiles(1.0, false);
	local targets = getTargetsInRadius(kaiju:getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		if not isSameEntity(kaiju, t) then
			local aura = createAura(this, t, 0);
			aura:setTickParameters(blindDuration, 0);
			aura:setScriptCallback(AuraEvent.OnTick, "onTick");
			aura:setTag("BLIND");
			aura:setTarget(t);
			
			applyDamage(kaiju, t, damage);
		end
	end
	local view = a:getView();
	view:attachEffectToNode("root", "effects/novaCoreBack.plist", 0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/novaCoreFront.plist", 0, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/novaBack.plist", 0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/novaFront.plist", 0, 0, 0, true, false);
end

function onTick(aura)
	local elapsed = aura:getElapsed();
	
	if elapsed >= blindDuration then
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end
