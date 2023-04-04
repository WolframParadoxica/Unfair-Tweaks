--------------  Boosters    -----------------

Support_Boosters = Leap_Attack:new{
	Class = "",
	Icon = "weapons/brute_boosters.png",	
	Rarity = 1,
	Range = 7,
	Cost = "med",
	PowerCost = 0, 
	Upgrades = 1,
	UpgradeCost = {2},
	Push = 1,
	SelfDamage = 0,
	LaunchSound = "/weapons/boosters",
	ImpactSound = "/impact/generic/mech",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,1),
		Enemy2 = Point(3,2),
		Target = Point(2,2)
	}
}

Support_Boosters_A = Support_Boosters:new{
	TwoClick = true,
	ImpactSound = "",
	TipImage = {
		Unit = Point(0,3),
		Enemy1 = Point(3,3),
		Enemy2 = Point(3,2),
		Friendly = Point(2,3),
		Target = Point(3,1),
		Second_Click = Point(3,3),
	}
}

function Support_Boosters_A:GetTargetArea(point)
	local ret = PointList()
	for i, p in ipairs(Board) do
		if not Board:IsBlocked(p, Pawn:GetPathProf()) then ret:push_back(p) end
	end

	return ret
end

function Support_Boosters_A:IsTwoClickException(p1,p2)
	if (self:GetTargetArea(p1,p2)):size() == 0 then
		return true
	end
	return false
end

function Support_Boosters_A:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	if (p1.x == p2.x) or (p1.y == p2.y) then
		local dir = GetDirection(p2 - p1)
		for i = -7,7 do
			local curr = p1 + DIR_VECTORS[dir]*i
			if Board:IsValid(curr) and curr ~= p2 then
				ret:push_back(curr)
			end
			curr = p2 + DIR_VECTORS[(dir + 1)%4]*i
			if Board:IsValid(curr) and curr ~= p2 then
				ret:push_back(curr)
			end
		end
	else
		ret:push_back(Point(p1.x,p2.y))
		ret:push_back(Point(p2.x,p1.y))
	end

	return ret
end

function Support_Boosters_A:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()
	--ret:AddDelay(FULL_DELAY)
	local dir = GetDirection(p2 - p1)
	--ret:AddSound(self.LaunchSound)
	local move = PointList()
	move:push_back(p1)
	move:push_back(p2)
	ret:AddBurst(p1,"Emitter_Burst_$tile",DIR_NONE)
	ret:AddLeap(move, FULL_DELAY)
	ret:AddBurst(p2,"Emitter_Burst_$tile",DIR_NONE)
	
	local backwards = (dir + 2) % 4
	for i = DIR_START, DIR_END do
		if p1:Manhattan(p2) ~= 1 or i ~= backwards then
			local dam = SpaceDamage(p2 + DIR_VECTORS[i], self.Damage)
			if self.Push == 1 then dam.iPush = i end
			dam.sAnimation = PUSH_ANIMS[i]
			if self.PushAnimation == 1 then dam.sAnimation = PUSHEXPLO1_ANIMS[i]   --JUSTIN ADDED
			elseif self.PushAnimation == 2 then dam.sAnimation = PUSHEXPLO2_ANIMS[i] end
			
			if not self.BuildingDamage and Board:IsBuilding(p2 + DIR_VECTORS[i]) then		-- Target Buildings - 
				dam.iDamage = 0
			end
			ret:AddDamage(dam)
		end
	end

	local damage = SpaceDamage(p2, self.SelfDamage)
	damage.sAnimation = self.SelfAnimation
	if self.SelfDamage ~= 0 then ret:AddDamage(damage) end
	ret:AddBounce(p2,3)
	ret:AddSound("/impact/generic/mech")
	damage = SpaceDamage(p2,0)
	damage.fDelay = 2.5
	ret:AddDamage(damage)
	ret:AddSound("/weapons/airstrike")
	ret:AddAirstrike(p3,"units/mission/bomber_1.png")
	local dam = SpaceDamage(p3,self.SelfDamage)
	dam.sAnimation = "ExploRepulse1"
	dam.sSound = "/impact/generic/explosion_large"
	dam.fDelay = -1
	ret:AddDamage(dam)
	ret:AddBounce(p3, 3)

	for i = DIR_START, DIR_END do
		dam = SpaceDamage(p3 + DIR_VECTORS[i],0,i)
		dam.sAnimation = PUSH_ANIMS[i]
		ret:AddDamage(dam)
	end
	return ret
	
