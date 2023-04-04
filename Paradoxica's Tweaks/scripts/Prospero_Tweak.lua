local selection = ProsperoGlobalSelection or 1

local oldGetSkillInfo = GetSkillInfo

function GetSkillInfo(skill)
	if skill == "Flying" then
		if selection == 1 then
			return PilotSkill("Flying", "Mech gains Flying and +1 Move.")
		elseif selection == 2 then
			return PilotSkill("Flying", "Mech gains Flying. On deployment, crack adjacent tiles.")
		elseif selection == 3 then
			return PilotSkill("Flying", "Mech gains Flying. On deployment, create chasm under and in front of self.")
		end
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

local function EVENT_onModsLoaded() --This function will run when the mod is loaded
	modapiext:addTargetAreaBuildHook(ProsperoMove)
end

if selection == 1 then
	modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
elseif selection == 2 then
	modApi.events.onPawnLanded:subscribe(ProsperoCrack)
elseif selection == 3 then
	modApi.events.onPawnLanded:subscribe(ProsperoChasm)
end