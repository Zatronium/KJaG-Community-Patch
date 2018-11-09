require 'scripts/avatars/common'
local kaiju = nil;
local centerPoint = nil;
local duration = 30;
local healPerSecond = 5;
local healRange = 200;

function onUse(a)

	kaiju = a;
	playAnimation(kaiju, "ability_channel");
	playSound("shrubby_ability_NewDawn");
	startCooldown(kaiju, abilityData.name);
	
	local healAura = createAura(this, kaiju, 0);
	healAura:setTickParameters(1, duration);
	healAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	healAura:setTarget(kaiju);

	local view = a:getView();
	view:attachEffectToNode("root", "effects/newDawnSun.plist", duration, 0, 200, true, false);	
	view:attachEffectToNode("root", "effects/newDawnBottom.plist", duration, 0, 0, false, true);

end

function onTick(aura)
	centerPoint = kaiju:getWorldPosition();
	--local dist = getDistanceFromPoints(kaiju:getWorldPosition(), centerPoint);
	--if dist < healRange then
	kaiju:gainHealth(healPerSecond);
	--end
	local minions = kaiju:getMinions();
	for t in minions:iterator() do
		local mdist = getDistanceFromPoints(t:getWorldPosition(), centerPoint);
		if mdist < healRange then
			local m = entityToMinion(t);
			m:gainHealth(healPerSecond);
		end
	end
end