end

-------------- Refrigerate ---------------------------

Support_Refrigerate = Skill:new{  
	Class = "",
	Icon = "weapons/support_refrigerate.png",
	Explosion = "",
	ProjectileArt = "effects/shot_tankice",
	LaunchSound = "/weapons/doubleshot",
	ImpactSound = "/impact/generic/explosion",
	Range = 1, -- Tooltip?
	TwoClick = true,
	PathSize = 1,
	Damage = 0,
	Push = 0,
	PowerCost = 0, --AE Change
	Limited = 1,
	Upgrades = 1,
	UpgradeCost = {1},
	--UpgradeList = { "+1 Use" },
	TipImage = {
		Unit = Point(1,3),
		Enemy = Point(1,1),
		Enemy2 = Point(3,3),
		Target = Point(1,1),
		Second_Click = Point(3,3),
	}
}

function Support_Refrigerate:GetTargetArea(p1)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		for i = 1, 8 do
			local curr = Point(p1 + DIR_VECTORS[dir] * i)
			if not Board:IsValid(curr) then
				break
			end
			
			ret:push_back(curr)
			
			if Board:IsBlocked(curr,PATH_PROJECTILE) then
				break
			end
		end
	end

	return ret
end

function Support_Refrigerate:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local target1 = GetProjectileEnd(p1,p2,PATH_PROJECTILE)  
	
	local damage1 = SpaceDamage(target1, 0)
	damage1.iFrozen = 1
	damage1.sSound = "/impact/generic/explosion"
	ret:AddProjectile(damage1, self.ProjectileArt, NO_DELAY)
	
	return ret
end

function Support_Refrigerate:GetSecondTargetArea(p1,p2)
	local dir = GetDirection(p2-p1)
	local ret = PointList()
	
	for i = 1, 3 do
		for j = 1, 8 do
			local curr = Point(p1 + DIR_VECTORS[(dir+i)%4] * j)
			if not Board:IsValid(curr) then
				break
			end
			ret:push_back(curr)
			
			if Board:IsBlocked(curr, PATH_PROJECTILE) then
				break
			end
		end
	end
	return ret
end

function Support_Refrigerate:GetFinalEffect(p1, p2, p3)
	local ret = self:GetSkillEffect(p1,p2)
	local target1 = GetProjectileEnd(p1,p2,PATH_PROJECTILE)  
	local target2 = GetProjectileEnd(p1,p3,PATH_PROJECTILE)  
	
	local damage1 = SpaceDamage(target1, 0)
	damage1.iFrozen = 1
	damage1.sSound = "/impact/generic/ice"
	ret:AddProjectile(damage1, self.ProjectileArt, NO_DELAY)
	
	local damage2 = SpaceDamage(target2, 0, GetDirection(p3-p1))
	damage2.iFire = 1
	damage2.sSound = "/props/fire_damage"
	ret:AddProjectile(damage2, "effects/shot_mechtank", NO_DELAY)
	
	return ret
end	

Support_Refrigerate_A = Support_Refrigerate:new{
		Limited = 2, 
}

-----------------FORCE -----------------

Support_Force = Support_Force:new{  
	Upgrades = 2,
	UpgradeCost = {1,1},
	Acid = false,
	Fire = false,
}	

function Support_Force:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	ret:AddSound("/weapons/airstrike")
	ret:AddAirstrike(p2,"units/mission/bomber_1.png")
	local dam = SpaceDamage(p2,self.Damage)
	dam.sAnimation = "ExploArt2"
	dam.sSound = "/impact/generic/explosion_large"
	if self.Fire then
		dam.iFire = 1
	end
	ret:AddDamage(dam)
	ret:AddBounce(p2, 2)
	
	for i = DIR_START, DIR_END do
		dam = SpaceDamage(p2 + DIR_VECTORS[i],0,i)
		if self.Acid then
			dam.iAcid = 1
		end
		dam.sAnimation = PUSH_ANIMS[i]
		ret:AddDamage(dam)
	end
	
	return ret
