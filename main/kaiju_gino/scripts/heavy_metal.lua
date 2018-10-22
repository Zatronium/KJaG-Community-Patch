--Armor shields slide into place for 10 seconds adding armor to the Kaiju but slowing it down.
--+5 armour and 1/2 speed for 10s
--active

require 'scripts/common'

local avatar = 0;
local durationtime = 10;
local bonusSpeed = 0.0;
local bonusArmor = 5;
function onUse(a)
	avatar = a;
	
	playAnimation(a, "ability_channel");

	--modify stats first and store the values to remove EXACLTY the same amount 
	--	(otherwise with %, you run the risk of leaving trace bonuses behind
	
	-- create aura that just calls an update to remove
	boostAura = Aura.create(this, a);
	boostAura:setTag("gino_heavy_metal");
	boostAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	boostAura:setTickParameters(durationtime, 0);
	boostAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("root", "effects/heavymetal.plist", durationtime, 0, 0,true, false);
	
	startAbilityUse(avatar, abilityData.name);
	
	--is the stat Armor or Armor? Should be Armor.
	bonusArmor = 5;
	a:modStat("Armor", bonusArmor);
	
	--store bonus total (NOTE: may need a "getBaseStat" and go off of that, but minor concern)
	bonusSpeed = a:getBaseStat("Speed") * 0.5;
	a:modStat("Speed", -bonusSpeed);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		avatar = entityToAvatar(aura:getOwner());
		avatar:modStat("Speed", bonusSpeed);
		avatar:modStat("Armor", -bonusArmor);
		endAbilityUse(avatar, abilityData.name);
		avatar:detachAura(aura);
	end
end