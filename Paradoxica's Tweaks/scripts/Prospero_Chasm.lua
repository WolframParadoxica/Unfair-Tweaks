local oldGetSkillInfo = GetSkillInfo
function GetSkillInfo(skill)
	if skill == "Flying"    then
		return PilotSkill("Flying", "Mech gains Flying. On deployment, create chasm under and in front of self.")
	end
	return oldGetSkillInfo(skill)
end
local function ProsperoChasm(pawnId)
	local pawn = Board:GetPawn(pawnId)
	local point = pawn:GetSpace()
	if pawn and pawn:IsAbility("Flying") then
		local dam = SpaceDamage(point,0)
		dam.iTerrain = TERRAIN_HOLE
		Board:DamageSpace(dam)
		point = point + DIR_VECTORS[1]
		dam.loc = point
		if Board:IsTerrain(point,TERRAIN_MOUNTAIN) then dam.iDamage = DAMAGE_DEATH end
		if not ((Board:IsPawnSpace(point) and Board:GetPawn(point):GetTeam() == TEAM_PLAYER) or Board:IsBuilding(point)) then Board:DamageSpace(dam) end
		Game:TriggerSound("/props/ground_break_tile")
	end
end
modApi.events.onPawnLanded:subscribe(ProsperoChasm)