local oldGetSkillInfo = GetSkillInfo
function GetSkillInfo(skill)
	if skill == "Flying"    then
		return PilotSkill("Flying", "Mech gains Flying and +1 Move.")
	end
	return oldGetSkillInfo(skill)
end
local function ProsperoMove(mission, pawn, weaponId, p1, targetArea)
	local this_pawn = pawn or Board:GetPawn(p1)
	local PlacesToGo = extract_table(targetArea)
	local PlacesToSee = extract_table(Board:GetReachable(p1, this_pawn:GetMoveSpeed() + 1, PATH_FLYER))
	if pawn and pawn:IsAbility("Flying") and weaponId == "Move" then
		for i = 1, #PlacesToSee do
			local curr = PlacesToSee[i]
			if not list_contains(PlacesToGo, curr) and not Board:IsBlocked(curr,PATH_FLYER) then targetArea:push_back(curr) end
		end
	end
end
local function EVENT_onModsLoaded() --This function will run when the mod is loaded
	modapiext:addTargetAreaBuildHook(ProsperoMove)
end
modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)