ticktime = 1.0; 
local healpertick = 2;
local kaiju = nil
local maxHealth = 0;

function onSet(a)
	kaiju = a;
	maxHealth = kaiju:getStat("MaxHealth");
	
	local aura = createAura(this, kaiju, "gino_repairbots");
	aura:setTickParameters(ticktime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
end

function onTick(aura)
	kaiju:gainHealth(healpertick);
end