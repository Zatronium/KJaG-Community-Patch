require 'scripts/common'
local disableTime = 30;
local kaijuDisable = 5;
local range = 1000;
local kaiju = nil;

function onUse(a)
	kaiju = a;
	
	startAbilityUse(kaiju, abilityData.name);
	local view = a:getView();
	view:attachEffectToNode("root", "effects/empBlast_shockwave.plist", 0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/armorPolarization_back.plist", kaijuDisable, 0,0, false, true);
	view:attachEffectToNode("root", "effects/armorPolarization_front.plist", kaijuDisable, 0,0, true, false);
	playAnimation(a, "roar");
	local view = a:getView();
	view:pauseAnimation(kaijuDisable);
	--registerAnimationCallback(this, a, "start");
	-- effects
	
	local worldPos = a:getWorldPosition();
	local targets = getTargetsInRadius(worldPos, range, EntityFlags(EntityType.Vehicle))
	for t in targets:iterator() do
		local veh = entityToVehicle(t);
		if not veh:isVehicleType(VehicleType.Infantry)  then
			veh:disabled(disableTime);
			t:attachEffect("effects/onEmp.plist", disableTime, true);
		end
		if veh:isAir() == true then
			applyDamage(a, t, t:getStat("Health") + t:getStat("Armor"));
		end
	end
	
	local empAura = Aura.create(this, a);
	boostAura:setTag('gino_emp_blast');
	empAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	empAura:setTickParameters(kaijuDisable, 0); --updates every second                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	empAura:setTarget(a); -- required so aura doesn't autorelease
	playSound("emp");
	a:loseControl();
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= kaijuDisable then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:regainControl();
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end
