local oldGetSkillInfo = GetSkillInfo
function GetSkillInfo(skill)
	if skill == "Flying"    then
		return PilotSkill("Flying", "Mech gains Flying. On deployment, crack adjacent tiles.")
	end
	return oldGetSkillInfo(skill)
end
local function ProsperoCrack(pawnId)
	local pawn = Board:GetPawn(pawnId)
	local point = pawn:GetSpace()
	if pawn and pawn:IsAbility("Flying") then
		local dam = SpaceDamage(0)
		dam.iCrack = 1
		for i = 0, 3 do
			local curr = point + DIR_VECTORS[i]
			dam.loc = curr
			Board:DamageSpace(dam)
		end
		Game:TriggerSound("/weapons/crack_ko")
	end
end
modApi.events.onPawnLanded:subscribe(ProsperoCrack)