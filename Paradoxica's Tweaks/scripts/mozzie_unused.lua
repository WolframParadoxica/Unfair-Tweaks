local function RepeaterInit(mission)
	mission.do_second_whip = true
	mission.boost_mozzie = false
end

local function BoostFlag(mission, pawn, weapon, p1, p2)
	if pawn:IsBoosted() and mission.do_second_whip then
		mission.boost_mozzie = true
	end
end

local function Repeater(mission, pawn, weapon, p1, p2)
	local slot = 0

	--figure out which weapon slot the whip is in, because not guaranteed to be in primary slot
	if pawn:GetEquippedWeapons()[1] == "Mozzie_Whip" then
		slot = 1
	elseif pawn:GetEquippedWeapons()[2] == "Mozzie_Whip" then
		slot = 2
	end

	if mission.boost_mozzie then
		pawn:SetBoosted(true)
		mission.boost_mozzie = false
	end

	if mission.do_second_whip and slot ~= 0 then
		Board:GetPawn(pawn):FireWeapon(p2,slot)
		mission.do_second_whip = false--prevent the skill from calling this hook again after the second instance
	end
end

local function RepeaterReset(mission)
	mission.do_second_whip = true
end

local function EVENT_onModsLoaded() --This function will run when the mod is loaded
	modApi:addMissionStartHook(RepeaterInit)
	--Set mission flags at the beginning of every mission to avoid a nil error
	modapiext:addSkillStartHook(BoostFlag)
	--Do this before the first attack is executed (if this does not work, try SkillBuildHook instead)
	modapiext:addSkillEndHook(Repeater)
	--Do this after the first attack has finished executing
	modApi:addNextTurnHook(RepeaterReset)
	--Do this every time the team turn changes
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
--This tells the mod loader to run the above when loaded