require 'kaiju_goop/scripts/goop_common'

kaiju = 0;

spawntimemin = 5;
spawntimemax = 15;

spawntime = 5;

limitSpawn = 10;
groupName = "goopening";

function onSet(a)
	kaiju = a;

	local aura = createAura(this, kaiju, 0);
	aura:setTag("goop_goopeninig");
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
end

function onTick(aura)
	kaiju = entityToAvatar(aura:getOwner());
--	createFloatingNumber(kaiju, getMinionLimitNum(groupName), 0, 255, 255);
	if (aura:getElapsed() >= spawntime) then
		if (kaiju:getStat("Health") >= kaiju:getStat("MaxHealth")) then
			if (getMinionLimitNum(groupName) < limitSpawn) then
				local newgoop = SpawnGoopling(kaiju:getWorldPosition());
				if newgoop ~= nil then
					limitMinionAdd(groupName, newgoop);
					createEffectInWorld("effects/goopball_splortsplash.plist", newgoop:getWorldPosition(), 0);
					createEffectInWorld("effects/goopball_splort.plist", newgoop:getWorldPosition(), 0);
				end
			end
			spawntime = math.random(spawntimemin, spawntimemax);
			aura:resetElapsed();
		end
	end
end