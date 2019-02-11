--EntityFlags 'scripts/common'

require 'scripts/common'
local kaiju = nil
local aoeRange = 100
local dotDamage = 5

function onSet(a)
	kaiju = a
	local aura = createAura(this, a, 0)
	aura:setTickParameters(1, 0)
	aura:setScriptCallback(AuraEvent.OnTick, "onTick")
	aura:setTarget(a)
end

function onTick(aura)
	if not aura then return end
	local targets			= getTargetsInEntityRadius(kaiju, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar, EntityType.Zone))
	if not targets then return end
	local canTarget_L		= canTarget	
	local applyDamage_L		= applyDamage
	local isSameEntity_L	= isSameEntity
	for t in targets do
		if canTarget_L(t) and not isSameEntity_L(kaiju, t) then
			applyDamage_L(kaiju, t, dotDamage)
		end
	end
end