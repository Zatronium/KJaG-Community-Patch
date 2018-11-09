local hasUpdated = false;
local duration = 2;
local kaiju = nil;
local distance = 1000;
function onUse(a)
	kaiju = a;
	a:misdirectMissiles(1.0, false);
	a:setEnablePhysicsBody(false);
	a:getView():setKaijuVisible(false);
	startCooldown(a, abilityData.name);
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/vanish_trailing.plist", 0, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, -40, 20, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, 40, 20, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, -80, 40, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, 80,40, true, false);
	view:attachEffectToNode("root", "effects/pulseVertical_back.plist", 0, 0,0, false, true);
	view:attachEffectToNode("root", "effects/pulseVertical_front.plist", 0, 0,0, true, false);
	
	local pos = a:getWorldPosition();
	local dirX = (math.random() * 2) - 1;
	local dirY = 1 - math.abs(dirX);
	if math.random() > 0.5 then
		dirY = dirY * -1;
	end
	
	pos.x = pos.x + dirX * distance;
	pos.y = pos.y + dirY * distance;
	
	a:teleportTo(pos);
	
	
	local vanishAura = Aura.create(this, a);
	vanishAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	vanishAura:setTickParameters(duration, duration);
	vanishAura:setTarget(a); -- required so aura doesn't autorelease
end

function onTick(aura)
	if not aura then
		return
	end
	if hasUpdated then
		kaiju:setEnablePhysicsBody(true);
		kaiju:getView():setKaijuVisible(true);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
	hasUpdated = true;
end