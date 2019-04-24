--Active
require 'kaiju_goop/scripts/transform_common'

-- control vars
local durationtime = 45;

--
local kaiju = nil -- org
local clone = nil -- clone
local cloneName = "gino2";

local cloneID = "8be22742653e30cb9b2f91f6f1e18573";
local revertAbi = "revert_gino"
local cloneLevel = 2;

local animState = 0;

function onSetup(a)
	preloadKaiju(cloneID);
	a:setPassive("Extra_System_Slot", 1);
end

function onUse(a)
	kaiju = a;	
	if animState == 0 then
		kaiju:getView():lockSWViewOnly(true);
		kaiju:getView():setAnimation("ability_kaijumorph", false);
		registerAnimationCallback(this, kaiju, "end");
		startAbilityUse(kaiju, abilityData.name);
		playSound("goop_ability_Gino2");
	end
end

function onAnimationEvent(a, event)
	if animState == 0 then
		if createTransformAvatar(cloneName, cloneID, cloneLevel) then -- creates the clone
			clone = getSwapAvatarByName(cloneName);
			clone:setPassive("goop_use_health", 1);
			setAbilities(clone);
			GinoSetup(a, clone);
			clone = swapToAvatar(cloneName, false, false, true, true); -- switches to clone (org not paused, orginal not visible, move the new kaiju to orginal, copy debuffs) 
			if clone then		
				-- create aura that just calls an update to remove
				local revertAura = Aura.create(this, clone);
				revertAura:setTag("revert");
				revertAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
				revertAura:setTickParameters(durationtime, 0); --updates at time 0 then at time 20
				revertAura:setTarget(clone); -- required so aura doesn't autorelease
			
			else
				cleanAvatar(cloneName);
			end
		end
	elseif animState == 1 then
		cleanAvatar(cloneName); -- clean up the clone, we will make a new one if we use it again
	end
	createEffectInWorld("effects/goop_transform.plist", a:getWorldPosition(), 0);
	createEffectInWorld("effects/goop_slamsplash3.plist", a:getWorldPosition(), 0);
end

function switchBack()
	if clone then
		kaiju = swapToAvatar(0, false, false, true, true); -- switches back to the orginal, clone not paused, clone not visible, don't move the orginal, don't copy aura
		clone = nil
		kaiju:getView():setAnimation("ability_kaijurevert", false);
		kaiju:getView():lockSWViewOnly(false);
		animState = 1;
		registerAnimationCallback(this, kaiju, "start");
		endAbilityUse(kaiju, abilityData.name);
	end
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationtime then
		switchBack();
	end
end

function setAbilities(a)
	if not a then
		return;
	end
	set1(a);
	
	a:setAbility(revertAbi, getNumberAbilitySlots());
	abilityInUse(a, revertAbi, true);
end

function set1(a)
	-- passives first
	GinoPassives(a, 2);
	a:setAbility("ability_CombatCapacitor", -1);
	a:setAbility("ability_TargetingScan", -1);
	a:setAbility("ability_TitaniumPlating", -1);
	a:setAbility("ability_PointDefenseCannon", -1);
	-- actives
	a:setAbility("ability_FireBall", 0);
	a:setAbility("ability_Icefire", 1);
	a:setAbility("ability_DeathStare", 2);
	a:setAbility("ability_Blasters", 3);
	a:setAbility("ability_Boosters", 4);
	a:setAbility("ability_TailThump", 5);
end