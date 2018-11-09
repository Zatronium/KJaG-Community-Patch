--Armor shields slide into place for 10 seconds adding armor to the Kaiju but slowing it down.
--+5 armour and 1/2 speed for 10s
--active

require 'scripts/common'

local kaiju = nil
local durationtime = 10;
local bonusSpeed = 0.0;
local bonusArmor = 5;
function onUse(a)
	kaiju = a;
	
	playAnimation(a, "ability_channel");

	--modify stats first and store the values to remove EXACLTY the same amount 
	--	(otherwise with %, you run the risk of leaving trace bonuses behind
	
	-- create aura that just calls an update to remove
	local boostAura = Aura.create(this, a);
	boostAura:setTag("gino_heavy_metal");
	boostAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	boostAura:setTickParameters(durationtime, 0);
	boostAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("root", "effects/heavymetal.plist", durationtime, 0, 0,true, false);
	
	startAbilityUse(kaiju, abilityData.name);

	a:modStat("Armor", bonusArmor);
	
	bonusSpeed = a:getBaseStat("Speed") * 0.5;
	a:modStat("Speed", -bonusSpeed);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationtime then
		kaiju:modStat("Speed", bonusSpeed);
		kaiju:modStat("Armor", -bonusArmor);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end