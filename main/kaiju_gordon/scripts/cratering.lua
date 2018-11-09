require 'scripts/avatars/common'
local buffAura = nil;
local kaiju = nil;

local zoneRange = 100;
local enemyAccDebuff = 0.1;
local accValue = 0;
local duration = 2;

function onSet(a)
	kaiju = a;
	if not a:hasStat("acc_notrack") then
		a:addStat("acc_notrack", 100);
	end
	
	a:setPassive("cratering_enemy_acc_debuff", enemyAccDebuff);
	a:setPassive("cratering_missile_dodge", 0);
	
	a:addPassiveScript(this);
end

function onZoneDestroyed(a, zone)
	local dist = getDistance(kaiju, zone);
	if dist < zoneRange then
		kaiju:misdirectMissiles(kaiju:hasPassive("cratering_missile_dodge"), false);
	
		if not buffAura then
			local def = kaiju:getStat("acc_notrack");
			accValue = def * a:hasPassive("cratering_enemy_acc_debuff");
			kaiju:setStat("acc_notrack", def - accValue);
			
			buffAura = createAura(this, kaiju, 0);
			buffAura:setTag("cratering");
			buffAura:setTickParameters(2, 0);
			buffAura:setScriptCallback(AuraEvent.OnTick, "onTick");
			buffAura:setTarget(kaiju);
		else
			buffAura:resetElapsed();
		end
	end
	playSound("Cratering");
end
	
function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= duration then
		local def = kaiju:getStat("acc_notrack");
		kaiju:setStat("acc_notrack", def + accValue);
		accValue = 0;
		
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
		buffAura = nil;
	end
end	
