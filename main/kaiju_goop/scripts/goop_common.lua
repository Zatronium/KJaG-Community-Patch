function CreateBlob(worldPos, minHealth, maxHealth)
	local hp = minHealth;
	if maxHealth > minHealth then
		hp = math.random(minHealth, maxHealth);
	end
	-- Spawn Blob here
	local stagger = false;
	while (hp > 5) do
		CreateSingleBlob(worldPos, stagger)
		stagger = true;
		hp = hp - 10;
	end
	--createFloatingNumber(getPlayerAvatar(), hp, 0, 255, 100);
end

function CreateSingleBlob(worldPos, offsets)
	local randpos = worldPos;
	if offsets then
		randpos = offsetRandomDirection(worldPos, 50, 100);
	end
	return spawnEntity(EntityType.Minion, "unit_goop_goopup", randpos);
end

function SpawnGoopling(worldPos)
	local ent = spawnEntity(EntityType.Minion, "unit_goop_goopling", worldPos);
	setRole(ent, "Player");
	return ent;
end