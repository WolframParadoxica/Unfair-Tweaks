-------------Void Shocker----------------

Passive_VoidShock = Passive_VoidShock:new{
	PowerCost = 1,
}

-------------Flame Shielding----------------

Passive_FlameImmune = Passive_FlameImmune:new{
	Upgrades = 1,
	UpgradeCost = {3},
}

Passive_FlameImmune_A = Passive_FlameImmune:new{
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Friendly = Point(3,2),
		Fire1 = Point(2,3),
		Fire2 = Point(2,1),
		Fire3 = Point(3,2),
		Target = Point(2,1),
		Second_Origin = Point(2,3),
		Second_Target = Point(2,1),
	}
}

function Passive_FlameImmune_A:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	if Board:GetPawn(Point(2,1)):GetHealth() == 5 then
		local damage = SpaceDamage(Point(2,1),2)
		damage.bHide = true
		ret:AddDamage(damage)
	else
		local damage = SpaceDamage(Point(2,1),1)
		damage.bHide = true
		ret:AddDamage(damage)
	end
	return ret
end

local function DoubleBurnTable(mission)
	mission.BurningPhase = false
	mission.DoubleBurn = false
	for i = 0,2 do
		if Board:GetPawn(i):IsWeaponPowered("Passive_FlameImmune_A") then
			mission.DoubleBurn = true
			mission.BurnTable = {}
		end
	end
end

local function Ignited(mission, pawn, isFire)
	local pawn_id = pawn:GetId()
	
	if pawn:IsEnemy() then
		mission.BurnTable = mission.BurnTable or {}
		mission.BurnTable[pawn_id] = mission.BurnTable[pawn_id] or {}
		mission.BurnTable[pawn_id].has_burned = mission.BurnTable[pawn_id].has_burned or false
		mission.BurnTable[pawn_id].is_fire = isFire
		--this line flags enemys that are on fire to handle burrowers instantly extinguishing after fire damage
		mission.BurnTable[pawn_id].eot_loc = mission.BurnTable[pawn_id].eot_loc
		if Board:IsValid(Board:GetPawnSpace(pawn_id)) then
			mission.BurnTable[pawn_id].eot_loc = Board:GetPawnSpace(pawn_id)
		end
		--these 2 lines marks down the enemy location to handle burrowers after they take the damage and hide, and also enemies taking electric damage
		--mission.BurnTable[pawn_id].is_suppressed = false
	end
end

local function Burn(mission, pawn, damageTaken)
	local health = pawn:GetHealth()
	local pawn_id = pawn:GetId()
	
	if pawn:IsEnemy() then
		mission.BurnTable = mission.BurnTable or {}
		mission.BurnTable[pawn_id] = mission.BurnTable[pawn_id] or {}
		mission.BurnTable[pawn_id].has_burned = mission.BurnTable[pawn_id].has_burned or false
		mission.BurnTable[pawn_id].is_fire = mission.BurnTable[pawn_id].is_fire or pawn:IsFire()
		--this line flags enemys that are on fire to handle burrowers instantly extinguishing after fire damage
		mission.BurnTable[pawn_id].eot_loc = mission.BurnTable[pawn_id].eot_loc
		if Board:IsValid(Board:GetPawnSpace(pawn_id)) then
			mission.BurnTable[pawn_id].eot_loc = Board:GetPawnSpace(pawn_id)
		end
		--these 2 lines marks down the enemy location to handle burrowers after they take the damage and hide, and also enemies taking electric damage
		mission.BurnTable[pawn_id].is_suppressed = mission.BurnTable[pawn_id].is_suppressed or false
		
		local electric_flag = (pawn:IsGuarding() and Board:IsSmoke(mission.BurnTable[pawn_id].eot_loc)) or (not pawn:IsGuarding() and Board:IsSmoke(Board:GetPawnSpace(pawn_id)))
		
		if mission.BurningPhase and mission.BurnTable[pawn_id].is_fire and mission.DoubleBurn and not mission.BurnTable[pawn_id].has_burned and not electric_flag then
			if mission.BurnTable[pawn_id].is_suppressed then
				--LOG("catcher")
				mission.BurnTable[pawn_id].is_suppressed = false
			elseif health > 1 then
				--LOG(pawn:GetMechName() .. " has been burnt!")
				modApi:scheduleHook(200, function()
					pawn:SetHealth(health-1)
					mission.BurnTable[pawn_id].has_burned = true
				end)
			elseif health == 1 then
				--LOG(pawn:GetMechName() .. " has been incinerated!")
				if pawn:IsBurrower() then
					local hook_flag = false
					modApi:conditionalHook(
						function()
							if pawn~=nil then
								return true
							else
								hook_flag = true
								return false
							end
						end,
						function()
							pawn:SetSpace(mission.BurnTable[pawn_id].eot_loc)
							if Board and Board:IsPawnAlive(pawn_id) then pawn:Kill(false) else hook_flag = true end
						end,
						hook_flag
					)
				else
					pawn:Kill(false)
				end
			end
		end
	end