end				

Support_Force_A = Support_Force:new{  
	Acid = true,
}

Support_Force_B = Support_Force:new{  
	Fire = true,
}

Support_Force_AB = Support_Force:new{  
	Acid = true,
	Fire = true,
}
--------------  Storm Surge    -----------------

Support_Wind = Skill:new{
	Class = "",
	Icon = "weapons/support_wind.png",
	UpShot = "effects/shotup_swarm.png",
	Damage = 0,
	PathSize = 1,
	PowerCost = 1, --AE Change
	Limited = 1,
	Upgrades = 1,
	UpgradeCost = { 3 },
	LaunchSound = "/weapons/wind",
	ZoneTargeting = ZONE_CUSTOM,
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Enemy2 = Point(3,2),
		Enemy3 = Point(0,2),
		Mountain = Point(3,1),
		Friendly = Point(1,2),
		Target = Point(3,2),
	}
}

function Support_Wind:GetTargetZone(piOrigin, p)
	local targets = self:GetTargetArea()
	local ret = PointList()
	for i = 1, targets:size() do
		if p == targets:index(i) then
			local start_index = math.floor((i-1) / 4)*4 + 1
			--LOG("Found target. Index = "..i.." Group index starts at "..start_index.."\n")
			for j = start_index, start_index + 3 do
				ret:push_back(targets:index(j))
			end
			return ret
		end
	end
	return ret
end

function Support_Wind:GetTargetArea(point)

	local ret = PointList()
	
	ret:push_back(Point(1,3))
	ret:push_back(Point(1,4))
	ret:push_back(Point(2,3))
	ret:push_back(Point(2,4))
	
	ret:push_back(Point(5,3))
	ret:push_back(Point(5,4))
	ret:push_back(Point(6,3))
	ret:push_back(Point(6,4))
	
	ret:push_back(Point(3,1))
	ret:push_back(Point(3,2))
	ret:push_back(Point(4,1))
	ret:push_back(Point(4,2))
	
	ret:push_back(Point(3,5))
	ret:push_back(Point(3,6))
	ret:push_back(Point(4,5))
	ret:push_back(Point(4,6))
	
	return ret
end
	
function Support_Wind:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = DIR_NONE
	
	if p2.x == 1 or p2.x == 2 then dir = DIR_LEFT
	elseif p2.x == 5 or p2.x == 6 then dir = DIR_RIGHT
	elseif p2.y == 1 or p2.y == 2 then dir = DIR_UP
	elseif p2.y == 5 or p2.y == 6 then dir = DIR_DOWN end
	
	
	ret:AddEmitter(Point(3,3),"Emitter_Wind_"..dir)
	ret:AddEmitter(Point(4,4),"Emitter_Wind_"..dir)
	local board_size = Board:GetSize()
	for i = 0, 7 do
		for j = 0, 7  do
			local point = Point(i,j) -- DIR_LEFT
			if dir == DIR_RIGHT then
				point = Point(7 - i, j)
			elseif dir == DIR_UP then
				point = Point(j,i)
			elseif dir == DIR_DOWN then
				point = Point(j,7-i)
			end
			
			if Board:IsPawnSpace(point) then
				ret:AddDamage(SpaceDamage(point, 0, dir))
				ret:AddDelay(0.2)
			end
		end
	end
	
	return ret
	
end

Support_Wind_A = Support_Wind:new{
	Limited = 0,
}

----------- Local Blizzard ------------------------

