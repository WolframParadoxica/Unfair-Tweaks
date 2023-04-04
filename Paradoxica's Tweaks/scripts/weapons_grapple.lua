-------------- WallMech - Grapple  -----------------

Brute_Grapple = {
	Class = "Brute",
	Rarity = 1,
	Icon = "weapons/brute_grapple.png",	
	Explosion = "",
	Shield = 0,
	ShieldFriendly = 0,
	Refuel = false,
	Damage = 0,
	Range = RANGE_PROJECTILE,--TOOLTIP info
	Cost = "low",
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 1,1 },
	LaunchSound = "/weapons/grapple",
	ImpactSound = "/impact/generic/grapple",
	ZoneTargeting = ZONE_DIR,
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,0),
		Target = Point(2,0),
		Second_Origin = Point(2,2),
		Second_Target = Point(2,4),
		Mountain = Point(2,4),
	}
}
			
Brute_Grapple = Skill:new(Brute_Grapple)

function Brute_Grapple:GetTargetArea(point)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
		local this_path = {}
		
		local target = point + DIR_VECTORS[dir]

		while not Board:IsBlocked(target, PATH_PROJECTILE) do
			this_path[#this_path+1] = target
			target = target + DIR_VECTORS[dir]
		end
		
		if Board:IsValid(target) and target:Manhattan(point) > 1 then
			this_path[#this_path+1] = target
			for i,v in ipairs(this_path) do 
				ret:push_back(v)
			end
		end
	end
	
	return ret
end

function Brute_Grapple:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local mechId = Board:GetPawn(p1):GetId()
	
	local target = p1 + DIR_VECTORS[direction]

	while not Board:IsBlocked(target, PATH_PROJECTILE) do
		target = target + DIR_VECTORS[direction]
	end
	
	if not Board:IsValid(target) then
		return ret
	end
	
	local damage = SpaceDamage(target)
	damage.bHidePath = true
	ret:AddProjectile(damage,"effects/shot_grapple")
	
	if Board:IsPawnSpace(target) and not Board:GetPawn(target):IsGuarding() then	-- If it's a pawn

		ret:AddCharge(Board:GetSimplePath(target, p1 + DIR_VECTORS[direction]), FULL_DELAY)

		if Board:IsPawnTeam(target, TEAM_PLAYER) then
			local shielddamage = SpaceDamage(p1 + DIR_VECTORS[direction],0)
			shielddamage.iShield = self.ShieldFriendly
			ret:AddDamage(shielddamage)
		end
	elseif Board:IsBlocked(target, Pawn:GetPathProf()) then     --If it's an obstruction
		ret:AddCharge(Board:GetSimplePath(p1, target - DIR_VECTORS[direction]), FULL_DELAY)	
		if Board:IsBuilding(target) or Board:IsPawnTeam(target, TEAM_PLAYER) then
			local spaceDamage = SpaceDamage(target)
			spaceDamage.iShield = self.ShieldFriendly
			ret:AddDamage(spaceDamage)
		end
	end
	
	if self.Refuel and not Board:IsTipImage() then
		if Board:GetPawn(mechId):IsAbility("Double_Shot") then
			--do nothing
		elseif GetCurrentMission().Para_Grapple_Refuel[mechId + 1] then
			ret:AddScript("Board:GetPawn("..mechId.."):SetActive(true)")
		end
	end
	return ret
end

Brute_Grapple_A = Brute_Grapple:new{
		ShieldFriendly = 1,
		TipImage = {
			Unit = Point(2,2),
			Friendly = Point(2,0),
			Target = Point(2,0),
			Second_Origin = Point(2,2),
			Second_Target = Point(2,4),
			Building = Point(2,4),
		}
}

Brute_Grapple_B = Brute_Grapple:new{
	Refuel = true,
}

Brute_Grapple_AB = Brute_Grapple_A:new{
	Refuel = true,
}

local function GrappleRefuel(mission, pawn, weaponId, p1, p2)
	if Board:IsTipImage() then
		if weaponId == "Brute_Grapple_B" or weaponId == "Brute_Grapple_AB" then
			Board:AddAlert(pawn:GetSpace(),"REACTIVATED") return end
		return
	end
	if mission == nil then return end
	if pawn == nil then return end
	if pawn:IsAbility("Double_Shot") then
		if weaponId ~= "Move" then mission.Para_Silica_Actions = mission.Para_Silica_Actions + 1 end
		if weaponId == "Move" then mission.Para_Silica_Moved = true end
	end
	if pawn:IsAbility("Shifty") then
		if weaponId == "Move" and not mission.Para_Grapple_Refuel[pawn:GetId() + 1] and mission.Para_Chen_Refuel then
			Board:AddAlert(pawn:GetSpace(),"REACTIVATED")
			pawn:SetActive(true)
		end
		if weaponId ~= "Move" and not mission.Para_Grapple_Refuel[pawn:GetId() + 1] then
			mission.Para_Chen_Refuel = false
		end
	end
	if pawn:IsAbility("Post_Move") then
		if weaponId == "Move" and not mission.Para_Grapple_Refuel[pawn:GetId() + 1] and mission.Para_Archie_Refuel then
			Board:AddAlert(pawn:GetSpace(),"REACTIVATED")
			pawn:SetActive(true)
		end
		if weaponId ~= "Move" and not mission.Para_Grapple_Refuel[pawn:GetId() + 1] then
			mission.Para_Archie_Refuel = false
		end
	end
	if weaponId == "Brute_Grapple_B" or weaponId == "Brute_Grapple_AB" then
		if mission.Para_Grapple_Refuel[pawn:GetId() + 1] and not (pawn:IsAbility("Post_Move") or pawn:IsAbility("Shifty")) then
			if not pawn:IsAbility("Double_Shot") then Board:AddAlert(pawn:GetSpace(),"REACTIVATED") end
			if pawn:IsAbility("Double_Shot") and mission.Para_Silica_Moved then Board:AddAlert(pawn:GetSpace(),"REACTIVATED") end
		end
		mission.Para_Grapple_Refuel[pawn:GetId() + 1] = false
		if pawn:IsAbility("Double_Shot") then
			mission.Para_Silica_Grapples = mission.Para_Silica_Grapples + 1
		end
	end
	
	if pawn:IsAbility("Double_Shot") and weaponId ~= "Move" and (mission.Para_Silica_Grapples >= mission.Para_Silica_Actions - 1) and mission.Para_Silica_Refuels<2 and mission.Para_Silica_Grapples>0 and mission.Para_Silica_Actions>1 then
		pawn:SetActive(true)
		mission.Para_Silica_Refuels = mission.Para_Silica_Refuels + 1
		Board:AddAlert(pawn:GetSpace(),"REACTIVATED")
	end
end

local function RefuelTracker(mission, pawn, weaponId, p1, p2, p3)
	if mission == nil then return end
	if pawn == nil then return end
	if pawn:IsAbility("Double_Shot") then
		mission.Para_Silica_Actions = mission.Para_Silica_Actions + 1
	end
	if pawn:IsAbility("Shifty") then
		if not mission.Para_Grapple_Refuel[pawn:GetId() + 1] then
			mission.Para_Chen_Refuel = false
		end
	end
	if pawn:IsAbility("Post_Move") then
		if not mission.Para_Grapple_Refuel[pawn:GetId() + 1] then
			mission.Para_Archie_Refuel = false
		end
	end
	if pawn:IsAbility("Double_Shot") and (mission.Para_Silica_Grapples >= mission.Para_Silica_Actions - 1) and mission.Para_Silica_Refuels<2 and mission.Para_Silica_Grapples>0 and mission.Para_Silica_Actions>1 then
		pawn:SetActive(true)
		mission.Para_Silica_Refuels = mission.Para_Silica_Refuels + 1
		Board:AddAlert(pawn:GetSpace(),"REACTIVATED")
	end
end

local function SilicaUnmoved(mission, pawn, undonePosition)
	if pawn:IsAbility("Double_Shot") then mission.Para_Silica_Moved = false end
end

--this section detects the event that triggers when End Turn is pressed
EXCL = {
    "GetAmbience", 
    "GetBonusStatus", 
    "BaseUpdate", 
    "UpdateMission", 
    "GetCustomTile", 
    "GetDamage", 
    "GetTurnLimit", 
    "BaseObjectives",
    "UpdateObjectives",
} 

for i,v in pairs(Mission) do 
    if type(v) == 'function' then 
        local oldfn = v 
        Mission[i] = function(...) 
            if not list_contains(_G["EXCL"], i) then 
                if i == "IsEnvironmentEffect" then
					--LOG("The fire has started burning!")
					GetCurrentMission().Para_Grapple_Refuel = {true,true,true}
					GetCurrentMission().Para_Silica_Moved = false
					GetCurrentMission().Para_Silica_Actions = 0
					GetCurrentMission().Para_Silica_Grapples = 0
					GetCurrentMission().Para_Silica_Refuels = 0
					GetCurrentMission().Para_Chen_Refuel = true
					GetCurrentMission().Para_Archie_Refuel = true
				end
            end 
            return oldfn(...) 
        end 
    end 
end

local function EVENT_onModsLoaded() --This function will run when the mod is loaded
	modapiext:addSkillEndHook(GrappleRefuel)
	modapiext:addFinalEffectEndHook(RefuelTracker)
	modapiext:addPawnUndoMoveHook(SilicaUnmoved)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
