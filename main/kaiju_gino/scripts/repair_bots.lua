local ticktime = 1.0; 
local healpertick = 2;
local avatar = 0;
local maxHealth = 0;

function onSet(a)
	avatar = a;
	maxHealth = avatar:getStat("MaxHealth");
	
	local aura = createAura(this, avatar, "gino_repairbots");
	aura:setTickParameters(ticktime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
end

function onTick(aura)
	avatar:gainHealth(healpertick);
end