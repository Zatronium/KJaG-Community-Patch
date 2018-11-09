require 'kaiju_gordon/scripts/radioactive_field'

local kaiju = nil;

local healthUnder = 0.75;

function onSet(a)
	kaiju = a;
	kaiju:setPassive("radioactive_field_Range", aoeRange);
	kaiju:setPassive("radioactive_field_ROF", ROFDebuff);
	kaiju:setPassive("radioactive_field_HealthActivate", healthUnder);
	
	local aura = createAura(this, a, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "DotTick");
	aura:setTarget(a);
end

function bonusStats(s)
	setAbilityToPassive("ability_gordon_RadioactiveField");
end

function DotTick(aura)
	if not canTarget(kaiju) then
		return;
	end
	local hpScale = kaiju:getStat("Health") / kaiju:getStat("MaxHealth");
	if hpScale <= healthUnder then		
		local targets = getTargetsInRadius(kaiju:getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle));
		for t in targets:iterator() do
			if isOrganic(t) == true then
				applyDamage(kaiju, t, dotDamage);
			end
		end
	end
end