Support_Blizzard = Science_LocalShield:new{  
	Class = "",
	Icon = "weapons/support_blizzard.png",
	Explosion = "",
	Damage = 0,
	PathSize = 1,
	PowerCost = 1, --AE Change
	IceVersion = 1,
	WideArea = 1,
	Push = 1,--TOOLTIP HELPER,
	Range = 1,--TOOLTIP HELPER
	Limited = 1,
	Upgrades = 1,
	UpgradeCost = {2},
	UpgradeList = { "+1 Size",  "+1 Size"  },
	LaunchSound = "/weapons/blizzard",
	ZoneTargeting = ZONE_ALL,
}

Support_Blizzard_A = Support_Blizzard:new{
		WideArea = 2,
		TipImage = {
			Unit = Point(2,2),
			Target = Point(2,1),
			Friendly = Point(2,3),
			Friendly2 = Point(3,2),
			Friendly3 = Point(4,2),
			Building = Point(2,1),
			Building1 = Point(1,1),
			Enemy = Point(1,2)
		}
}

Support_Blizzard_B = Support_Blizzard:new{
		WideArea = 2,
		TipImage = {
			Unit = Point(2,2),
			Target = Point(2,1),
			Friendly = Point(2,3),
			Friendly2 = Point(3,2),
			Friendly3 = Point(4,2),
			Building = Point(2,1),
			Building1 = Point(1,1),
			Enemy = Point(1,2)
		}
}

Support_Blizzard_AB = Support_Blizzard:new{
		WideArea = 3,
		TipImage = {
			Unit = Point(2,2),
			Target = Point(2,1),
			Friendly = Point(2,3),
			Friendly2 = Point(3,2),
			Friendly3 = Point(4,2),
			Building = Point(2,1),
			Building1 = Point(1,1),
			Building2 = Point(0,1),
			Building3 = Point(4,3),
			Enemy = Point(1,2)
		}
}

----------- Local Confusion! ------------------------
Support_Confuse = Science_LocalShield:new{  
	Class = "",
	Icon = "advanced/weapons/Support_Confuse.png",
	LaunchSound = "/weapons/confusion",
	Explosion = "",
	Damage = 0,
	PathSize = 1,
	PowerCost = 0,
	WideArea = 2,
	Everywhere = false,
	Limited = 1,
	Upgrades = 2,
	UpgradeCost = { 1,2 },
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy1 = Point(2,3),
		Enemy2 = Point(3,2),
		Enemy3 = Point(2,1),
		Queued1 = Point(2,2),
		Queued2 = Point(2,2),
		Queued3 = Point(2,2),
		CustomEnemy = "Firefly2"
	}
}

function Support_Confuse:FireFlyBossFlip(point)
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
		return "Board:GetPawn("..point:GetString().."):SetQueuedTarget("..newthreat:GetString()..")"
	else
		return ""
	end
end

