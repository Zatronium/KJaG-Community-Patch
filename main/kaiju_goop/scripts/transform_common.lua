function GinoSetup(kaiju, clone)
	clone:modStat("melee_damage_amplify", kaiju:hasPassive("gino_melee"));
	clone:modStat("damage_amplify", kaiju:hasPassive("gino_damage"));
end

function ShrubbySetup(kaiju, clone)
	local bonus = clone:getStat("MaxHealth") * kaiju:hasPassive("shrubby_health_pct"); -- percent increate
	bonus = bonus + kaiju:hasPassive("shrubby_health_val") -- value increase
	clone:modStat("MaxHealth", bonus);
end

function GordonSetup(kaiju, clone)
	local bonus = clone:getBaseStat("Speed") * kaiju:hasPassive("gordon_speed_pct"); -- percent increate
	--bonus = bonus + kaiju:hasPassive("shrubby_health_val") -- value increase
	clone:modStat("Speed", bonus);
end

function GinoPassives(kaiju, tier)
	-- t1
	kaiju:setAbility("ability_HullPlating", -1);
	
	if tier < 2 then
		return;
	end
	kaiju:setAbility("ability_HeuristicAlgorithms", -1);
	kaiju:setAbility("ability_EMJammer", -1);
	kaiju:setAbility("ability_Omnigears", -1);
	kaiju:setAbility("ability_AuxiliaryReactor", -1);
	
	if tier < 3 then
		return;
	end
	kaiju:setAbility("ability_CombatCapacitor", -1);
	kaiju:setAbility("ability_StructuralReinforcement", -1);
	kaiju:setAbility("ability_TargetingScan", -1);
	kaiju:setAbility("ability_TitaniumPlating", -1);
	kaiju:setAbility("ability_EfficiencySystems", -1);
	kaiju:setAbility("ability_PointDefenseCannon", -1);
	
	if tier < 4 then
		return;
	end
	kaiju:setAbility("ability_PointDefenseArray", -1);
	kaiju:setAbility("ability_PowerOptimizers", -1);
	kaiju:setAbility("ability_Momentum", -1);
	kaiju:setAbility("ability_ExposeWeakness", -1);
	kaiju:setAbility("ability_VanadiumPlating", -1);
	kaiju:setAbility("ability_ReactiveThrusters", -1);
	kaiju:setAbility("ability_RazorArmor", -1);
	kaiju:setAbility("ability_ActiveCamo", -1);
	kaiju:setAbility("ability_Recycle", -1);
	kaiju:setAbility("ability_SuperconductorSpikes", -1);
	kaiju:setAbility("ability_ReactiveArmor", -1);
	kaiju:setAbility("ability_HeavyFoot", -1);

	if tier < 5 then
		return;
	end
	kaiju:setAbility("ability_RepairBots", -1);
	kaiju:setAbility("ability_Unrelenting", -1);
	kaiju:setAbility("ability_Rampage", -1);
	kaiju:setAbility("ability_HeavyArms", -1);
	kaiju:setAbility("ability_QPR", -1);
	kaiju:setAbility("ability_HardenedArmor", -1);
	kaiju:setAbility("ability_AdamantiumPlating", -1);
	kaiju:setAbility("ability_XenoGearing", -1);
end

function ShrubbyPassives(kaiju, tier)
	-- t1
	kaiju:setAbility("ability_DynamicGrowth", -1);
	kaiju:setAbility("ability_NaturalGrowth", -1);
	
	if tier < 2 then
		return;
	end
	kaiju:setAbility("ability_SwiftRoots", -1);
	kaiju:setAbility("ability_GreenBrain", -1);
	kaiju:setAbility("ability_HealthyGrowth", -1);
	kaiju:setAbility("ability_IronBark", -1);
	kaiju:setAbility("ability_ConcealingGrowth", -1);
	
	if tier < 3 then
		return;
	end
	kaiju:setAbility("ability_Feed", -1);
	kaiju:setAbility("ability_RootShuffle", -1);
	kaiju:setAbility("ability_SteelBark", -1);
	kaiju:setAbility("ability_Brambles", -1);
	kaiju:setAbility("ability_JungleGrowth", -1);
	kaiju:setAbility("ability_Flow", -1);
	kaiju:setAbility("ability_GreenThumb", -1);
	kaiju:setAbility("ability_Efficiency", -1);

	
	if tier < 4 then
		return;
	end
	kaiju:setAbility("ability_SpikedVines", -1);
	kaiju:setAbility("ability_TitaniumBark", -1);
	kaiju:setAbility("ability_ThornPatch", -1);
	kaiju:setAbility("ability_Undulation", -1);
	kaiju:setAbility("ability_NaturalHigh", -1);
	kaiju:setAbility("ability_WildVines", -1);
	kaiju:setAbility("ability_Glitter", -1);
	kaiju:setAbility("ability_GreenSoul", -1);
	kaiju:setAbility("ability_Adaptability", -1);
	kaiju:setAbility("ability_Compost", -1);
