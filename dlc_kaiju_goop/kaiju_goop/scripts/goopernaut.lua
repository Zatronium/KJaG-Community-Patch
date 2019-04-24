require 'kaiju_goop/scripts/slow_roll'

local kaiju = nil;

function onSet(a)
	kaiju = a;
	onActive(a, -1);
end

function bonusStats(s)
	setAbilityToPassive("ability_goop_SlowRoll");
end


