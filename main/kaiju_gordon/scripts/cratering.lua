require 'scripts/avatars/common'
local buffAura = nil;
local avatar = nil;

local zoneRange = 100;
local enemyAccDebuff = 0.1;
local accValue = 0;
local duration = 2;

function onSet(a)
	avatar = a;
	if not a:hasStat("acc_notrack") then
		a:addStat("acc_notrack", 100);
	end
	
	a:setPassive("cratering_enemy_acc_debuff", enemyAccDebuff);
	a:setPassive("cratering_missile_dodge", 0);
	
	a:addPassiveScript(this);
end

function onZoneDestroyed(a, zone)
	local dist = getDistance(avatar, zone);
	if dist < zoneRange then
		avatar:misdirectMissiles(avatar:hasPassive("cratering_missile_dodge"), false);
	
		if not buffAura then
			local def = avatar:getStat("acc_notrack");
			accValue = def * a:hasPassive("cratering_enemy_acc_debuff");
			avatar:setStat("acc_notrack", def - accValue);
			
			buffAura = createAura(this, avatar, 0);
			buffAura:setTag("cratering");
			buffAura:setTickParameters(2, 0);
			buffAura:setScriptCallback(AuraEvent.OnTick, "onTick");
			buffAura:setTarget(avatar);
		else
			buffAura:resetElapsed();
		end
	end
	playSound("Cratering");
end
	
function onTick(aura)
	if aura:getElapsed() >= duration then
		local def = avatar:getStat("acc_notrack");
		avatar:setStat("acc_notrack", def + accValue);
		accValue = 0;
		
		aura:getOwner():detachAura(aura);
		buffAura = nil;
	end
end	
