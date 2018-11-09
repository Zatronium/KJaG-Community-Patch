require 'scripts/common'

local citySetup = false

function setLightingProfile()
	--					hrMin,	ambR,	ambG,	ambB,			dirX,	dirY,	dirZ,			dirR,	dirG,	dirB,	emZ
	_setLightingProfile(0,		vec3(0.025,	0.025,	0.15	),vec3(1.2,		-2,		0.75	),vec3(.02,		.04,	.07		),true); --midnight
	_setLightingProfile(2,		vec3(0.036,	0.0228, 0.225	),vec3(1.2,		-2,		2		),vec3(.0125,	.002,	.033	),true); --spooky
	_setLightingProfile(4,		vec3(0.06,	0.02,	0.25	),vec3(1.2,		-2,		2		),vec3(.025,	.02,	.03		),true); --less spooky
	_setLightingProfile(6,		vec3(0.024,	0.007,	0.001	),vec3(0.2,		-3,		2		),vec3(.2,		.07,	.043	),true); --breaking dawn
	_setLightingProfile(7,		vec3(0.0043, 0.042,	0.083	),vec3(2.5,		-0.25,	1		),vec3(.48,		.3,		.065	),true); --sunriseish
	_setLightingProfile(9,		vec3(0.012,	0.012,	0.15	),vec3(1.75,	-0.8,	1		),vec3(.75,		.65,	.55		),false);--noon
	_setLightingProfile(12,		vec3(0.007,	0.008,	0.1		),vec3(0.7,		-0.2,	0.5		),vec3(.85,		.65,	.57		),false);--mid afternoon
	_setLightingProfile(16,		vec3(0.12,	0.05,	0.03	),vec3(2,		 0.5,	1.4		),vec3(.7,		.55,	.35		),false);--lat eafternoon
	_setLightingProfile(18,		vec3(0.02,	0.00,	0.00	),vec3(2,		 0.5,	1		),vec3(.527,	.27,	.06		),true);--sunset
	_setLightingProfile(23,		vec3(0.03,	0.02,	0.03	),vec3(1.5,		 0,		0.75	),vec3(.07,		.1,		.15		),true); --evening
end

function onSpawn() -- No heartbeat
	if not citySetup then
		doSpawnSetup()
	end
end

