require 'kaiju_gordon/scripts/radioactive_field'

local avatar = nil;

local healthUnder = 0.75;

function onSet(a)
	avatar = a;
	avatar:setPassive("radioactive_field_Range", aoeRange);
	avatar:setPassive("radioactive_field_ROF", ROFDebuff);
	avatar:setPassive("radioactive_field_HealthActivate", healthUnder);
	
	local aura = createAura(this, a, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "DotTick");
	aura:setTarget(a);
end

function bonusStats(s)
	setAbilityToPassive("ability_gordon_RadioactiveField");
end

function DotTick(aura)
	avatar = getPlayerAvatar();
	if not canTarget(avatar) then
		return;
	end
	local hpScale = avatar:getStat("Health") / avatar:getStat("MaxHealth");
	if hpScale <= healthUnder then		
		local targets = getTargetsInRadius(avatar:getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle));
		for t in targets:iterator() do
			if isOrganic(t) == true then
				applyDamage(avatar, t, dotDamage);
			end
		end
	end
end