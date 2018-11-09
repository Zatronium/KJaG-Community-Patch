require 'scripts/avatars/common'
local kaiju = nil;
local duration = 5;
local aoeRange = 100;
local speedDecrease = -0.5;
local weapon = "weapon_shrubby_poisonCloud1"

function onSet(a)
	kaiju = a;
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
	local view = a:getView();
	view:attachEffectToNode("root", "effects/toxicFog.plist", -1, 0, 200, true, false);
	view:attachEffectToNode("root", "effects/toxicFogTrail.plist", -1, 0, 180, true, false);

end

function onTick(aura)
	local targets = getTargetsInRadius(kaiju:getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle ,EntityType.Avatar));
	for t in targets:iterator() do
		if canTarget(t) and not isSameEntity(kaiju, t) and not t:hasAura("toxic_fog") then
			local aura = createAura(this, t, 0);
			aura:setTag("toxic_fog");
			aura:setTickParameters(1, 0);
			local sd = t:getStat("Speed") * speedDecrease;
			aura:setStat("Speed", t:getStat("Speed") * speedDecrease);
			aura:setScriptCallback(AuraEvent.OnTick, "onDot");
			aura:setTarget(t);
		end
	end
end

function onDot(aura)
	if not aura then return end
	local elapsed = aura:getElapsed();
	local target = aura:getTarget();
	if elapsed > duration or not canTarget(target) then
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	else
		if isOrganic(target) then
			applyDamageWithWeapon(kaiju, target, weapon);
		end
	end
end