function Support_Confuse:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	
	local damage = SpaceDamage(p1,0)
	damage.sAnimation = "ExploRepulse3"
	ret:AddDamage(damage)
	
	if self.Everywhere then
		for i, p in ipairs(Board) do
			local dam = SpaceDamage(p,0,DIR_FLIP)
			dam.sAnimation = "ExploRepulseSmall2"
			ret:AddDamage(dam)
			ret:AddScript(self:FireFlyBossFlip(p))
		end
	else
		local damage = SpaceDamage(p2,0,DIR_FLIP)
		--local storm_spot = p1 + Point(-1*self.WideArea,-1*self.WideArea)
		--local storm_size = Point(3,3) + Point(self.WideArea,self.WideArea)
		--ret:AddScript("Board:SetWeather(5,"..RAIN_SNOW..","..storm_spot:GetString()..","..storm_size:GetString()..",2)")
		ret:AddDelay(0.2)
		
		
		for i = DIR_START, DIR_END do
			ret:AddDelay(0.02)
			damage.loc = p1 + DIR_VECTORS[i]
			damage.sAnimation = "ExploRepulseSmall2"
			ret:AddDamage(damage)
			ret:AddScript(self:FireFlyBossFlip(p1+DIR_VECTORS[i]))
			
			
			if self.WideArea > 1 then
				ret:AddDelay(0.02)
				damage.loc = p1 + DIR_VECTORS[i] + DIR_VECTORS[i]
				ret:AddDamage(damage)
				ret:AddScript(self:FireFlyBossFlip(p1 + DIR_VECTORS[i] + DIR_VECTORS[i]))
				ret:AddDelay(0.02)
				damage.loc = p1 + DIR_VECTORS[i] + DIR_VECTORS[(i+1)%4]
				ret:AddDamage(damage)
				ret:AddScript(self:FireFlyBossFlip(p1 + DIR_VECTORS[i] + DIR_VECTORS[(i+1)%4]))
				
			end
			if self.WideArea > 2 then
				ret:AddDelay(0.02)
				damage.loc = p1 + DIR_VECTORS[i]*3
				ret:AddDamage(damage)
				ret:AddScript(self:FireFlyBossFlip(p1 + DIR_VECTORS[i]*3))
				ret:AddDelay(0.02)
				damage.loc = p1 + DIR_VECTORS[i]*2 + DIR_VECTORS[(i+1)%4]
				ret:AddDamage(damage)
				ret:AddScript(self:FireFlyBossFlip(p1 + DIR_VECTORS[i]*2 + DIR_VECTORS[(i+1)%4]))
				ret:AddDelay(0.02)
				damage.loc = p1 + DIR_VECTORS[i] + DIR_VECTORS[(i+1)%4]*2
				ret:AddDamage(damage)
				ret:AddScript(self:FireFlyBossFlip(p1 + DIR_VECTORS[i] + DIR_VECTORS[(i+1)%4]*2))
				
			end
		end
	end
	
	ret:AddBurst(p1, "Emitter_Confuse2", DIR_NONE)
	return ret
	
end	

Support_Confuse_A = Support_Confuse:new{
		WideArea = 2,
		Everywhere = true,
		TipImage = {
			Unit = Point(2,2),
			Target = Point(2,1),
			Enemy1 = Point(2,3),
			Enemy2 = Point(3,2),
			Enemy3 = Point(4,2),
			Enemy4 = Point(2,1),
			Enemy5 = Point(1,1),
			CustomEnemy = "Firefly2",
			Building1 = Point(1,2),
			Building2 = Point(4,1),
			Queued1 = Point(2,2),
			Queued2 = Point(2,2),
			Queued3 = Point(4,1),
			Queued4 = Point(2,2),
			Queued5 = Point(1,2),
		}
}

Support_Confuse_B = Support_Confuse:new{
		Limited = 0,
}

Support_Confuse_AB = Support_Confuse:new{
		Limited = 0,
		WideArea = 2,
		Everywhere = true,
		TipImage = {
			Unit = Point(2,2),
			Target = Point(2,1),
			Enemy1 = Point(2,3),
			Enemy2 = Point(3,2),
			Enemy3 = Point(4,2),
			Enemy4 = Point(2,1),
			Enemy5 = Point(1,1),
			CustomEnemy = "Firefly2",
			Building1 = Point(1,2),
			Building2 = Point(4,1),
			Queued1 = Point(2,2),
			Queued2 = Point(2,2),
			Queued3 = Point(4,1),
			Queued4 = Point(2,2),
			Queued5 = Point(1,2),
		}
}

--------------  Water Drill  ----------------- 

local scriptPath = mod_loader.mods[modApi.currentMod].resourcePath

modApi:appendAsset("img/combat/icons/icon_para_acid_water.png", scriptPath.."img/combat/icons/icon_para_acid_water.png")
Location["combat/icons/icon_para_acid_water.png"] = Point(-12,12)

modApi:appendAsset("img/combat/icons/icon_para_lava.png", scriptPath.."img/combat/icons/icon_para_lava.png")
Location["combat/icons/icon_para_lava.png"] = Point(-12,12)

