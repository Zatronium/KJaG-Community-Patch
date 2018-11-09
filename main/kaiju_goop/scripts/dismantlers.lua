meleeBonus = 0.2;

function onSet(a)
	a:modStat("melee_damage_amplify", meleeBonus);
	a:addPassive("gino_melee", meleeBonus);
	local view = a:getView();
	view:attachEffectToNode("palm_node_01", "effects/dismantlers.plist" , -1, 0, 0, true, false);
	view:attachEffectToNode("palm_node_02", "effects/dismantlers.plist" , -1, 0, 0, true, false);
end