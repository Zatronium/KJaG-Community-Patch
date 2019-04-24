--Active
require 'scripts/common'

-- control vars
local durationtime = 30;

--
local health = 0.0;
local money = 0.0;
local bio = 0.0;
local power = 0.0;
local know = 0.0;
local purple = 0.0;

local kaiju = nil -- org
local clone = nil -- clone
local cloneName = "memory";

function onInitStat(s)
	preloadKaiju("avatar_goop");
end

function onUse(a)
	kaiju = a;	
	startAbilityUse(kaiju, abilityData.name);
	health 	= 	kaiju:getStat("Health");
	money 	= 	getKaijuResource("money"	);
	power 	= 	getKaijuResource("power"	);
	know 	=	getKaijuResource("know"		);
	bio 	= 	getKaijuResource("organic"	);
	purple 	= 	getKaijuResource("purple"	);
	--createFloatingNumber(kaiju"health";	, aura:getElapsed(), 0, 255, 255);
	if createCopyAvatar(cloneName) then -- creates the clone
		kaiju:getView():setKaijuVisible(false);
		clone = swapToAvatar(cloneName, true, true, true, false); -- switches to clone (orginal paused, orginal still visible, move the new kaiju to orginal, don't copy debuffs 
	end 
	if clone then
		createEffectInWorld("effects/memory.plist", kaiju:getWorldPosition(), 0);
		
		if kaiju:hasPassive("goop_mem_health") > 0 then
			kaiju:removePassive("goop_mem_health"	, health);
			kaiju:removePassive("goop_mem_money"	, money );
			kaiju:removePassive("goop_mem_power"	, power );
			kaiju:removePassive("goop_mem_know"	, know );
			kaiju:removePassive("goop_mem_organic"	, bio 	);
			kaiju:removePassive("goop_mem_purple"	, purple);
		else
			kaiju:setPassive("goop_mem_health"	, health);
			kaiju:setPassive("goop_mem_money"	, money );
			kaiju:setPassive("goop_mem_power"	, power );
			kaiju:setPassive("goop_mem_know"	, know );
			kaiju:setPassive("goop_mem_organic"	, bio 	);
			kaiju:setPassive("goop_mem_purple"	, purple);
		end
		
		-- create aura that just calls an update to remove
		local memAura = Aura.create(this, clone);
		memAura:setTag('goop_memory');
		memAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
		memAura:setTickParameters(durationtime, 0); --updates at time 0 then at time 20
		memAura:setTarget(clone); -- required so aura doesn't autorelease
		memAura:setAlwaysUpdate(true);
		
		clone:setPassive("goop_replicate", kaiju:hasPassive("goop_replicate_enable"));

	--	local view = a:getView();
	--	view:attachEffectToNode("foot_01", "effects/booster.plist", durationtime, 0, 0, false, true);
	--	view:attachEffectToNode("foot_02", "effects/booster.plist", durationtime, 0, 0, false, true);
		
		playSound("goop_ability_MemoryGOOP");
		abilityInUse(clone, abilityData.name, true);
	end
end

function switchBack()
	if clone then
		--clone:teleportTo(kaiju:getWorldPosition());
		createEffectInWorld("effects/memory.plist", kaiju:getWorldPosition(), 0);
		
		endAbilityUse(kaiju, abilityData.name);
		if isSameEntity(kaiju, clone) then
			swapToAvatar(0, false, false, false, false); -- switches back to the orginal, clone not paused, clone not visible, don't move the orginal, don't copy aura
		end
		kaiju:setStat("Health", health); -- resets health
		kaiju:getView():setKaijuVisible(true);
		money = 	money 	- getKaijuResource("money"	);
		power = 	power 	- getKaijuResource("power"	);
		know = 		know 	- getKaijuResource("know"		);
		bio = 		bio 	- getKaijuResource("organic"	);
		purple = 	purple 	- getKaijuResource("purple"	);
		
		addKaijuResource("money"	, money );
		addKaijuResource("power"	, power );
		addKaijuResource("know"		, know  );
		addKaijuResource("organic"	, bio   );
		addKaijuResource("purple"	, purple);
		clone = nil
		cleanAvatar(cloneName); -- clean up the clone, we will make a new one if we use it again
	end
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationtime then
		switchBack();
	end
end