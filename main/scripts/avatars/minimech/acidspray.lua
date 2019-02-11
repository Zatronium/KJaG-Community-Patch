require 'scripts/common'

-- Global values.
local kaiju = nil

function onUse(a, t)
	
	kaiju = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), t:getWorldPosition());
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_beam");
	registerAnimationCallback(this, kaiju, "start");
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local worldPosition = kaiju:getWorldPosition();
	local sceneFacing = kaiju:getSceneFacing();
	
	local targets = getTargetsInEntityRadius(worldPosition, 300, EntityFlags(EntityType.Avatar, EntityType.Zone), TargetFlags(TargetType.Air, TargetType.Land, TargetType.Sea, TargetType.Player, TargetType.Buildable), 20)
	if not targets then return end
	
	view:doEffectFromNode('palm_node_01', 'effects/acidSpray_wide.plist', sceneFacing);
	view:doEffectFromNode('palm_node_01', 'effects/acidSpray_core.plist', sceneFacing);
	view:doEffectFromNode('palm_node_01', 'effects/acidSpray_splash.plist', sceneFacing);
	
	view:doEffectFromNode('palm_node_02', 'effects/acidSpray_wide.plist', sceneFacing);
	view:doEffectFromNode('palm_node_02', 'effects/acidSpray_core.plist', sceneFacing);
	view:doEffectFromNode('palm_node_02', 'effects/acidSpray_splash.plist', sceneFacing);
	for t in targets do
		local mechG = Aura.create(this, t);
		mechG:setTag('mech_green_acid');
		mechG:setScriptCallback(AuraEvent.OnTick, 'onTick');
		mechG:setTickParameters(0.2, 0.2);
		mechG:setTarget(t); -- required so aura doesn't autorelease
		t:attachEffect("effects/onCorrosive.plist"       ,0.3, true);
		t:attachEffect("effects/onCorrosive_smoke.plist" ,0.3, true);
	end
	playSound("sfx_weap_acid_spray_muzzle");
end

function onTick(aura)
	if not aura then return end
	
	applyDamageWithWeapon(kaiju, aura:getTarget(), "weapon_mechgreen_acid");
end