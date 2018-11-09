local kaiju = nil;

function onUse(a)
	
	local curr = a:hasPassive("core_shield"); -- only need to check 1, we're assuming everything is cleaned and created at the same time
	if curr == 0 then --if off then on
		local powerVal = getKaijuResource("power");
		if powerVal > 0 then -- if there is power
			onON(a);
		end
	else -- else if on then off
		onOFF(a);
	end
end

function onON(a)
	abilityInUse(a, abilityData.name, true);
	a:addPassiveScript(this);
	local view = a:getView();
	
	local shieldEffect = view:attachEffectToNode("root", "effects/forceShield_pulseBack.plist", -1, 0, 0, false, true);
	local shieldEffect1 = view:attachEffectToNode("root", "effects/forceShield_pulseFront.plist", -1, 0, 0, true, flase);
	local shieldEffect2 = view:attachEffectToNode("root", "effects/forceShield_core.plist", -1, 0, 0, true, false);
	local shieldEffect3 = view:attachEffectToNode("root", "effects/forceShield_electric.plist", -1, 0, 0, true, false);
	a:setPassive("core_shield", shieldEffect); -- use a differnet core shield with the next id eg "core_shield_1"
	a:setPassive("core_shield_1", shieldEffect1); -- use a differnet core shield with the next id eg "core_shield_1"
	a:setPassive("core_shield_2", shieldEffect2); -- use a differnet core shield with the next id eg "core_shield_1"
	a:setPassive("core_shield_3", shieldEffect3); -- use a differnet core shield with the next id eg "core_shield_1"
	
end

function onOFF(a)
	abilityInUse(a, abilityData.name, false);
	local view = a:getView();
	view:endEffect(a:hasPassive("core_shield")); -- make sure to do these 2 lines for each "core_sheld_x" you used
	view:endEffect(a:hasPassive("core_shield_1")); -- make sure to do these 2 lines for each "core_sheld_x" you used
	view:endEffect(a:hasPassive("core_shield_2")); -- make sure to do these 2 lines for each "core_sheld_x" you used
	view:endEffect(a:hasPassive("core_shield_3")); -- make sure to do these 2 lines for each "core_sheld_x" you used
	a:removePassive("core_shield", 0); -- make sure to do these 2 lines for each "core_sheld_x" you used
	a:removePassive("core_shield_1", 0); -- make sure to do these 2 lines for each "core_sheld_x" you used
	a:removePassive("core_shield_2", 0); -- make sure to do these 2 lines for each "core_sheld_x" you used
	a:removePassive("core_shield_3", 0); -- make sure to do these 2 lines for each "core_sheld_x" you used
	a:removePassiveScript(this);
end

function onAvatarHit(a, n, w)
	local powerVal = getKaijuResource("power");
	if powerVal <= 0 then
		onOFF(a); -- I have no power, so I prevent nothing
	else 
		-- effects on hit
		local view = a:getView();
		view:attachEffectToNode("root", "effects/shield_hit.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/forceshield_hit.plist", 0, 0, 0, true, false);
		
		-- shield logic
		if powerVal > n.x then
			powerVal = n.x;
		else
			onOFF(a); -- if I used all my power to prevent damage
		end
		
		n.x = n.x - powerVal;		
		addKaijuResource("power", -powerVal);
	end	
end