function doSpawnSetup()
	citySetup = true
	-- check to see PREP value
	-- randomly scatter units throughout the map (need to keep a limit of units, don't want more than say 50 available at the same time)
	-- spawn the units
	-- returns only the hours (add "true" for military time or "false" for regular, though regular you down get am/pm)

	setLightingProfile();
	local hour = getCityHour(true);
	_setLightingProfileTime(hour, false);

	_clearKaijuWaterEffects();
	if hour >= 1 and hour < 2 then							--midnight
		_addKaijuWaterEffect("effects/water_midnight.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splash.plist");
		_addKaijuWaterEffect("effects/waterMidnight_ripple.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splashRight.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splashLeft.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splashTip.plist");
		_addKaijuWaterEffect("effects/waterMidnight_cloudLeft.plist");
		_addKaijuWaterEffect("effects/waterMidnight_cloudRight.plist");
		_addKaijuWaterEffect("effects/waterMidnight_cloudTip.plist");
	elseif hour >= 2 and hour < 4 then						-- spooky
		_addKaijuWaterEffect("effects/water_spooky.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splash.plist");
		_addKaijuWaterEffect("effects/waterMidnight_ripple.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splashRight.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splashLeft.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splashTip.plist");
		_addKaijuWaterEffect("effects/waterMidnight_cloudLeft.plist");
		_addKaijuWaterEffect("effects/waterMidnight_cloudRight.plist");
		_addKaijuWaterEffect("effects/waterMidnight_cloudTip.plist");
	elseif hour >= 4 and hour < 6 then						--less spooky
		_addKaijuWaterEffect("effects/water_lessspooky.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splash.plist");
		_addKaijuWaterEffect("effects/waterMidnight_ripple.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splashRight.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splashLeft.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splashTip.plist");
		_addKaijuWaterEffect("effects/waterMidnight_cloudLeft.plist");
		_addKaijuWaterEffect("effects/waterMidnight_cloudRight.plist");
		_addKaijuWaterEffect("effects/waterMidnight_cloudTip.plist");
	elseif hour >= 6 and hour < 7 then						--breaking dawn
		_addKaijuWaterEffect("effects/water_breakingdawn.plist");
		_addKaijuWaterEffect("effects/waterBreakingDawn_splash.plist");
		_addKaijuWaterEffect("effects/waterBreakingDawn_ripple.plist");
		_addKaijuWaterEffect("effects/waterBreakingDawn_splashRight.plist");
		_addKaijuWaterEffect("effects/waterBreakingDawn_splashLeft.plist");
		_addKaijuWaterEffect("effects/waterBreakingDawn_splashTip.plist");
		_addKaijuWaterEffect("effects/waterBreakingDawn_cloudLeft.plist");
		_addKaijuWaterEffect("effects/waterBreakingDawn_cloudRight.plist");
		_addKaijuWaterEffect("effects/waterBreakingDawn_cloudTip.plist");
	elseif hour >= 7 and hour < 9 then						--sunriseish
		_addKaijuWaterEffect("effects/water_sunriseish.plist");
		_addKaijuWaterEffect("effects/waterSunriseish_splash.plist");
		_addKaijuWaterEffect("effects/waterSunriseish_ripple.plist");
		_addKaijuWaterEffect("effects/waterSunriseish_splashRight.plist");
		_addKaijuWaterEffect("effects/waterSunriseish_splashLeft.plist");
		_addKaijuWaterEffect("effects/waterSunriseish_splashTip.plist");
		_addKaijuWaterEffect("effects/waterSunriseish_cloudLeft.plist");
		_addKaijuWaterEffect("effects/waterSunriseish_cloudRight.plist");
		_addKaijuWaterEffect("effects/waterSunriseish_cloudTip.plist");
	elseif hour >= 9 and hour < 12 then						--noon
		_addKaijuWaterEffect("effects/water_noon.plist");
		_addKaijuWaterEffect("effects/waterNoon_splash.plist");
		_addKaijuWaterEffect("effects/waterNoon_ripple.plist");
		_addKaijuWaterEffect("effects/waterNoon_splashRight.plist");
		_addKaijuWaterEffect("effects/waterNoon_splashLeft.plist");
		_addKaijuWaterEffect("effects/waterNoon_splashTip.plist");
		_addKaijuWaterEffect("effects/waterNoon_cloudLeft.plist");
		_addKaijuWaterEffect("effects/waterNoon_cloudRight.plist");
		_addKaijuWaterEffect("effects/waterNoon_cloudTip.plist");
	elseif hour >= 12 and hour < 16 then						--mid afternoon
		_addKaijuWaterEffect("effects/water_midafternoon.plist");
		_addKaijuWaterEffect("effects/waterMidAfternoon_splash.plist");
		_addKaijuWaterEffect("effects/waterMidAfternoon_ripple.plist");
		_addKaijuWaterEffect("effects/waterNoon_splashRight.plist");
		_addKaijuWaterEffect("effects/waterNoon_splashLeft.plist");
		_addKaijuWaterEffect("effects/waterNoon_splashTip.plist");
		_addKaijuWaterEffect("effects/waterNoon_cloudLeft.plist");
		_addKaijuWaterEffect("effects/waterNoon_cloudRight.plist");
		_addKaijuWaterEffect("effects/waterNoon_cloudTip.plist");
	elseif hour >= 16 and hour < 18 then						--lateafternoon
		_addKaijuWaterEffect("effects/water_lateafternoon.plist");
		_addKaijuWaterEffect("effects/waterLateAfternoon_splash.plist");
		_addKaijuWaterEffect("effects/waterLateAfternoon_ripple.plist");
		_addKaijuWaterEffect("effects/waterLateAfternoon_splashRight.plist");
		_addKaijuWaterEffect("effects/waterLateAfternoon_splashLeft.plist");
		_addKaijuWaterEffect("effects/waterLateAfternoon_splashTip.plist");
		_addKaijuWaterEffect("effects/waterLateAfternoon_cloudLeft.plist");
		_addKaijuWaterEffect("effects/waterLateAfternoon_cloudRight.plist");
		_addKaijuWaterEffect("effects/waterLateAfternoon_cloudTip.plist");
	elseif hour >= 18 and hour < 23 then						--sunset
		_addKaijuWaterEffect("effects/water_sunset.plist");
		_addKaijuWaterEffect("effects/waterSunset_splash.plist");
		_addKaijuWaterEffect("effects/waterSunset_ripple.plist");
		_addKaijuWaterEffect("effects/waterSunset_splashRight.plist");
		_addKaijuWaterEffect("effects/waterSunset_splashLeft.plist");
		_addKaijuWaterEffect("effects/waterSunset_splashTip.plist");
		_addKaijuWaterEffect("effects/waterSunset_cloudLeft.plist");
		_addKaijuWaterEffect("effects/waterSunset_cloudRight.plist");
		_addKaijuWaterEffect("effects/waterSunset_cloudTip.plist");
	elseif hour >= 23 and hour < 24 then						--evening
		_addKaijuWaterEffect("effects/water_evening.plist");
		_addKaijuWaterEffect("effects/waterevening_splash.plist");
		_addKaijuWaterEffect("effects/waterEvening_ripple.plist");
		_addKaijuWaterEffect("effects/waterEvening_splashRight.plist");
		_addKaijuWaterEffect("effects/waterEvening_splashLeft.plist");
		_addKaijuWaterEffect("effects/waterEvening_splashTip.plist");
		_addKaijuWaterEffect("effects/waterEvening_cloudLeft.plist");
		_addKaijuWaterEffect("effects/waterEvening_cloudRight.plist");
		_addKaijuWaterEffect("effects/waterEvening_cloudTip.plist");
	else														--midnight
		_addKaijuWaterEffect("effects/water_midnight.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splash.plist");
		_addKaijuWaterEffect("effects/waterMidnight_ripple.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splashRight.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splashLeft.plist");
		_addKaijuWaterEffect("effects/waterMidnight_splashTip.plist");
		_addKaijuWaterEffect("effects/waterMidnight_cloudLeft.plist");
		_addKaijuWaterEffect("effects/waterMidnight_cloudRight.plist");
		_addKaijuWaterEffect("effects/waterMidnight_cloudTip.plist");
	end

--	-- check to see PREP value
--	-- randomly scatter units throughout the map (need to keep a limit of units, don't want more than say 50 available at the same time)
--	-- spawn the units
--	-- returns only the hours (add "true" for military time or "false" for regular, though regular you down get am/pm)
--	_clearKaijuWaterEffects();
--	local hour = getCityHour(true);
--	if hour >= 1 and hour < 3 then		--spooky
--		_setAmbientLight(0.036, 0.0228, 0.225);
--		_setDirectionLight(1.2,-2,2, .0125,.002,.033, false); 
--		--_enableEmissiveLight(true);-- spooky
--		_enableEmissiveLightByClass(true, "Zone");
--		_addKaijuWaterEffect("effects/water_spooky.plist");
--	elseif hour >= 3 and hour < 5 then		--less spooky
--		_setAmbientLight(0.06, 0.02, 0.25);
--		_setDirectionLight(1.2,-2,2, .025,.02,.03, false);
--		--_enableEmissiveLight(true);-- less spooky
--		_enableEmissiveLightByClass(true, "Zone");
--		_addKaijuWaterEffect("effects/water_lessSpooky.plist");
--	elseif hour >= 5 and hour < 7 then		--breaking dawn
--		_setAmbientLight(.024,.007,.001);
--		_setDirectionLight(0.2,-3,2, 0.2,0.07,0.043, false);
--		--_enableEmissiveLight(true);-- breaking dawn
--		_enableEmissiveLightByClass(true, "Zone");
--		_addKaijuWaterEffect("effects/water_breakingDawn.plist");
--	elseif hour >= 7 and hour < 10 then		--sunriseish
--		_setAmbientLight(0.0043, 0.042, 0.083);
--		_setDirectionLight(2.5,-.25, 1, .48,.3,.065, false);
--		--_enableEmissiveLight(true);-- sunriseish
--		_enableEmissiveLightByClass(true, "Zone");
--		_addKaijuWaterEffect("effects/water_sunriseish.plist");
--	elseif hour >= 10 and hour < 14 then	--noon
--		_setAmbientLight(0.012, 0.012, 0.15);
--		_setDirectionLight(1.75,-.8, 1, .75,.65,.55, false);
--		--_enableEmissiveLight(false);-- noon
--		_enableEmissiveLightByClass(false, "Zone");
--		_addKaijuWaterEffect("effects/water_noon.plist");
--	elseif hour >= 14 and hour < 16 then	--afternoon
--		_setAmbientLight(0.007, 0.008, 0.1);
--		_setDirectionLight(0.7,-0.2,.5,  .85,.65,.57, false);
--		--_enableEmissiveLight(false);-- mid afternoon
--		_enableEmissiveLightByClass(false, "Zone");
--		_addKaijuWaterEffect("effects/water_midAfternoon.plist");
--	elseif hour >= 16 and hour < 18 then	--afternoon
--		_setAmbientLight(0.12, 0.05, 0.03);
--		_setDirectionLight(2,.5, 1.4, .7,.55,.35, false); 
--		--_enableEmissiveLight(false);-- late afternoon
--		_enableEmissiveLightByClass(false, "Zone");
--		_addKaijuWaterEffect("effects/water_lateAfternoon.plist");
--	elseif hour >= 18 and hour < 20 then	--sunset
--		_setAmbientLight(0.02, 0.00, 0.00);
--		_setDirectionLight(2,.5,1,  .527,.27,.06, false);
--		--_enableEmissiveLight(false);-- sunset
--		_enableEmissiveLightByClass(false, "Zone");
--		_addKaijuWaterEffect("effects/water_sunset.plist");
--	elseif hour >= 20 and hour < 23 then		--evening
--		_setAmbientLight(0.03, 0.02, 0.03);
--		_setDirectionLight(1.5,0,.75, .07,.1,.15, false);
--		--_enableEmissiveLight(true);-- evening
--		_enableEmissiveLightByClass(true, "Zone");
--		_addKaijuWaterEffect("effects/water_evening.plist");
--	else --midnight
--		_setAmbientLight(0.025, 0.025, 0.15);
--		_setDirectionLight(1.2,-2,.75, .02,.04,.07, false);
--		--_enableEmissiveLight(true);-- midnight
--		_enableEmissiveLightByClass(true, "Zone");
--		_addKaijuWaterEffect("effects/water_midnight.plist");
--	end
end