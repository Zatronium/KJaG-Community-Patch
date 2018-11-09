local kaiju = 0;
local maxHealth = 0;
local durationtime = 10;
local ticktime = 0.1;
local conversionPerSecond = 50;
local amountPerTick = 0;
function onUse(a)
	kaiju = a;
	maxHealth = kaiju:getStat("MaxHealth");
	amountPerTick = conversionPerSecond * ticktime;
	local org = getKaijuResource("organic");
	if org > 0 then
		local view = a:getView();
		view:attachEffectToNode("root", "effects/nature_regenCore.plist", durationtime, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/nature_regen.plist", durationtime, 0, 0, true, false);
		local aura = createAura(this, kaiju, 0);
		aura:setTickParameters(ticktime, durationtime);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(kaiju);
	end	
	playSound("shrubby_ability_MotherNature");
	startCooldown(kaiju, abilityData.name);	
end

function onTick(aura)
	local curHealth = kaiju:getStat("Health");
	local org = getKaijuResource("organic");	
	if curHealth < maxHealth and org > 0 then
		local diff = maxHealth - curHealth;
		local amount = math.min(math.min(diff, amountPerTick), org);
		addKaijuResource("organic", -amount);
		kaiju:gainHealth(amount);
	end
end