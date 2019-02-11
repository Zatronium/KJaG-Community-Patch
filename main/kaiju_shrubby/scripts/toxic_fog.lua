require 'scripts/common'

local kaiju = nil
local duration = 5
local aoeRange = 100
local speedDecrease = -0.5
local weapon = "weapon_shrubby_poisonCloud1"

function onSet(a)
	kaiju = a
	local aura = createAura(this, kaiju, 0)
	aura:setTickParameters(1, 0)
	aura:setScriptCallback(AuraEvent.OnTick, "onTick")
	aura:setTarget(kaiju)
	local view = a:getView()
	view:attachEffectToNode("root", "effects/toxicFog.plist", -1, 0, 200, true, false)
	view:attachEffectToNode("root", "effects/toxicFogTrail.plist", -1, 0, 180, true, false)
end

function onTick(aura)
	if not aura then return end
	local targets = getTargetsInEntityRadius(kaiju, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar))
	if not targets then return end
	for t in targets do
		if not t:hasAura("toxic_fog") then
			local subAura = createAura(this, t, 0)
			subAura:setTag("toxic_fog")
			subAura:setTickParameters(1, 0)
			local sd = t:getStat("Speed") * speedDecrease
			subAura:setStat("Speed", sd)
			subAura:setScriptCallback(AuraEvent.OnTick, "onDot")
			subAura:setTarget(t)
		end
	end
end

function onDot(aura)
	if not aura then return end
	local elapsed = aura:getElapsed()
	local target = aura:getTarget()
	if elapsed > duration or not canTarget(target) then
		local self = aura:getOwner()
		if not self then
			aura = nil return
		else
			self:detachAura(aura)
		end
	else
		if isOrganic(target) then
			applyDamageWithWeapon(kaiju, target, weapon)
		end
	end
end