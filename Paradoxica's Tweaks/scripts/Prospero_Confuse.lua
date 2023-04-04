CreatePilot{
	Id = "Pilot_Recycler",
	Skill = "Flying",
	Personality = "Recycler",
	PowerCost = 2,
	Name = "Pilot_Recycler_Name",
	Voice = "/voice/prospero",
}

local oldGetSkillInfo = GetSkillInfo
function GetSkillInfo(skill)
	if skill == "Flying"    then
		return PilotSkill("Flipping Bird", "Mech gains Flying. Flip adjacent tiles when repairing.")
	end
	return oldGetSkillInfo(skill)
end

local function ProsperoConfuse(mission, pawn, weaponId, p1, p2, skillEffect)
	if pawn and pawn:IsAbility("Flying") and weaponId == "Skill_Repair" then
		skillEffect:AddSound("/weapons/confusion")
		skillEffect:AddAnimation(p1, "ExploRepulse3", ANIM_NO_DELAY)
		for dir = 0,3 do
			skillEffect:AddDelay(0.02)
			local point = p2 + DIR_VECTORS[dir]
			local dam = SpaceDamage(point, 0, DIR_FLIP)
			dam.sAnimation = "ExploRepulseSmall2"
			skillEffect:AddDamage(dam)
			----firefly boss custom flip
			local Mirror = false
			if Board:IsPawnSpace(point) and (Board:GetPawn(point):GetType() == "FireflyBoss" or Board:GetPawn(point):GetType() == "DNT_JunebugBoss") and Board:GetPawn(point):IsQueued()then
				Mirror = true
			end
			if Mirror then
				local threat = Board:GetPawn(point):GetQueuedTarget()
				local flip = (GetDirection(threat - point)+1)%4
				local newthreat = point + DIR_VECTORS[flip]
				if not Board:IsValid(newthreat) then
					newthreat = point - DIR_VECTORS[flip]
				end
				skillEffect:AddScript("Board:GetPawn("..point:GetString().."):SetQueuedTarget("..newthreat:GetString()..")")
			end
			----
		end
		skillEffect:AddBurst(p1, "Emitter_Confuse1", DIR_NONE)
	end
end

--unused function from beta version of idea
local function ProsperoUnconfuse(mission, pawn, undonePosition)
	if pawn and _G[pawn:GetType()].NicoIsRobot then
		local ret = SkillEffect()
		for dir = 0,3 do
			ret:AddDamage(SpaceDamage(undonePosition + DIR_VECTORS[dir], 0, DIR_FLIP))
		end
		Board:AddEffect(ret)
	end
end

local function EVENT_onModsLoaded() --This function will run when the mod is loaded
	modapiext:addSkillBuildHook(ProsperoConfuse)
	--modapiext:addPawnUndoMoveHook(ProsperoUnconfuse)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
--This tells the mod loader to run the above when loaded