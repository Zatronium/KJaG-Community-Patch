require 'kaiju_goop/scripts/absorption'

local kaiju = nil;

function onSet(a)
	kaiju = a;
	kaiju:addPassiveScript(this);
	onStart(-1);
end

function bonusStats(s)
	setAbilityToPassive("ability_goop_Absorption");
end


