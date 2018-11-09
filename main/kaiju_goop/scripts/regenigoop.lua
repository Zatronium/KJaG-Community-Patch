local healPerTick = 1;

local kaiju = nil

function onSet(a)
	kaiju = a;
	kaiju:addPassive("goop_regen", healPerTick);
	local aura = createAura(this, kaiju, 0);
	aura:setTag("goop_regenigoop");
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
end

function onTick(aura)
	kaiju:gainHealth(kaiju:hasPassive("goop_regen"));
end