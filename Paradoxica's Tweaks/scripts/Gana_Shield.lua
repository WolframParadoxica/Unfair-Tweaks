local oldGetSkillInfo = GetSkillInfo
function GetSkillInfo(skill)
	if skill == "Deploy_Anywhere"    then
		return PilotSkill("Preemptive Strike", "Deploy anywhere on the map, damaging adjacent enemies and shielding adjacent friendly non-Mech units.")
	end
	return oldGetSkillInfo(skill)
end
local function GanaWeb(pawnId)
	local pawn = Board:GetPawn(pawnId)
	local point = pawn:GetSpace()
	if pawn and pawn:IsAbility("Deploy_Anywhere") then
		for i = 0, 3 do
			local curr = point + DIR_VECTORS[i]
			if Board:IsPawnSpace(curr) and Board:GetPawn(curr):GetTeam() == TEAM_PLAYER and not Board:GetPawn(curr):IsMech() then
				Board:AddShield(curr)
			end
		end
	end
end
modApi.events.onPawnLanded:subscribe(GanaWeb)