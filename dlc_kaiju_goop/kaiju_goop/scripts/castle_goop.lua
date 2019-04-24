require 'scripts/common'

local startHealthPercent	= 20;
local endHealthPercent	 	= 50;
local healPerSec			= 10;
local speedDecreasePecent	= 0.5;
local armorBonus			= 5;

local passiveHealthThresholdStart    = "goop_castle_start";
local passiveHealthThresholdStop     = "goop_castle_end";
local passiveSpeedDecrease           = "goop_castle_speed_dec";
local passiveArmorBonus              = "goop_castle_armor";
local passiveName					 = "goop_castle_active";

local kaiju = nil

local isActive = false;
local fxID = 0;

function onSet(a)
	kaiju = a;
	kaiju:setPassive(passiveHealthThresholdStart, startHealthPercent);
	kaiju:setPassive(passiveHealthThresholdStop , endHealthPercent);
	kaiju:setPassive(passiveSpeedDecrease       , speedDecreasePecent);
	kaiju:setPassive(passiveArmorBonus          , armorBonus);
	
	local healAura = Aura.create(this, kaiju);
	healAura:setTag("goop_castle_heal");
	healAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	healAura:setTickParameters(1, 0);
	healAura:setTarget(kaiju); -- required so aura doesn't autorelease
end

function onTick(aura)
	if not aura then return end
	local owner = aura:getOwner()
	if not owner then
		aura = nil return
	end
	if owner:hasPassive(passiveName) > 0 then
		if not isActive then
			local view = owner:getView();
			view:attachEffectToNode("root", "effects/harden.plist", 0, 0, 50, true, false);
			view:attachEffectToNode("root", "effects/harden_shield.plist", 0, 0, 50, true, false);
			
			fxID = view:attachEffectToNode("root", "effects/harden_sparkles.plist", durationtime, 0, 50, true, false);
			isActive = true;
		end
		owner:gainHealth(healPerSec);
	elseif isActive then
		local view = owner:getView();
		view:endEffect(fxID);
		fxID = 0;
		isActive = false;
	end
end