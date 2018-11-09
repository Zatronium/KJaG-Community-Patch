local duration = 10;
local kaiju = nil;
function onUse(a)
	kaiju = a;
	kaiju:misdirectMissiles(1.0, false);
	kaiju:setEnablePhysicsBody(false);
	kaiju:setPassive("ignore_proj", 100);
	
	kaiju:getView():setKaijuVisible(false);
	playSound("shrubby_ability_BendingWillow");
	startAbilityUse(kaiju, abilityData.name);
	
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/vanish_trailing.plist", 0, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, -40, 20, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, 40, 20, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, -80, 40, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, 80,40, true, false);
	view:attachEffectToNode("root", "effects/willowBack.plist", duration, 0,0, false, true);
	view:attachEffectToNode("root", "effects/willowFront.plist", duration, 0,0, true, false);
	
	local vanishAura = Aura.create(this, kaiju);
	vanishAura:setTag("shrubby_bending_willow");
	vanishAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	vanishAura:setTickParameters(duration, duration);
	vanishAura:setTarget(kaiju); -- required so aura doesn't autorelease
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= duration then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:setEnablePhysicsBody(true);
		kaiju:removePassive("ignore_proj", 0);
		kaiju:getView():setKaijuVisible(true);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end