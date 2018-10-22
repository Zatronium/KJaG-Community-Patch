require 'scripts/avatars/common'

local avatar = nil;
local aoeRange = 200;
local ROFDebuff = -0.5;

local dotDamage = 1;
local dotDuration = 30;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_stomp");
	local view = a:getView();
	local worldPos = avatar:getWorldPosition();

	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/radioactiveField_back.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/radioactiveField_front.plist",0, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/radioactiveFieldPulse_back.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/radioactiveFieldPulse_front.plist",0, 0, 0, true, false);
		
	local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle));
	for t in targets:iterator() do
		if isOrganic(t) == true then
			local aura = createAura(this, t, 0);
			aura:setTickParameters(1, dotDuration);
			aura:setScriptCallback(AuraEvent.OnTick, "onDotTick");
			aura:setTarget(t);
		end
		if getEntityType(t) == EntityType.Vehicle then
			local veh = entityToVehicle(t);
			local hasEnegy = veh:hasWeaponClass(WeaponClass.Energy);
			if hasEnergy then
				t:setStat("weapon_ROF", ROFDebuff);
			end
		end

	end
		
--	playSound("shrubby_ability_VineWave");
	startCooldown(avatar, abilityData.name);	
end

function onDotTick(aura)
	local target = aura:getTarget();
	if not canTarget(target) then
		target:detachAura(aura);
	else
		avatar = getPlayerAvatar();
		applyDamage(avatar, target, dotDamage);
	end
end