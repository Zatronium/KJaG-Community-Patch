require 'scripts/avatars/common'

local avatar = 0;
local aoeRange = 200;
local damage = 50;
local blindDuration = 10;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_cast");
	startCooldown(avatar, abilityData.name);
	playSound("shrubby_ability_Nova");
	avatar:misdirectMissiles(1.0, false);
	local targets = getTargetsInRadius(avatar:getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		if not isSameEntity(avatar, t) then
			local aura = createAura(this, t, 0);
			aura:setTickParameters(blindDuration, 0);
			aura:setScriptCallback(AuraEvent.OnTick, "onTick");
			aura:setTag("BLIND");
			aura:setTarget(t);
			
			applyDamage(avatar, t, damage);
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
		aura:getOwner():detachAura(aura);
	end
end
