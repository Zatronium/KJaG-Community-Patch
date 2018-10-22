local avatar = 0;
local maxHealth = 0;
local durationtime = 10;
local ticktime = 0.1;
local conversionPerSecond = 50;
local amountPerTick = 0;
function onUse(a)
	avatar = a;
	maxHealth = avatar:getStat("MaxHealth");
	amountPerTick = conversionPerSecond * ticktime;
	local org = getKaijuResource("organic");
	if org > 0 then
		local view = a:getView();
		view:attachEffectToNode("root", "effects/nature_regenCore.plist", durationtime, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/nature_regen.plist", durationtime, 0, 0, true, false);
		local aura = createAura(this, avatar, 0);
		aura:setTickParameters(ticktime, durationtime);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(avatar);
	end	
	playSound("shrubby_ability_MotherNature");
	startCooldown(avatar, abilityData.name);	
end

function onTick(aura)
	local curHealth = avatar:getStat("Health");
	local org = getKaijuResource("organic");	
	if curHealth < maxHealth and org > 0 then
		local diff = maxHealth - curHealth;
		local amount = math.min(math.min(diff, amountPerTick), org);
		addKaijuResource("organic", -amount);
		avatar:gainHealth(amount);
	end
end