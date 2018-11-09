require 'kaiju_goop/scripts/goop'

local kaiju = nil

local spawntimemin = 1;
local spawntimemax = 3;

local spawntime = 1;

local limitSpawn = 10;
local groupName = "poop";

function onSet(a)
	kaiju = a;

--	local view = a:getView();
--	view:attachEffectToNode("root", "effects/nature_regenCore.plist", durationtime, 0, 0, true, false);
--	view:attachEffectToNode("root", "effects/nature_regen.plist", durationtime, 0, 0, true, false);
	
	local aura = createAura(this, kaiju, 0);
	aura:setTag("goop_poop");
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
end

function onTick(aura)
	if not kaiju then
		return;
	end
	if aura:getElapsed() >= spawntime then
		if kaiju:getStat("Health") >= kaiju:getStat("MaxHealth") then
			if getMinionLimitNum(groupName) < limitSpawn then
				local newblob = CreateSingleBlob(kaiju:getWorldPosition(), true);
				if newblob then
					limitMinionAdd(groupName, newblob);
					createEffectInWorld("effects/goopball_splortsplash.plist", newblob:getWorldPosition(), 0);
					createEffectInWorld("effects/goopball_splort.plist", newblob:getWorldPosition(), 0);
				end
			end
		--	createFloatingNumber(kaiju, getMinionLimitNum(groupName), 0, 255, 255);
			spawntime = math.random(spawntimemin, spawntimemax);
			aura:resetElapsed();
		end
	end
end