--	kaiju:setAbility("ability_NoPainNoGain", -1);
	kaiju:setAbility("ability_RegenSprouts", -1);
	
	if tier < 5 then
		return;
	end
	kaiju:setAbility("ability_Corrupters", -1);
	kaiju:setAbility("ability_Detonators", -1);
	kaiju:setAbility("ability_ToxicFog", -1);
	kaiju:setAbility("ability_AdamantiumBark", -1);
	kaiju:setAbility("ability_Briarskin", -1);
	kaiju:setAbility("ability_LeafOnTheWind", -1);
	kaiju:setAbility("ability_WildGrowth", -1);
	kaiju:setAbility("ability_ShroudSpores", -1);
	kaiju:setAbility("ability_Survival", -1);
	kaiju:setAbility("ability_GreenFeast", -1);
	kaiju:setAbility("ability_Supremacy", -1);
	kaiju:setAbility("ability_Fertilizer", -1);
	kaiju:setAbility("ability_Rebirth", -1);
	kaiju:setAbility("ability_BigGreen", -1);	
end

function GordonPassives(kaiju, tier)
	-- t1
	kaiju:setAbility("ability_gordon_Warfighter", -1);
	
	if tier < 2 then
		return;
	end
	kaiju:setAbility("ability_gordon_BodyArmor", -1);
	kaiju:setAbility("ability_gordon_Camo", -1);
	
	if tier < 3 then
		return;
	end
	kaiju:setAbility("ability_gordon_AtomSmasher", -1);
	kaiju:setAbility("ability_gordon_AtomicBoost", -1);
	kaiju:setAbility("ability_gordon_AtomicReaction", -1);
	kaiju:setAbility("ability_gordon_BattlePlanning", -1);
	kaiju:setAbility("ability_gordon_CombatColors", -1);
	kaiju:setAbility("ability_gordon_Cratering", -1);
	kaiju:setAbility("ability_gordon_HeavyArmor", -1);
	kaiju:setAbility("ability_gordon_ImprovedShield", -1);
	--kaiju:setAbility("ability_gordon_UtilityBelt", -1);
	
	if tier < 4 then
		return;
	end
	kaiju:setAbility("ability_gordon_Anticipation", -1);
	kaiju:setAbility("ability_gordon_AtomBuster", -1);
	kaiju:setAbility("ability_gordon_BreederReactor", -1);
	kaiju:setAbility("ability_gordon_DangerousReaction", -1);
	kaiju:setAbility("ability_gordon_DustUp", -1);
	kaiju:setAbility("ability_gordon_FieldMastery", -1);
	kaiju:setAbility("ability_gordon_GrabATron", -1);
	kaiju:setAbility("ability_gordon_HeavierArmor", -1);
	kaiju:setAbility("ability_gordon_ImpenetrableShield", -1);
	kaiju:setAbility("ability_gordon_NanoMachinesSon", -1);
	kaiju:setAbility("ability_gordon_PocketTesseract", -1);
	kaiju:setAbility("ability_gordon_ScatteringField", -1);
	kaiju:setAbility("ability_gordon_ScoutArmor", -1);
	kaiju:setAbility("ability_gordon_WarFace", -1);
	kaiju:setAbility("ability_gordon_WarPaint", -1);
	
	if tier < 5 then
		return;
	end
	kaiju:setAbility("ability_gordon_AbsorptionInfusion", -1);
	kaiju:setAbility("ability_gordon_Aim", -1);
	kaiju:setAbility("ability_gordon_CatalyticConverter", -1);
	kaiju:setAbility("ability_gordon_Chaos", -1);
	kaiju:setAbility("ability_gordon_WarPaint", -1);
	kaiju:setAbility("ability_gordon_Efficiency", -1);
	kaiju:setAbility("ability_gordon_EternalShield", -1);
	kaiju:setAbility("ability_gordon_HeaviestArmor", -1);
	kaiju:setAbility("ability_gordon_Iridescence", -1);
	kaiju:setAbility("ability_gordon_Meltdown", -1);
	kaiju:setAbility("ability_gordon_NuclearMuscle", -1);
	kaiju:setAbility("ability_gordon_Optimization", -1);
	kaiju:setAbility("ability_gordon_Overload", -1);
	kaiju:setAbility("ability_gordon_PortableHole", -1);
	kaiju:setAbility("ability_gordon_Predict", -1);
	kaiju:setAbility("ability_gordon_ReactorBreach", -1);
	kaiju:setAbility("ability_gordon_StealthArmor", -1);
end