end

local function PostBurn(mission)
	--LOG("The fire has finished burning!")
	mission.BurningPhase = false
end

local function SuppressDoubleBurn(mission, pawn)
    local pawn_loc = Board:GetPawnSpace(pawn:GetId())
	local mech_push_flag = (pawn:GetId() == 0 or pawn:GetId() == 1 or pawn:GetId() == 2) and IsPassiveSkill("Psion_Leech")
	local vek_push_flag = pawn:GetDefaultFaction() ~= FACTION_BOTS and pawn:GetTeam() == TEAM_ENEMY and (not _G[pawn:GetType()].Minor)
    
    if not mission.BurningPhase then
		--do nothing
    elseif _G[pawn:GetType()].Explodes or pawn:IsMutation(6) then
        for i = 0,3 do
            if not Board:IsValid(pawn_loc + DIR_VECTORS[i]) then
				--do nothing
            elseif Board:IsPawnSpace(pawn_loc + DIR_VECTORS[i]) and Board:GetPawn(pawn_loc + DIR_VECTORS[i]):IsEnemy() and Board:GetPawn(pawn_loc + DIR_VECTORS[i]):GetHealth() > 1 and Board:GetPawn(pawn_loc + DIR_VECTORS[i]):IsFire() and not Board:GetPawn(pawn_loc + DIR_VECTORS[i]):IsShield() then
				mission.BurnTable[Board:GetPawn(pawn_loc + DIR_VECTORS[i]):GetId()].is_suppressed = true
            end
        end
    elseif (mech_push_flag or vek_push_flag) and mission.DNT_Reactive1 then
        for i = 0,3 do
            if not Board:IsValid(pawn_loc + DIR_VECTORS[i]) or not Board:IsValid(pawn_loc + DIR_VECTORS[i]*2) then
                --LOG("empty")
				--do nothing
            elseif Board:IsPawnSpace(pawn_loc + DIR_VECTORS[i]) and not Board:GetPawn(pawn_loc + DIR_VECTORS[i]):IsGuarding() then
				--LOG("pushable")
                if Board:IsPawnSpace(pawn_loc + DIR_VECTORS[i]*2) or Board:IsBuilding(pawn_loc + DIR_VECTORS[i]*2) or Board:IsTerrain(pawn_loc + DIR_VECTORS[i]*2, TERRAIN_MOUNTAIN) then
					--LOG("collides")
					for j = 1,2 do
						if Board:IsPawnSpace(pawn_loc + DIR_VECTORS[i]*j) and Board:GetPawn(pawn_loc + DIR_VECTORS[i]*j):IsEnemy() and Board:GetPawn(pawn_loc + DIR_VECTORS[i]*j):IsFire() and not Board:GetPawn(pawn_loc + DIR_VECTORS[i]*j):IsShield() then
							--LOG("enemy pushed")
							mission.BurnTable[Board:GetPawn(pawn_loc + DIR_VECTORS[i]*j):GetId()].is_suppressed = true
						end
					end
                end
            end
        end
    end
end