Support_Waterdrill = Grenade_Base:new{
	Class = "",
	Icon = "advanced/weapons/Support_Waterdrill.png",
	UpShot = "effects/shotup_waterdrill.png",
	LaunchSound = "/weapons/fireball",
	ImpactSound = "/impact/generic/flood_drill_attack",
	Explosion = "",
	PathSize = 1,
	Damage = 0,
	PowerCost = 0,
	ArtillerySize = 8,
	Limited = 1,
	Upgrades = 1,
	UpgradeCost = {1},
	TipImage = {
		Unit = Point(2,3),
		Target = Point(3,1),
		Water = Point(3,1),
		Enemy = Point(2,1),
		Mountain = Point(3,2),
		Length = 7,
		Second_Origin = Point(2,3),
		Second_Target = Point(1,2)
	},
}

function Support_Waterdrill:GetTargetArea(point)
	
	local ret = PointList()
	
	for i = 0, 7 do
		for j = 0, 7 do
			local curr = Point(i,j)
			if Board:GetTerrain(curr) == TERRAIN_WATER or (Board:IsAcid(curr) and (not Board:IsBuilding(curr)) and (Board:GetTerrain(curr) ~= TERRAIN_ICE)) or (Board:IsPawnSpace(curr) and (Board:GetPawn(curr):GetType() == "AcidVat" or Board:GetPawn(curr):GetType() == "Storm_Generator")) then
				ret:push_back(curr)
			end
		end
	end
	
	return ret
end


function Support_Waterdrill:GetSkillEffect(p1,p2)  --This is mostly copied from your AddLaser stuff in weapons_base
	--randomised portion of code for tooltip
	if Board:IsTipImage() and Board:IsPawnSpace(Point(2,1)) then
		local q = math.random(3)
		if q == 1 then Board:ClearSpace(Point(1,2)) Board:SetAcid(Point(1,2),true) end
		if q == 2 then Board:ClearSpace(Point(1,2)) Board:AddPawn("AcidVat",Point(1,2)) end
		if q == 3 then Board:ClearSpace(Point(1,2)) Board:AddPawn("Storm_Generator",Point(1,2)) end
		local z = math.random(3)
		if z == 1 then Board:ClearSpace(Point(3,1)) Board:SetAcid(Point(3,1),true) Board:SetTerrain(Point(3,1),TERRAIN_WATER) end
		if z == 2 then Board:ClearSpace(Point(3,1)) Board:SetTerrain(Point(3,1),TERRAIN_WATER) end
		if z == 3 then Board:ClearSpace(Point(3,1)) Board:SetTerrain(Point(3,1),TERRAIN_LAVA) end
	end
	
	local ret = SkillEffect()
--	local dir = GetDirection(p2 - p1)
	local damage = SpaceDamage(p2)
	damage.iTerrain = TERRAIN_HOLE
	--local effect = SkillEffect()
	--effect:AddDamage(damage)
	--Board:AddEffect(effect)
	damage.sAnimation = "explodrill"
	ret:AddArtillery(damage, self.UpShot, FULL_DELAY)
	damage = SpaceDamage(p2)
	damage.iTerrain = TERRAIN_WATER
	damage.sAnimation = "Splash"
	
	if Board:IsTerrain(p2, TERRAIN_LAVA) then
		damage.iTerrain = TERRAIN_LAVA
	end
	
	if Board:IsAcid(p2) or (Board:IsPawnSpace(p2) and (Board:GetPawn(p2):GetType() == "AcidVat" or Board:GetPawn(p2):GetType() == "Storm_Generator")) then
		damage.iAcid = EFFECT_CREATE
	end
	
	local list = extract_table(general_DiamondTarget(p2, 1))
	
	for i = 1, #list do
		if list[i] ~= p2 then
			damage.loc = list[i]
			local damage_water = SpaceDamage(damage.loc,0)

			if Board:IsTerrain(damage.loc, TERRAIN_MOUNTAIN) then
				local mount = SpaceDamage(damage.loc,DAMAGE_DEATH)
				mount.bHide=true
				ret:AddDamage(mount)
			end

			if Board:IsCrackable(damage.loc) then 
				ret:AddDamage(damage) 
				if Board:IsAcid(p2) or (Board:IsPawnSpace(p2) and (Board:GetPawn(p2):GetType() == "AcidVat" or Board:GetPawn(p2):GetType() == "Storm_Generator")) then
					damage_water.sImageMark = "combat/icons/icon_para_acid_water.png"
				elseif Board:IsTerrain(p2, TERRAIN_LAVA) then
					damage_water.sImageMark = "combat/icons/icon_para_lava.png"
				elseif Board:IsTerrain(p2, TERRAIN_WATER) then
					damage_water.sImageMark = "combat/icons/icon_water.png"
				end	
			else
	--			damage_water.sImageMark = "combat/icons/icon_water_off.png"
			end
			
			ret:AddDamage(damage_water)
			
			local curr = list[i]
			local webber = Board:GetPawn(curr)
			
			if Board:IsPawnSpace(curr) and (webber:GetType() == "DNT_SilkwormBoss" or webber:GetType() == "ScorpionBoss") then
				local identity = webber:GetId()
				local space = webber:GetSpace() --Store the space so we can move it back later
				ret:AddScript("Board:GetPawn("..identity.."):SetSpace(Point(-1,-1))")--Move the pawn to Point(-1,-1)
				ret:AddDelay(0.0017)
				ret:AddScript("Board:GetPawn("..identity.."):SetSpace("..space:GetString()..")") --Move the pawn back, after that one frame. The web will be gone
			end
		end
	end
	
	return ret