----Psionic Receiver, Blast and Reactive Psion----
local function ExploPulse(mission)
	if IsPassiveSkill("Psion_Leech") and (mission.DNT_Reactive1 or Board:GetPawn(0):IsMutation(6) or Board:GetPawn(1):IsMutation(6) or Board:GetPawn(2):IsMutation(6)) then
		for i = 0,2 do
			if Board:GetPawn(i):GetHealth() > 0 then
				modApi:conditionalHook(
					function()
						return Board and (not Board:IsBusy())
					end,
					function()
						local pos = Board:GetPawn(i):GetSpace()
						if mission.DNT_Reactive1 and Board:IsValid(pos) then
							Board:AddAlert(pos,"PASSIVE REPULSE")
							local effect = SkillEffect()
							effect:AddAnimation(pos,"ExploRepulse3")
							effect:AddSound("/weapons/science_repulse")
							for k = DIR_START, DIR_END do
								if not Board:IsValid(pos + DIR_VECTORS[k]) or not Board:IsValid(pos + DIR_VECTORS[k]*2) then
								elseif Board:IsPawnSpace(pos + DIR_VECTORS[k]) and not Board:GetPawn(pos + DIR_VECTORS[k]):IsGuarding() then
									if Board:IsPawnSpace(pos + DIR_VECTORS[k]*2) or Board:IsBuilding(pos + DIR_VECTORS[k]*2) or Board:IsTerrain(pos + DIR_VECTORS[k]*2, TERRAIN_MOUNTAIN) then
										for j = 1,2 do
											if (Board:GetPawn(0):IsWeaponPowered("Passive_FlameImmune_A") or Board:GetPawn(1):IsWeaponPowered("Passive_FlameImmune_A") or Board:GetPawn(2):IsWeaponPowered("Passive_FlameImmune_A")) and Board:IsPawnSpace(pos + DIR_VECTORS[k]*j) and Board:GetPawn(pos + DIR_VECTORS[k]*j):IsEnemy() and Board:GetPawn(pos + DIR_VECTORS[k]*j):IsFire() and not Board:GetPawn(pos + DIR_VECTORS[k]*j):IsShield() then
												mission.BurnTable = mission.BurnTable or {}
												mission.BurnTable[Board:GetPawn(pos + DIR_VECTORS[k]*j):GetId()].is_suppressed = true
											end
										end
									end
								end
								local damage = SpaceDamage(pos + DIR_VECTORS[k], 0)
								damage.iPush = k
								damage.sAnimation = "airpush_"..k
								if k==3 then damage.fDelay = 0.5 end
								effect:AddDamage(damage)
							end
							effect:AddDelay(1.0)
							Board:AddEffect(effect)
						end
						if Board:GetPawn(i):IsMutation(6) and Board:IsValid(pos) then
							Board:AddAlert(pos,"PASSIVE BLAST")
							local effect = SkillEffect()
							effect:AddAnimation(pos,"explo_fire1")
							effect:AddSound("/impact/generic/explosion_large")
							for k = DIR_START, DIR_END do
								local curr = pos + DIR_VECTORS[k]
								local damage = SpaceDamage(curr, 1)
								damage.sAnimation = "exploout1_"..k
								if Board:IsPawnSpace(curr) and (_G[Board:GetPawn(curr):GetType()].Armor or Board:GetPawn(curr):IsMutation(5)) then damage = SpaceDamage(curr, 2) end
								if Board:IsBuilding(curr) or Board:IsPod(curr) or (Board:IsPawnSpace(curr) and Board:GetPawn(curr):GetTeam() == TEAM_PLAYER) then damage = SpaceDamage(curr, 0) damage.sAnimation = "" end
								local acid_flag = false
								local flyer_flag = true
								if Board:IsPawnSpace(curr) and Board:GetPawn(curr):GetTeam() == TEAM_ENEMY then
									if (Board:GetPawn(0):IsWeaponPowered("Passive_FlameImmune_A") or Board:GetPawn(1):IsWeaponPowered("Passive_FlameImmune_A") or Board:GetPawn(2):IsWeaponPowered("Passive_FlameImmune_A")) and Board:IsPawnSpace(curr) and Board:GetPawn(curr):IsEnemy() and Board:GetPawn(curr):IsFire() and not Board:GetPawn(curr):IsShield() then
										mission.BurnTable = mission.BurnTable or {}
										mission.BurnTable[Board:GetPawn(curr):GetId()].is_suppressed = true
									end
									if Board:GetPawn(curr):IsAcid() and Board:GetPawn(curr):GetHealth()>1 then
										if Board:GetPawn(curr):IsFlying() then
											flyer_flag = true
										else
											effect:AddScript("Board:GetPawn("..curr:GetString().."):SetFlying(true)")
											flyer_flag = false
										end
										effect:AddScript("Board:GetPawn("..curr:GetString().."):SetAcid(false)")
										acid_flag = true
									end
								end
								if k==3 then damage.fDelay = 0.5 end
								effect:AddDamage(damage)
								if not flyer_flag then
									effect:AddScript("Board:GetPawn("..curr:GetString().."):SetFlying(false)")
								end
								if acid_flag then
									effect:AddScript("Board:GetPawn("..curr:GetString().."):SetAcid(true)")
								end
							end
							effect:AddDelay(1.0)
							Board:AddEffect(effect)
						end
					end
				)
			end
		end
	end
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
					GetCurrentMission().BurningPhase = true
					ExploPulse(GetCurrentMission())
					GetCurrentMission().BurnTable = GetCurrentMission().BurnTable or {}
					for i = 0,2 do
						if Board:GetPawn(i):IsWeaponPowered("Passive_FlameImmune_A") then
							GetCurrentMission().DoubleBurn = true
						end
					end
					local pawnList = extract_table(Board:GetPawns(TEAM_ENEMY))
					if GetCurrentMission().DoubleBurn then
						for i = 1, #pawnList do
							GetCurrentMission().BurnTable[pawnList[i]] = GetCurrentMission().BurnTable[pawnList[i]] or {}
							GetCurrentMission().BurnTable[pawnList[i]].has_burned = GetCurrentMission().BurnTable[pawnList[i]].has_burned or false
							GetCurrentMission().BurnTable[pawnList[i]].is_fire = Board:GetPawn(pawnList[i]):IsFire()
							GetCurrentMission().BurnTable[pawnList[i]].eot_loc = Board:GetPawnSpace(pawnList[i])
							GetCurrentMission().BurnTable[pawnList[i]].is_suppressed = false
						end
					end
					if Board:IsPawnSpace(Point(4,6)) and Board:GetPawn(Point(4,6)):GetType() == "Train_Pawn" and Board:IsBuilding(Point(3,5)) and Board:IsBuilding(Point(5,5)) then
						Board:SetDangerous(Point(4,5))
					end
				end 
            end 
            return oldfn(...) 
        end 
    end 
end

----Psionic Receiver, Smoldering Psion----

local function TurnTile(mission)
	if Game:GetTeamTurn() == TEAM_PLAYER then
		if IsPassiveSkill("Psion_Leech") and (Board:GetPawn(0):IsMutation(10) or Board:GetPawn(1):IsMutation(10) or Board:GetPawn(2):IsMutation(10)) then
			mission.Para_UndoTile = mission.Para_UndoTile or {}
			for i = 1,3 do
				local curr = Board:GetPawn(i-1):GetSpace()
				mission.Para_UndoTile[i] = mission.Para_UndoTile[i] or {}
				mission.Para_UndoTile[i].WasBurning = Board:GetPawn(i-1):IsFire()
				mission.Para_UndoTile[i].WasForest = Board:IsTerrain(curr,TERRAIN_FOREST)
				mission.Para_UndoTile[i].WasFire = Board:IsFire(curr)
				mission.Para_UndoTile[i].WasSand = Board:IsTerrain(curr,TERRAIN_SAND)
				mission.Para_UndoTile[i].WasSmoke = Board:IsSmoke(curr)
				--mission.Para_UndoTile[i].WasFart = false
				--if (mission.DNT_FartList ~= nil) and (#mission.DNT_FartList > 0) then
					--for i = 1,#mission.DNT_FartList do
						--mission.Para_UndoTile[i].WasFart = (mission.DNT_FartList[i] == curr) or false
					--end
				--end
				mission.Para_UndoTile[i].WasAcid = Board:IsAcid(curr)
				mission.Para_UndoTile[i].WasIce = Board:IsTerrain(curr,TERRAIN_ICE) and Board:GetHealth(curr) == 2
				mission.Para_UndoTile[i].WasCrackedIce = Board:IsTerrain(curr,TERRAIN_ICE) and Board:GetHealth(curr) == 1
			end
		end
	end
end

local function MechMoved(mission, pawn)
	local i = pawn:GetId()+1
	local curr = pawn:GetSpace()
	if IsPassiveSkill("Psion_Leech") and pawn:IsMutation(10) then
		mission.Para_UndoTile = mission.Para_UndoTile or {}
		mission.Para_UndoTile[i] = mission.Para_UndoTile[i] or {}
		--mission.Para_UndoTile[i].UndoPoint = curr
		mission.Para_UndoTile[i].WasBurning = pawn:IsFire()
		mission.Para_UndoTile[i].WasForest = Board:IsTerrain(curr,TERRAIN_FOREST)
		mission.Para_UndoTile[i].WasFire = Board:IsFire(curr)
		mission.Para_UndoTile[i].WasSand = Board:IsTerrain(curr,TERRAIN_SAND)
		mission.Para_UndoTile[i].WasSmoke = Board:IsSmoke(curr)
		--mission.Para_UndoTile[i].WasFart = false
		--if (mission.DNT_FartList ~= nil) and (#mission.DNT_FartList > 0) then
			--for i = 1,#mission.DNT_FartList do
			--	mission.Para_UndoTile[i].WasFart = (mission.DNT_FartList[i] == curr) or false
			--end
		--end
		mission.Para_UndoTile[i].WasAcid = Board:IsAcid(curr)
		mission.Para_UndoTile[i].WasIce = Board:IsTerrain(curr,TERRAIN_ICE) and Board:GetHealth(curr) == 2
		mission.Para_UndoTile[i].WasCrackedIce = Board:IsTerrain(curr,TERRAIN_ICE) and Board:GetHealth(curr) == 1
		Game:TriggerSound("/impact/generic/explosion_large")
		Board:AddAnimation(pawn:GetSpace(), "explo_fire1", 0)
		Board:SetFire(pawn:GetSpace(),true)
		--pawn:SetUndoLoc(Point(0,0))
	end
end

local function MechUnmoved(mission, pawn, undonePosition)
	if IsPassiveSkill("Psion_Leech") and pawn:IsMutation(10) then
		local i = pawn:GetId()+1
		local loc = pawn:GetSpace()
		--local loc = mission.Para_UndoTile[i].UndoPoint
		if not mission.Para_UndoTile[i].WasFire then Board:SetFire(loc,false) end
		if not mission.Para_UndoTile[i].WasBurning then pawn:SetFire(false) end
		
		modApi:runLater(function() --This runs a function one frame later so things get updated
			if mission.Para_UndoTile[i].WasSand then Board:SetTerrain(loc,TERRAIN_SAND) end
			if mission.Para_UndoTile[i].WasSmoke then Board:SetSmoke(loc,true,true) end
			--if mission.Para_UndoTile[i].WasFart then Board:SetSmoke(loc,true,true) end--table.insert(mission.DNT_FartList,loc) end
			if mission.Para_UndoTile[i].WasAcid then Board:SetAcid(loc,true) end
			if mission.Para_UndoTile[i].WasIce then Board:SetTerrain(loc,TERRAIN_ICE) end
			if mission.Para_UndoTile[i].WasCrackedIce then Board:SetTerrain(loc,TERRAIN_ICE) Board:SetHealth(loc, 1, 2) end
			if mission.Para_UndoTile[i].WasForest then Board:SetTerrain(loc,TERRAIN_FOREST) end
			--modApi:runLater(function() pawn:SetSpace(loc) pawn:SetUndoLoc(loc) end)
		end)
	end
end

local function EventFlagger(mission)
	for i = 0,199 do
		if i ~= 1 and i~= 4 and i ~= 5 and i ~= 11 and i ~= 78 and i ~= 79 and Game:IsEvent(i) then LOG(i) end
	end
end

local function EVENT_onModsLoaded() --This function will run when the mod is loaded
	--modapiext is requested in the init.lua
	modApi:addMissionStartHook(DoubleBurnTable)
	--This line tells us that we want to run the above function every time a mission is entered
	modapiext:addPawnDamagedHook(Burn)
	--This line tells us that we want to run the above function every time a pawn takes damage
	modapiext:addPawnIsFireHook(Ignited)
	--This line tells us that we want to run the above function every time a pawn is ignited
	modApi:addPreEnvironmentHook(PostBurn)
	--This line tells us that we want to run the above function after the fire damage phase has taken place
	modapiext:addPawnKilledHook(SuppressDoubleBurn)
	--This line tells us that we want to run the above function every time a pawn dies
	--modApi:addMissionStartHook(TurnTile)
	--This line tells us that we want to run the above function every time a mission is entered
	modApi:addNextTurnHook(TurnTile)
	--This line tells us that we want to run the above function every time the turn changes teams
	modapiext:addPawnMoveStartHook(MechMoved)
	--This line tells us that we want to run the above function every time a mech moves (what about tank missions?)
	modapiext:addPawnUndoMoveHook(MechUnmoved)
	--This line tells us that we want to run the above function every time a move is undone
	--modApi:addMissionUpdateHook(EventFlagger)
	--called every frame during missions
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
--This tells the mod loader to run the above when loaded