end

Support_Waterdrill_A = Support_Waterdrill:new{
	Limited = 2,
}

---------------- Grid Attack  --------------

Support_TC_GridAtk = Skill:new{
	Class = "",
	Icon = "advanced/weapons/Support_TC_GridAtk.png",
	TwoClick = true,
	AllyDamage = true,
	Fire = false,
	Missile = false,
	LaunchSound = "/weapons/grid_defense",
	ImpactSound = "/impact/generic/grid_attack",
	Explosion = "ExploRepulse3",
	Exploart = "explopush1_",
	Damage = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 2, 1 },
	TipImage = {
		Unit = Point(2,3),
		Building = Point(2,1),
		Enemy1 = Point(3,1),
		Target = Point(2,1),
		Second_Click = Point(3,1)
	},
	
}

function Support_TC_GridAtk:GetTargetArea(point)
	local ret = PointList()
	
	local board_size = Board:GetSize()
	for i = 0, 7 do
		for j = 0, 7  do
			local point = Point(i,j)
			if Board:IsBuilding(point) then
				ret:push_back(point)
			end
		end
	end
	
	
	return ret
end


function Support_TC_GridAtk:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	ret:AddDamage(SpaceDamage(p1, 0))  --Don't know why but i need to put SOMETHING here for it to work.
	return ret
end	

function Support_TC_GridAtk:GetSecondTargetArea(p1, p2)
	local ret = PointList()
	
	for i = DIR_START, DIR_END do
		ret:push_back(p2 + DIR_VECTORS[i])
	end
	
	return ret
end

function Support_TC_GridAtk:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()
	local dir = GetDirection(p3 - p2)
	local target = p3
	
	if self.Missile then
		target = GetProjectileEnd(p2,p3,PATH_PROJECTILE)
	end
	
	local damage = SpaceDamage(target,1,dir)
	
	if self.Fire then
		damage.iFire = 1
		damage.sSound = "/props/fire_damage"
	end
	
	ret:AddArtillery(SpaceDamage(p2,0),"effects/shotup_grid.png")
	damage.sAnimation = self.Exploart..dir
	
	if self.Missile then
		ret:AddProjectile(p2,damage,"effects/shot_mechtank")
	else
		ret:AddDamage(damage)
	end
	return ret
end	

Support_TC_GridAtk_A = Support_TC_GridAtk:new{
	Missile = true,
	Exploart = "explopush2_",
	TipImage = {
		Unit = Point(2,3),
		Building = Point(1,1),
		Enemy1 = Point(3,1),
		Target = Point(1,1),
		Second_Click = Point(2,1)
	},
}


Support_TC_GridAtk_B = Support_TC_GridAtk:new{
	Fire = true,
	Exploart = "explopush2_",
}


Support_TC_GridAtk_AB = Support_TC_GridAtk_A:new{
	Fire = true,
}