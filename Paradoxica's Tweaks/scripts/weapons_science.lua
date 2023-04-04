-------------- ScienceMech - Pull  ---------------

Science_Pullmech = 	{
	Class = "Science",
	Icon = "weapons/science_pullmech.png",
	Rarity = 3,
	Sound = "",
	Damage = 0,
	Range = RANGE_PROJECTILE,
	PathSize = INT_MAX,
	Explosion = "",
	Push = 1,--TOOLTIP
	PowerCost = 0,
	LaunchSound = "/weapons/enhanced_tractor",
	ImpactSound = "/impact/generic/tractor_beam",
	Upgrades = 1,
	UpgradeCost = {1},
	UpgradeList = { "Pull Beam" },
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,0),
		Target = Point(2,0)
	},
	ZoneTargeting = ZONE_DIR,
}
		
Science_Pullmech = Skill:new(Science_Pullmech)
			
function Science_Pullmech:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
			
	local target = GetProjectileEnd(p1,p2)  
	
	
	local damage = SpaceDamage(target, self.Damage, GetDirection(p1 - p2))
	if Board:IsPawnTeam(target, TEAM_PLAYER) then
		damage.iShield = self.Shield
	elseif Board:IsPawnTeam(target, TEAM_ENEMY) then
		damage.iAcid = self.Acid
	end
	--ret.path = Board:GetSimplePath(p1, target)
	ret:AddProjectile(damage,"effects/shot_pull", NO_DELAY)
		
	local temp = p1 
	while temp ~= target  do 
		ret:AddDelay(0.05)
		ret:AddBounce(temp,-1)
		temp = temp + DIR_VECTORS[direction]
	end

	return ret
end

Science_Pullmech_A = Science_Pullmech:new{
	LaunchSound = "/weapons/push_beam",
	ImpactSound = nil,
	LaserArt = "effects/laser_push",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,0),
		Friendly = Point(2,1),
		Enemy2 = Point(2,2),
		Target = Point(2,0)
	},
}

function Science_Pullmech_A:GetTargetArea(point)
	local ret = PointList()
	
	for i = DIR_START, DIR_END do
		for k = 1, 8 do
			local curr = DIR_VECTORS[i]*k + point
			if Board:GetTerrain(curr) ~= TERRAIN_MOUNTAIN and not Board:IsBuilding(curr) and Board:IsValid(curr) then
			--if Board:IsValid(curr) and not Board:IsBlocked(curr, Pawn:GetPathProf()) then
				ret:push_back(DIR_VECTORS[i]*k + point)
			else
				break
			end
		end
	end
	
	return ret
end

function Science_Pullmech_A:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p1 - p2)
	
	local targets = {}
	local curr = p1 - DIR_VECTORS[dir]
	while Board:GetTerrain(curr) ~= TERRAIN_MOUNTAIN and not Board:IsBuilding(curr) and Board:IsValid(curr) do
		targets[#targets+1] = curr
		curr = curr - DIR_VECTORS[dir]
	end
	
	local dam = SpaceDamage(curr, 0)
	ret:AddProjectile(dam,self.LaserArt)
	
	for i = 1, #targets do
		local curr = targets[i]
		if Board:IsPawnSpace(curr) then
			ret:AddDelay(0.1)
		end
		
		local damage = SpaceDamage(curr, 0, dir)
		ret:AddDamage(damage)
	end
	
	return ret
end

-------------- ScienceMech - Shield ---------------

Science_Shield = Science_Shield:new{
		UpgradeCost = {1,2},
}

--------------GravMech - Grav Well ----------------

Science_Gravwell = LineArtillery:new{
	Class = "Science",
	Icon = "weapons/science_gravwell.png",
	Sound = "",
	Explosion = "",
	PowerCost = 0,
	Damage = 0,
		ArtilleryStart = 2,
		ArtillerySize = 8,
	LaunchSound = "/weapons/gravwell",
	Upgrades = 1,
	UpgradeCost = {1},
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,0),
		Target = Point(2,0)
	}
}
					
function Science_Gravwell:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	
	ret:AddBounce(p1,-2)
	local damage = SpaceDamage(p2, self.Damage, GetDirection(p1 - p2))
	damage.sAnimation = "airpush_"..GetDirection(p1 - p2)
	ret:AddArtillery(damage,"effects/shot_pull_U.png")
	return ret
end

Science_Gravwell_A = Science_Gravwell:new{
	TwoClick = true,
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,0),
		Target = Point(2,0),
		Second_Click = Point(2,1),
	}
}

function Science_Gravwell_A:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	
	ret:AddBounce(p1,-2)
	local damage = SpaceDamage(p2, self.Damage, GetDirection(p1 - p2))
	damage.sAnimation = "airpush_"..GetDirection(p1 - p2)
	ret:AddArtillery(damage,"effects/shot_pull_U.png")
	return ret
end

function Science_Gravwell_A:GetSecondTargetArea(p1, p2)
	local ret = PointList()
	
	ret:push_back(p1)
	for j = DIR_START, DIR_END do
		for i = 2, 8 do
			local curr = Point(p1 + DIR_VECTORS[j]*i)
			if Board:IsValid(curr) and curr ~= p2 then  
				ret:push_back(curr)
			end
		end
	end
	
	return ret
end
	
function Science_Gravwell_A:GetFinalEffect(p1,p2,p3)
	local ret = self:GetSkillEffect(p1,p2)
	local damage = SpaceDamage(p1, 0)
	damage.fDelay = 2.5
	ret:AddDamage(damage)
	ret:AddSound(self.LaunchSound)

	ret:AddBounce(p1,-2)
	local damage = SpaceDamage(p3, self.Damage)
	if p1==p3 then
		damage = SpaceDamage(p2, self.Damage, GetDirection(p1 - p2))
		damage.sAnimation = "airpush_"..GetDirection(p1 - p2)
	else
		damage = SpaceDamage(p3, self.Damage, GetDirection(p1 - p3))
		damage.sAnimation = "airpush_"..GetDirection(p1 - p3)
	end
	ret:AddArtillery(damage,"effects/shot_pull_U.png")
	return ret
end

---------------- PulseMech - Repulse  --------------

Science_Repulse = Skill:new{  
	PathSize = 1,
	Class = "Science",
	Icon = "weapons/science_repulse.png",
	LaunchSound = "",
	Explosion = "ExploRepulse1",
	Damage = 0,
	PowerCost = 0, --AE Change
	Upgrades = 2,
	ShieldSelf = false,
	ShieldFriendly = false,
	ZoneTargeting = ZONE_ALL,
	UpgradeCost = { 1,2 },
	TipImage = {
		Unit = Point(3,3),
		Enemy1 = Point(2,3),
		Building1 = Point(1,3),
		Building2 = Point(3,2),
		Friendly1 = Point(3,1),
		Target = Point(3,3),
		Second_Origin = Point(3,3),
		Second_Target = Point(3,1),
	}
}

function Science_Repulse:GetTargetArea(point)
	local ret = PointList()
	ret:push_back(point)
	for i = DIR_START, DIR_END do
		for j = 0,7 do
			ret:push_back(point + DIR_VECTORS[i]*j)
		end
	end
	return ret
end

function Science_Repulse:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	if p1:Manhattan(p2) < 2 then
		ret:AddSound("/weapons/science_repulse")
		ret:AddBounce(p1,-2)
		for i = DIR_START,DIR_END do
			local curr = p1 + DIR_VECTORS[i]
			local spaceDamage = SpaceDamage(curr, 0, i)
			
			if self.ShieldFriendly and (Board:IsBuilding(curr) or Board:GetPawnTeam(curr) == TEAM_PLAYER) then
				spaceDamage.iShield = 1
			end
			
			spaceDamage.sAnimation = "airpush_"..i
			ret:AddDamage(spaceDamage)
			
			ret:AddBounce(curr,-1)
		end
	else
		ret:AddSound("/weapons/gravwell")
		ret:AddBounce(p1,2)
		local dist = p1:Manhattan(p2)
		for i = DIR_START,DIR_END do
			local curr = p1 + DIR_VECTORS[i]*dist
			if Board:IsValid(curr) then
				local damage = SpaceDamage(curr, 0, i)
				damage.sAnimation = "airpush_"..i
				ret:AddArtillery(damage,"effects/shot_pull_U.png",0)
			end
		end
		for i = DIR_START,DIR_END do
			if self.ShieldFriendly and (Board:IsBuilding(p1 + DIR_VECTORS[i]) or Board:GetPawnTeam(p1 + DIR_VECTORS[i]) == TEAM_PLAYER) then
				local shieldDamage = SpaceDamage(p1 + DIR_VECTORS[i], 0)
				shieldDamage.iShield = 1
				ret:AddDamage(shieldDamage)
			end
		end
		local selfDamage = SpaceDamage(p1,0)
		if self.ShieldSelf then selfDamage.iShield = 1 end
		selfDamage.sAnimation = self.Explosion
		ret:AddDamage(selfDamage)
		ret:AddDelay(0.8)
		for i = DIR_START,DIR_END do
			local curr = p1 + DIR_VECTORS[i]*dist
			if Board:IsValid(curr) then
				ret:AddBounce(curr,-1)
			end
		end
	end
	if p1:Manhattan(p2) < 2 then
		local selfDamage = SpaceDamage(p1,0)
		
		if self.ShieldSelf then
			selfDamage.iShield = 1
		end
			
		selfDamage.sAnimation = "ExploRepulse1"
		ret:AddDamage(selfDamage)
	end
	return ret
end	

Science_Repulse_A = Science_Repulse:new{
	ShieldSelf = true,
}

Science_Repulse_B = Science_Repulse:new{
	ShieldFriendly = true,
	TipImage = {
		Unit = Point(3,3),
		Enemy1 = Point(2,3),
		Building1 = Point(1,3),
		Building2 = Point(3,2),
		Friendly1 = Point(3,1),
		Target = Point(3,1),
	}
}

Science_Repulse_AB = Science_Repulse_B:new{
	ShieldSelf = true,
}

---------------- TeleMech - Tele-Swapper  --------------

Science_Swap = Skill:new{
	Class = "Science",
	Icon = "weapons/science_swap.png",
	Rarity = 1,
	Explosion = "",
--	LaunchSound = "/weapons/titan_fist",
	Range = 1,
	Damage = 0,
	PowerCost = 0,
	Upgrades = 2,
--	UpgradeList = { "+1 Range",  "+2 Range"  },
	UpgradeCost = { 1 , 2 },
	TipImage = StandardTips.Melee,
	LaunchSound = "/weapons/swap"
	
}

function Science_Swap:GetTargetArea(point)
	local ret = PointList()
	local list = extract_table(general_DiamondTarget(point, self.Range))
	for i = 1, #list do
		if ((Board:IsPawnSpace(list[i]) and not Board:GetPawn(list[i]):IsGuarding())
			or not Board:IsBlocked(list[i], PATH_FLYER)) and (list[i] ~= point) then
			ret:push_back(list[i])
		end
	end
	
	return ret
end

function Science_Swap:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	--local target = GetProjectileEnd(p1,p2)
	local delay = Board:IsPawnSpace(p2) and 0 or FULL_DELAY
	ret:AddTeleport(p1,p2, delay)
	
	if delay ~= FULL_DELAY then
		ret:AddTeleport(p2,p1, FULL_DELAY)
	end
	
	return ret
end	

Science_Swap_A = Science_Swap:new{
	Range = 2,
	TipImage = {
		Unit = Point(1,2),
		Enemy = Point(2,1),
		Target = Point(2,1)
	},
}

Science_Swap_B = Science_Swap:new{
	Range = 3,
	TipImage = {
		Unit = Point(1,2),
		Enemy = Point(3,1),
		Target = Point(3,1)
	},
}

Science_Swap_AB = Science_Swap:new{
	Range = 4,
	TipImage = {
		Unit = Point(1,3),
		Enemy = Point(3,1),
		Target = Point(3,1)
	},
}

----------- Local Shield ------------------------

Science_LocalShield = Skill:new{  
	PathSize = 1,
	Class = "Science",
	Icon = "weapons/science_localshield.png",
	Explosion = "",
	Damage = 0,
	PowerCost = 1, --AE Change
	IceVersion = 0,
	WideArea = 2,
	ZoneTargeting = ZONE_ALL,
	Upgrades = 2,
	Ignore_Vek = false,
	Push = 1,--TOOLTIP HELPER,
	Range = 1,--TOOLTIP HELPER
	Limited = 1,
	UpgradeCost = { 1,1 },
	UpgradeList = { "Ignore Enemy",  "+1 Use"  },
	LaunchSound = "/weapons/localized_burst",
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Friendly1 = Point(2,3),
		Friendly2 = Point(3,2),
		Friendly3 = Point(4,2),
		Building1 = Point(2,1),
		Building2 = Point(1,1),
		Enemy = Point(1,2)
	}
}
		
function Science_LocalShield:GetTargetArea(point)
	local ret = PointList()
	local list = extract_table(general_DiamondTarget(point, self.WideArea))
	for i = 1, #list do
		ret:push_back(list[i])
	end
	return ret
end

function Science_LocalShield:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	local list = extract_table(general_DiamondTarget(p1, self.WideArea))
	local damage = SpaceDamage(p1,0)
	damage.iShield = 1
	
	if self.IceVersion == 1 then
		damage.iShield = 0
		damage.iFrozen = EFFECT_CREATE
		local storm_spot = p1 + Point(-1*self.WideArea,-1*self.WideArea)
		local storm_size = Point(3,3) + Point(self.WideArea,self.WideArea)
		ret:AddScript("Board:SetWeather(5,"..RAIN_SNOW..","..storm_spot:GetString()..","..storm_size:GetString()..",2)")
	end
	
	for i = 1, #list do
		damage.loc = list[i]
		if self.Ignore_Vek and Board:IsPawnSpace(list[i]) and Board:IsPawnTeam(list[i], TEAM_ENEMY) then
		else
			ret:AddDamage(damage)
		end
	end
	
	return ret
end	

Science_LocalShield_A = Science_LocalShield:new{
		Ignore_Vek = true,
}

Science_LocalShield_B = Science_LocalShield:new{
		Limited = 2,
}

Science_LocalShield_AB = Science_LocalShield:new{
		Ignore_Vek = true,
		Limited = 2,
}

----------------NanoMech - Acid Shot --------------

local scriptPath = mod_loader.mods[modApi.currentMod].resourcePath

modApi:appendAsset("img/effects/upshot_nano.png", scriptPath.."img/effects/upshot_nano.png")

Science_AcidShot = LineArtillery:new {
	Class = "Science",
	Icon = "weapons/mission_tankacid.png",
	Rarity = 1,
	Explosion = "",
	UpShot = "effects/upshot_nano.png",
	Damage = 0,
	Push = 1,
	Acid = 1,
	TwoClick = true,
	PowerCost = 0,
	Upgrades = 0,
	UpgradeCost = {1,2},
	LaunchSound = "/weapons/acid_shot",
	ImpactSound = "/impact/generic/acid_canister",
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Building1 = Point(2,2),
		Enemy1 = Point(2,1),
		Second_Click = Point(3,1),
	},
	ZoneTargeting = ZONE_DIR,
}

function Science_AcidShot:FireFlyBossFlip(point)
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

function Science_AcidShot:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local damage = SpaceDamage(p2, self.Damage)
	damage.iAcid = self.Acid
	damage.sAnimation = "ExploAcid1"
	ret:AddArtillery(damage, self.UpShot)
	return ret
end

function Science_AcidShot:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	ret:push_back(p1)
	for i = 0,3 do
		local curr = p2 + DIR_VECTORS[i]
		if Board:IsValid(curr) then ret:push_back(curr) end
	end
	return ret
end

function Science_AcidShot:GetFinalEffect(p1,p2,p3)
	local ret = SkillEffect()
	local dir = (p3 == p1 and DIR_FLIP) or GetDirection(p3 - p2)
	local damage = SpaceDamage(p2, self.Damage)
	if p3 == p1 then damage = SpaceDamage(p2, self.Damage, dir) end
	damage.iAcid = self.Acid
	damage.sAnimation = "ExploAcid1"
	ret:AddArtillery(damage, self.UpShot)
	if p3 ~= p1 then
		damage = SpaceDamage(p2, self.Damage, dir)
		damage.sAnimation = "airpush_"..dir
		damage.fDelay = -1
		ret:AddDamage(damage)
	else
		ret:AddScript(self:FireFlyBossFlip(p2))
	end
	return ret
end

----------------- ConfuseRay --------------

local scriptRath = mod_loader.mods[modApi.currentMod].resourcePath

modApi:appendAsset("img/effects/upshot_confuse.png", scriptRath.."img/effects/upshot_confuse.png")

Science_Confuse = LineArtillery:new{ 
	Class = "Science",
	Icon = "weapons/science_confuse.png",
	UpShot = "effects/upshot_confuse.png",
	LaunchSound = "/weapons/science_enrage_launch",
	ImpactSound = "/impact/generic/enrage",
	TwoClick = true,
	TwoClickError = "Science_TC_Enrage_Error",
	Damage = 0,
	PowerCost = 2,
	Explosion = "",
	Upgrades = 0,
	CustomTipImage = "Science_Confuse_Tip",
}

function Science_Confuse:IsConfuseable(point)
	--Four Way Attackers "target" themselves
	if Board:IsPawnSpace(point) and Board:IsPawnTeam(point, TEAM_ENEMY) and Board:GetPawn(point):IsQueued() and (Board:GetPawn(point):GetQueuedTarget() == point or Board:GetPawn(point):GetType() == "lmn_Puffer2" or Board:GetPawn(point):GetType() == "DNT_AntlionBoss") then
		return false
	--Other Attackers do not
	elseif Board:IsPawnSpace(point) and Board:IsPawnTeam(point, TEAM_ENEMY) and Board:GetPawn(point):IsQueued() then
		if Board:IsValid(Board:GetPawn(point):GetQueuedTarget()) then
			return true
		end
	end
	
	return false	
end

function Science_Confuse:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local target = p2
	local damage = SpaceDamage(target,0)
	if self:IsConfuseable(target) then
		damage.sImageMark = "combat/icons/icon_mind_glow.png"
	else
		damage.sImageMark = "combat/icons/icon_mind_off_glow.png"
	end
	ret:AddArtillery(damage,self.UpShot)
	return ret
end

function Science_Confuse:GetSecondTargetArea(p1, p2)
	local ret = PointList()
	local target = p2
	
	if not self:IsConfuseable(target) then
		return ret
	end
	
	local threat = Board:GetPawn(target):GetQueuedTarget()
	
	if target:Manhattan(threat)==1 then
		for i = DIR_START,DIR_END do
			local curr = target + DIR_VECTORS[i]
			if Board:IsValid(curr) and curr ~= threat then
				ret:push_back(curr)
			end
		end
		return ret
	else
		for i = DIR_START,DIR_END do
			for j = 2,7 do
				local curr = target + DIR_VECTORS[i]*j
				if Board:IsValid(curr) and curr ~= threat then
					ret:push_back(curr)
				end
			end
		end
		return ret
	end
	return ret
end

function Science_Confuse:GetFinalEffect(p1,p2,p3)
	local ret = SkillEffect()
	local target = p2
	local direction = GetDirection(p3 - target)
	local dummy_damage = SpaceDamage(target,0)
	dummy_damage.sImageMark = "combat/icons/icon_mind_glow.png"
	dummy_damage.sAnimation = "ExploRepulseSmall"
	ret:AddArtillery(dummy_damage,self.UpShot)
	ret:AddDelay(0.2)
	
	ret:AddScript("Board:GetPawn("..target:GetString().."):SetQueuedTarget("..p3:GetString()..")")
	
	ret:AddScript("Board:AddAlert("..target:GetString()..",\"ATTACK CHANGED\")")
	
	local web_id = Board:GetPawn(p2):GetId()--Store pawn id
	ret:AddScript("Board:GetPawn("..web_id.."):SetSpace(Point(-1,-1))")--Move the pawn to Point(-1,-1) to delete webbing
	local damage = SpaceDamage(p1,0)
	damage.bHide = true
	damage.fDelay = 0.00017--force a one frame delay on the board
	ret:AddDamage(damage)
	ret:AddScript("Board:GetPawn("..web_id.."):SetSpace("..p2:GetString()..")")--Move the pawn back
	return ret
end

Science_Confuse_Tip = Skill:new{
	Class = "Science",
	TipImage = {
		Unit = Point(3,2),
		Enemy1 = Point(1,2),
		Enemy2 = Point(1,1),
		Queued1 = Point(2,2),
		Target = Point(1,2),
		CustomEnemy = "Firefly2",
		Length = 4
	}
}

function Science_Confuse_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	ret.piOrigin = Point(3,2)
	local damage = SpaceDamage(0)
	damage.bHide = true
	damage.fDelay = 0.017
	ret:AddDamage(damage)
	local damage = SpaceDamage(p2,0)
	damage.bHide = true
	damage.sAnimation = "ExploRepulseSmall"--"airpush_"..GetDirection(p2 - p1)
	ret:AddArtillery(damage,"effects/upshot_confuse.png")
	ret:AddScript("Board:GetPawn("..Point(1,2):GetString().."):SetQueuedTarget("..Point(1,1):GetString()..")")
	ret:AddScript("Board:AddAlert("..Point(1,2):GetString()..",\"ATTACK CHANGED\")")
	return ret
end

---------------- Emergency Smoke  -------------------

Science_SmokeDefense = Skill:new{ 
	Class = "Science",
	Icon = "weapons/science_smokedefense.png",
	Rarity = 1,
	Selfsmoke = true,
	ZoneTargeting = ZONE_ALL,
	Range = 1,
	PowerCost = 1,
	Upgrades = 2,
	UpgradeCost = {2,2},
	Limited = 1,
--	UpgradeList = { "Ally Immune", "+1 Use" },
	LaunchSound = "/weapons/defensive_smoke",
	Smoke = 1,--TOOLTIP HELPER,
	TipImage = StandardTips.Surrounded
}

function Science_SmokeDefense:GetTargetArea(point)
	local ret = PointList()
	
	local list = extract_table(general_DiamondTarget(point, self.Range))
	for i = 1, #list do
			ret:push_back(list[i])
	end
	
	return ret
end

function Science_SmokeDefense:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	
	ret:AddDamage(SoundEffect(p2,self.LaunchSound))
	
	local list = extract_table(general_DiamondTarget(p1, self.Range))
	
	for i = 1, #list do
		local damage = SpaceDamage(list[i], 0)
		damage.iSmoke = 1
		ret:AddDamage(damage)
	end
	
	return ret
end

Science_SmokeDefense_A = Science_SmokeDefense:new{
			Range = 2,
			TipImage= {
				Unit = Point(2,2),
				Target = Point(2,1),
				Enemy = Point(2,3),
				Enemy2 = Point(3,2),
				Enemy3 = Point(1,1),
				Friendly = Point(2,1)
			}
}
Science_SmokeDefense_B = Science_SmokeDefense:new{
			Limited = 2,
}

Science_SmokeDefense_AB = Science_SmokeDefense:new{
			Range = 2,
			Limited = 2,
			TipImage= {
				Unit = Point(2,2),
				Target = Point(2,1),
				Enemy = Point(2,3),
				Enemy2 = Point(3,2),
				Enemy3 = Point(1,1),
				Friendly = Point(2,1)
			}
}

-------------- Fire Beam ---------------------------

Science_FireBeam = LaserDefault:new{
	Class = "Science",
	Icon = "weapons/science_firebeam.png",
	LaserArt = "effects/laser_fire", --laser_fire
	LaunchSound = "/weapons/fire_beam",
	Explosion = "",
	Sound = "",
	Damage = 0,
	MinDamage = 0,
	PowerCost = 0, --AE Change
	Fire = 1,
	Flip = false,
	FriendlyDamage = true,
	Limited = 1,
	Upgrades = 2,
	--UpgradeList = { "+1 Use" },
	UpgradeCost = { 1,2 },
	ZoneTargeting = ZONE_DIR,
	--DamageTooltip = TipData("Damage","3 to 1"),
	TipImage = {
		Unit = Point(2,4),
		Enemy1 = Point(2,2),
		Friendly = Point(1,2),
		Queued1 = Point(1,2),
		Target = Point(2,2),
		Mountain = Point(2,0)
	}
}

function Science_FireBeam:FireFlyBossFlip(point)
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

function Science_FireBeam:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local curr = p1 + DIR_VECTORS[dir]
	local targets = {curr}
	
	while Board:GetTerrain(curr) ~= TERRAIN_MOUNTAIN and not Board:IsBuilding(curr) and Board:IsValid(curr) do
		curr = curr + DIR_VECTORS[dir]
		targets[#targets+1] = curr
	end
	
	if Board:IsValid(curr) then
		local dam = SpaceDamage(curr, 0)
		ret:AddProjectile(dam,self.LaserArt)
	else
		local dam = SpaceDamage(curr - DIR_VECTORS[dir], 0)
		ret:AddProjectile(dam,self.LaserArt)
	end
	
	for i = 1, #targets do
		local curr = targets[i]
		local damage = SpaceDamage(curr, 0)
		damage.iFire = 1
		if self.Flip then damage.iPush = DIR_FLIP end
		ret:AddDamage(damage)
		if self.Flip then ret:AddScript(self:FireFlyBossFlip(curr)) end
	end
	return ret
end

Science_FireBeam_A = Science_FireBeam:new{	
		Limited = 0,
	}

Science_FireBeam_B = Science_FireBeam:new{	
		Flip = true,
	}

Science_FireBeam_AB = Science_FireBeam:new{	
		Limited = 0,
		Flip = true,
	}

-------------- Push Beam ---------------------------

Science_PushBeam = Science_PushBeam:new{
	Class = "Science",
	Icon = "weapons/science_pushbeam.png",
	LaserArt = "effects/laser_push", --laser_fire
	LaunchSound = "",
	Explosion = "",
	Sound = "",
	Omni = false,
	Damage = 0,
	MinDamage = 0,
	PowerCost = 0, --AE Change
	Limited = 2,
	ZoneTargeting = ZONE_DIR,
	Upgrades = 2,
	UpgradeCost = { 1,2 },
	LaunchSound = "/weapons/push_beam",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Friendly = Point(2,1),
		Target = Point(2,2),
		Mountain = Point(2,0)
	}
}

function Science_PushBeam:GetTargetArea(point)
	local ret = PointList()
	
	for i = DIR_START, DIR_END do
		for k = 1, 8 do
			local curr = DIR_VECTORS[i]*k + point
			if Board:GetTerrain(curr) ~= TERRAIN_MOUNTAIN and not Board:IsBuilding(curr) and Board:IsValid(curr) then
			--if Board:IsValid(curr) and not Board:IsBlocked(curr, Pawn:GetPathProf()) then
				ret:push_back(DIR_VECTORS[i]*k + point)
			else
				break
			end
		end
	end
	
	if self.Omni then ret:push_back(point) end
	
	return ret
end

function Science_PushBeam:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	
	if p1 ~= p2 then
		local targets = {}
		local curr = p1 + DIR_VECTORS[dir]
		while Board:GetTerrain(curr) ~= TERRAIN_MOUNTAIN and not Board:IsBuilding(curr) and Board:IsValid(curr) do
			targets[#targets+1] = curr
			curr = curr + DIR_VECTORS[dir]
		end
		
		if Board:IsValid(curr) then
			local dam = SpaceDamage(curr, 0)
			ret:AddProjectile(dam,self.LaserArt)
		else
			local dam = SpaceDamage(curr - DIR_VECTORS[dir], 0)
			ret:AddProjectile(dam,self.LaserArt)
		end
		
		for i = 1, #targets do
			local curr = targets[#targets - i + 1]
			if Board:IsPawnSpace(curr) then
				ret:AddDelay(0.1)
			end
			
			local damage = SpaceDamage(curr, 0, dir)
			ret:AddDamage(damage)
		end
	else
		local length_list = {}
		for m = 0,3 do
			local targets = {}
			local curr = p1 + DIR_VECTORS[m]
			while Board:GetTerrain(curr) ~= TERRAIN_MOUNTAIN and not Board:IsBuilding(curr) and Board:IsValid(curr) do
				targets[#targets+1] = curr
				curr = curr + DIR_VECTORS[m]
			end
			if Board:IsValid(curr) then
				length_list[m+1] = p1:Manhattan(curr)
				dam = SpaceDamage(curr, 0)
				ret:AddProjectile(dam,self.LaserArt)
			else
				length_list[m+1] = p1:Manhattan(curr)-1
				dam = SpaceDamage(curr - DIR_VECTORS[m], 0)
				if curr - DIR_VECTORS[m] ~= p1 then
					ret:AddProjectile(dam,self.LaserArt)
				end
			end
			
		end
		local temp = {}
		temp[1] = length_list[1]
		temp[2] = length_list[2]
		temp[3] = length_list[3]
		temp[4] = length_list[4]
		table.sort(temp)
		local start = temp[#temp]
		for i = start, 1, -1 do
			local pawn_flag = false
			for k = 0,3 do
				if i < length_list[k+1]+1 then
					local corr = p1 + DIR_VECTORS[k]*i
					pawn_flag = (Board:IsValid(corr) and Board:IsPawnSpace(corr)) or pawn_flag
				end
			end
			if pawn_flag then ret:AddDelay(0.1) end
			for k = 0,3 do
				local corr = p1 + DIR_VECTORS[k]*i
				if i < length_list[k+1]+1 then--and Board:GetTerrain(corr) ~= TERRAIN_MOUNTAIN and not Board:IsBuilding(corr) then
					local damage = SpaceDamage(corr, 0, k)
					ret:AddDamage(damage)
				end
			end
		end
	end
	
	return ret
end

Science_PushBeam_A = Science_PushBeam:new{
		Limited = 0,
}

Science_PushBeam_B = Science_PushBeam:new{
		Omni = true,
		TipImage = {
			Unit = Point(2,2),
			Enemy = Point(1,2),
			Enemy2 = Point(3,2),
			Friendly = Point(2,1),
			Friendly2 = Point(2,3),
			Target = Point(2,2),
			Mountain = Point(2,0),
			Mountain2 = Point(0,2),
		}
}

Science_PushBeam_AB = Science_PushBeam_B:new{
		Limited = 0,
}

------------------- Enrage ------------------------------------

Science_TC_Enrage = LineArtillery:new{ 
	Class = "Science",
	Icon = "advanced/weapons/Science_TC_Enrage.png",
	LaunchSound = "/weapons/science_enrage_launch",
	ImpactSound = "/impact/generic/enrage",
	AttackSound = "/weapons/science_enrage_attack",
	TwoClickError = "Science_TC_Enrage_Error",
	TwoClick = true,
	Cancel = false,
	Damage = 1,
	PowerCost = 0,
	Explosion = "",
	Upgrades = 2,
	UpgradeCost = { 2,1 },
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy1 = Point(2,1),
		Enemy2 = Point(3,1),
		Second_Click = Point(3,1),
	},
}

function Science_TC_Enrage:IsEnrageable(curr)
		
	if not Board:IsPawnSpace(curr) then
		return false
	end
	
	if Board:GetPawn(curr):IsFrozen() then
		return false
	end
	
	if not Board:GetPawn(curr):IsPowered() then
		return false
	end

	if Board:GetPawn(curr):GetBaseMove() > 0 then
		return true
	end
	
	local pawn_type = Board:GetPawn(curr):GetType() 
	local OK_Types = {"Totem1", "Totem2", "VIP_Truck", "Snowmine1", "TotemB"} --things with move 0 that can still enrage
	
	for i,v in ipairs(OK_Types) do
		if pawn_type == v then
			return true
		end
	end
	
	return false	
end

function Science_TC_Enrage:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local damage = SpaceDamage(p2,0)
	if self:IsEnrageable(p2) then
		damage.sImageMark = "combat/icons/icon_mind_glow.png"
	else
		damage.sImageMark = "combat/icons/icon_mind_off_glow.png"
	end
	ret:AddDamage(damage)
	return ret
end

function Science_TC_Enrage:GetSecondTargetArea(p1, p2)
	local ret = PointList()
	
	if not self:IsEnrageable(p2) then
		return ret
	end
	
	for dir = DIR_START, DIR_END do
		ret:push_back(p2 + DIR_VECTORS[dir])
	end
	return ret
end

function Science_TC_Enrage:GetFinalEffect(p1,p2,p3)
	local direction = GetDirection(p3 - p2)
	local ret = SkillEffect()
	
	ret:AddArtillery(SpaceDamage(p2,0), "advanced/effects/shotup_swapother.png", FULL_DELAY)
	
	local dummy_damage = SpaceDamage(p2,0)
	dummy_damage.sAnimation = "ExploRepulseSmall"
	ret:AddDamage(dummy_damage)
	ret:AddDelay(0.2)
	
	local final_damage = self.Damage
	
	if IsPassiveSkill("Passive_FriendlyFire") and Board:IsPawnSpace(p2) and Board:GetPawn(p2):GetTeam() == TEAM_ENEMY then
		final_damage = final_damage + 1	
		if IsPassiveSkill("Passive_FriendlyFire_AB") then
			final_damage = final_damage + 2
		elseif IsPassiveSkill("Passive_FriendlyFire_A") or IsPassiveSkill("Passive_FriendlyFire_B") then
			final_damage = final_damage + 1
		end
	end
	
	if Board:GetPawn(p2):GetType() == "MosquitoBoss" then final_damage = DAMAGE_DEATH end
	
	local damage = SpaceDamage(p3, final_damage, direction)
	damage.sAnimation = "explopunch1_"..direction
	damage.sSound = self.AttackSound
	ret:AddMelee(p2, damage)
	
	if self.Cancel then
		ret:AddScript("Board:GetPawn("..p2:GetString().."):ClearQueued()")
		if Board:GetPawn(p2):IsQueued() and Board:IsPawnTeam(p2, TEAM_ENEMY) then
			ret:AddScript("Board:AddAlert("..p2:GetString()..",\"ATTACK CANCELED\")")
		end
		local web_id = Board:GetPawn(p2):GetId()--Store pawn id
		ret:AddScript("Board:GetPawn("..web_id.."):SetSpace(Point(-1,-1))")--Move the pawn to Point(-1,-1) to delete webbing
		local damage = SpaceDamage(p1,0)
		damage.bHide = true
		damage.fDelay = 0.00017--force a one frame delay on the board
		ret:AddDamage(damage)
		ret:AddScript("Board:GetPawn("..web_id.."):SetSpace("..p2:GetString()..")")--Move the pawn back
		return ret
	end
	return ret
end

Science_TC_Enrage_A = Science_TC_Enrage:new{
	Cancel = true,
	CustomTipImage = "Science_TC_Enrage_Tip",
}
Science_TC_Enrage_B = Science_TC_Enrage:new{
	Damage = 2,
}
Science_TC_Enrage_AB = Science_TC_Enrage_A:new{
	Damage = 2,
	CustomTipImage = "Science_TC_Enrage_TipTwo",
}

Science_TC_Enrage_Tip = Skill:new{
	Class = "Science",
	TipImage = {
		Unit = Point(3,2),
		Friendly = Point(0,2),
		Enemy1 = Point(1,2),
		Enemy2 = Point(1,1),
		Queued1 = Point(0,2),
		Target = Point(1,2),
		Length = 4
	}
}

function Science_TC_Enrage_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	ret.piOrigin = Point(3,2)
	local damage = SpaceDamage(0)
	damage.bHide = true
	damage.fDelay = 0.017
	ret:AddDamage(damage)
	ret:AddArtillery(SpaceDamage(p2,0), "advanced/effects/shotup_swapother.png")
	damage = SpaceDamage(p2,0)
	damage.sAnimation = "ExploRepulseSmall"
	ret:AddDamage(damage)
	ret:AddDelay(0.2)
	local final_damage = 1
	
	if IsPassiveSkill("Passive_FriendlyFire") and Board:IsPawnSpace(p2) and Board:GetPawn(p2):GetTeam() == TEAM_ENEMY then
		final_damage = final_damage + 1	
		if IsPassiveSkill("Passive_FriendlyFire_AB") then
			final_damage = final_damage + 2
		elseif IsPassiveSkill("Passive_FriendlyFire_A") or IsPassiveSkill("Passive_FriendlyFire_B") then
			final_damage = final_damage + 1
		end
	end
	ret:AddMelee(p2, SpaceDamage(Point(1,1), final_damage, 0))
	ret:AddScript("Board:GetPawn("..p2:GetString().."):ClearQueued()")
	ret:AddScript("Board:AddAlert("..p2:GetString()..",\"ATTACK CANCELED\")")
	return ret
end

Science_TC_Enrage_TipTwo = Skill:new{
	Class = "Science",
	TipImage = {
		Unit = Point(3,2),
		Friendly = Point(0,2),
		Enemy1 = Point(1,2),
		Enemy2 = Point(1,1),
		Queued1 = Point(0,2),
		Target = Point(1,2),
		Length = 4
	}
}

function Science_TC_Enrage_TipTwo:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	ret.piOrigin = Point(3,2)
	local damage = SpaceDamage(0)
	damage.bHide = true
	damage.fDelay = 0.017
	ret:AddDamage(damage)
	ret:AddArtillery(SpaceDamage(p2,0), "advanced/effects/shotup_swapother.png")
	damage = SpaceDamage(p2,0)
	damage.sAnimation = "ExploRepulseSmall"
	ret:AddDamage(damage)
	ret:AddDelay(0.2)
	local final_damage = 2
	
	if IsPassiveSkill("Passive_FriendlyFire") and Board:IsPawnSpace(p2) and Board:GetPawn(p2):GetTeam() == TEAM_ENEMY then
		final_damage = final_damage + 1	
		if IsPassiveSkill("Passive_FriendlyFire_AB") then
			final_damage = final_damage + 2
		elseif IsPassiveSkill("Passive_FriendlyFire_A") or IsPassiveSkill("Passive_FriendlyFire_B") then
			final_damage = final_damage + 1
		end
	end
	ret:AddMelee(p2, SpaceDamage(Point(1,1), final_damage, 0))
	ret:AddScript("Board:GetPawn("..p2:GetString().."):ClearQueued()")
	ret:AddScript("Board:AddAlert("..p2:GetString()..",\"ATTACK CANCELED\")")
	return ret
end

----------------- Control -------------------------

Science_TC_Control = Science_TC_Control:new{
	UpgradeCost = {2,2},
}

-------------- Mass Shift   -----------------

Science_MassShift = Skill:new{
	Class = "Science",
	Icon = "advanced/weapons/Science_MassShift.png",
	LaunchSound = "/weapons/mass_shift",
	Damage = 0,
	PathSize = 1,
	PowerCost = 0,
	ShieldSelf = false,
	ShieldFriendly = false,
	Limited = 0,
	Upgrades = 2,
	UpgradeCost = { 1, 2 },
	TipImage = StandardTips.Surrounded,
}

	
function Science_MassShift:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	
	local damage = SpaceDamage (p1 + DIR_VECTORS[dir], 0, dir)
	damage.sAnimation = "airpush_"..dir
	if self.ShieldFriendly and (Board:IsBuilding(damage.loc) or Board:GetPawnTeam(damage.loc) == TEAM_PLAYER) then
			damage.iShield = 1 end
	ret:AddDamage(damage)
	ret:AddDelay(0.2)
	damage.iShield = 0
	
	damage.loc = p1
	if self.ShieldSelf then damage.iShield = 1 end
	ret:AddDamage(damage)
	damage.iShield = 0
	
	damage.loc = p1 + DIR_VECTORS[(dir+1)%4]
	if self.ShieldFriendly and (Board:IsBuilding(damage.loc) or Board:GetPawnTeam(damage.loc) == TEAM_PLAYER) then
			damage.iShield = 1 end
	ret:AddDamage(damage)
	damage.iShield = 0
	
	damage.loc = p1 - DIR_VECTORS[(dir+1)%4]
	if self.ShieldFriendly and (Board:IsBuilding(damage.loc) or Board:GetPawnTeam(damage.loc) == TEAM_PLAYER) then
			damage.iShield = 1 end
	ret:AddDamage(damage)
	damage.iShield = 0
	
	ret:AddDelay(0.2)
	
	damage.loc = p1 - DIR_VECTORS[dir]
	if self.ShieldFriendly and (Board:IsBuilding(damage.loc) or Board:GetPawnTeam(damage.loc) == TEAM_PLAYER) then
			damage.iShield = 1 end
	ret:AddDamage(damage)
	ret:AddDelay(0.2)
	damage.iShield = 0
	
	return ret
	
end

Science_MassShift_A = Science_MassShift:new{
	ShieldSelf = true,
}

Science_MassShift_B = Science_MassShift:new{
	ShieldFriendly = true,
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(2,3),
		Friendly = Point(3,2),
		Enemy2 = Point(2,1),
		Building = Point(1,2),
	}
}

Science_MassShift_AB = Science_MassShift:new{
	ShieldSelf = true,
	ShieldFriendly = true,
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,1),
		Enemy = Point(2,3),
		Friendly = Point(3,2),
		Enemy2 = Point(2,1),
		Building = Point(1,2),
	}
}

----------------   Explosive Warp  --------------

Science_TelePush = Skill:new{
	Class = "Science",
	Icon = "advanced/weapons/Science_TelePush.png",
	Explosion = "",
	Range = 7,
	Burn = false,
	Crack = false,
	Kill = false,
	Damage = 0,
	SelfDamage = 0,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {3,1},
	LaunchSound = "/weapons/force_swap",
	TipImage = {
		Unit = Point(2,4),
		Target = Point(2,1),
		Enemy1 = Point(2,2),
		Enemy2 = Point(3,1),
		Enemy3 = Point(1,1),
	},
}

function Science_TelePush:IsSpaceTaken(point)
	if (not Board:IsPawnSpace(point)) and (not Board:IsBuilding(point)) and (Board:GetTerrain(point) ~= TERRAIN_MOUNTAIN) then
		return false
	elseif Board:IsPawnSpace(point) and Board:IsPawnTeam(point, TEAM_PLAYER) then
		return true
	else
		return true
	end
end

function Science_TelePush:GetTargetArea(point)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
		for range = 1, self.Range do
			local curr = point + DIR_VECTORS[dir]*range
			if (not Board:IsPawnSpace(curr) and not Board:IsBlocked(curr, PATH_FLYER)) then
				ret:push_back(curr)
			elseif Board:IsPawnSpace(curr) and (not Board:IsPawnTeam(curr, TEAM_PLAYER)) and self.Kill and (not Board:IsBuilding(curr)) then
				ret:push_back(curr)
			elseif self.Kill and Board:GetTerrain(curr) == TERRAIN_MOUNTAIN then
				ret:push_back(curr)
			end
		end
	end
	
	return ret
end

function Science_TelePush:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
		
	local damage = SpaceDamage(p2, 0)
	local damage2 = SpaceDamage(Point(-1,-1), 0)
	
	if self.Kill and self:IsSpaceTaken(p2) then
		damage = SpaceDamage(p2, DAMAGE_DEATH)
		damage2 = SpaceDamage(p1, self.SelfDamage)
	end
	
	damage.sAnimation = "ExploRepulse2"
	
	ret:AddDamage(damage)
	
	ret:AddDamage(damage2)
	
	ret:AddTeleport(p1,p2, 0)
	
	ret:AddDelay(0.6)
	
	for i = DIR_START, DIR_END do
		damage = SpaceDamage(p2 + DIR_VECTORS[i], 0, i)
		damage.sAnimation = "airpush_"..i
		ret:AddDamage(damage)
	end
	
	local wait = SpaceDamage(0)
	wait.fDelay = -1
	ret:AddDamage(wait)

	return ret
end

Science_TelePush_A = Science_TelePush:new{
	Kill = true,
	Damage = DAMAGE_DEATH,
	SelfDamage = 1,
	TipImage = {
		Unit = Point(2,4),
		Target = Point(2,1),
		Enemy1 = Point(2,2),
		Enemy2 = Point(3,1),
		Enemy3 = Point(1,1),
		Enemy4 = Point(2,1),
	},
}

Science_TelePush_B = Science_TelePush:new{
	SelfDamage = 0,
	CustomTipImage = "Science_TelePush_AB",
	TipImage = {
		Unit = Point(2,4),
		Target = Point(2,1),
		Enemy1 = Point(2,2),
		Enemy2 = Point(3,1),
		Enemy3 = Point(1,1),
		Enemy4 = Point(2,1),
	},
}

Science_TelePush_AB = Science_TelePush_A:new{
	SelfDamage = 0,
}

-------------------Shield Placer  ---------

Science_Placer = Skill:new{  
	Class = "Science",
	Icon = "advanced/weapons/Science_Placer.png",
	LaunchSound = "",
	Explosion = "",
	Range = 7,
	PathSize = 1,
	Damage = 0,
	Anywhere = false,
	TwoClick = false,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 2,2 },
	TipImage = {
		Unit = Point(2,3),
		Building = Point(2,0),
		Enemy1 = Point(1,0),
		Enemy2 = Point(1,3),
		Friendly = Point(2,1),
		Enemy3 = Point(3,0),
		Enemy4 = Point(3,3),
		Target = Point(2,0),
		Second_Origin = Point(2,3),
		Second_Target = Point(2,3),
	}
}
				
function Science_Placer:GetTargetArea(point)
	local ret = PointList()
	if self.Anywhere then
		for i, p in ipairs(Board) do
			ret:push_back(p)
		end
	else
		for dir = DIR_START, DIR_END do
			for range = 1, self.Range do
				local curr = point + DIR_VECTORS[dir]*range
				ret:push_back(curr)
			end
		end
		ret:push_back(point)
	end
	return ret
end

function Science_Placer:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	local dir = GetDirection(p2 - p1)

	ret:AddSound("/weapons/enhanced_tractor")
	local damage = SpaceDamage(p2, self.Damage)
	damage.iShield = EFFECT_CREATE
	damage.sAnimation = "ExploRepulse1"
	if p1 == p2 then ret:AddDamage(damage) 
	else
		
		ret:AddArtillery(damage, "effects/shot_pull_U.png", NO_DELAY)
		ret:AddDelay(1)
	end
	
	for i = DIR_START, DIR_END do
		damage = SpaceDamage(p2 + DIR_VECTORS[i], 0, i)
		damage.sAnimation = "airpush_"..i
		ret:AddDamage(damage)
	end
	
	return ret
end

Science_Placer_B = Science_Placer:new{
	TwoClick = true,
	TipImage = {
		Unit = Point(2,3),
		Enemy1 = Point(2,2),
		Friendly = Point(3,2),
		Enemy2 = Point(1,2),
		Enemy3 = Point(2,1),
		Enemy4 = Point(0,2),
		Enemy5 = Point(2,0),
		Target = Point(2,2),
		Second_Click = Point(6,5),
	}
}

function Science_Placer_B:GetTargetArea(point)
	local ret = PointList()
	if self.Anywhere then
		for i, p in ipairs(Board) do
			ret:push_back(p)
		end
	else
		for dir = DIR_START, DIR_END do
			for range = 1, self.Range do
				local curr = point + DIR_VECTORS[dir]*range
				ret:push_back(curr)
			end
		end
		ret:push_back(point)
	end
	return ret
end

function Science_Placer_B:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	local dir = GetDirection(p2 - p1)

	local damage = SpaceDamage(p2, self.Damage)
	damage.iShield = EFFECT_CREATE
	damage.sAnimation = "ExploRepulse1"
	if p1 == p2 then ret:AddDamage(damage) 
	else
		ret:AddArtillery(damage, "effects/shot_pull_U.png", NO_DELAY)
		ret:AddDelay(1)
	end
	
	for i = DIR_START, DIR_END do
		damage = SpaceDamage(p2 + DIR_VECTORS[i], 0, i)
		damage.sAnimation = "airpush_"..i
		ret:AddDamage(damage)
	end
	
	return ret
end

function Science_Placer_B:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	local store = PointList()
	
	for k = 2,5 do
		store:push_back(Point(1,k))
		store:push_back(Point(2,k))
		store:push_back(Point(5,k))
		store:push_back(Point(6,k))
	end
	
	local list = extract_table(store)
	
	for i = 1, #list do
		if p2 ~= list[i] then
		ret:push_back(list[i])
		end
	end
	
	return ret
end

function Science_Placer_B:GetFinalEffect(p1, p2, p3)	
	local ret = SkillEffect()
	
	local damage = SpaceDamage(p2,0)

	if p3.x == 5 or p3.x == 6 then
		ret:AddSound("/weapons/ice_throw")
		damage.iFrozen = EFFECT_CREATE
		if p1 == p2 then ret:AddDamage(damage) 
		else
			ret:AddArtillery(damage,"effects/shotup_ice.png",FULL_DELAY)
		end
		ret:AddBounce(p2, 2)
		ret:AddSound("/impact/generic/ice")
		for i = DIR_START, DIR_END do
			local damage2 = SpaceDamage(p2 + DIR_VECTORS[i], 0, i)
			damage2.sAnimation = "airpush_"..i
			ret:AddDamage(damage2)
		end
		ret:AddDelay(1.5)
		damage = SpaceDamage(p2,0)
	end
	damage.iShield = EFFECT_CREATE
	damage.sAnimation = "ExploRepulse1"
	
	if p3.x == 5 or p3.x == 6 then
		local shoved = Point(-1,-1)
		if p1:Manhattan(p2) == 1 then
			shoved = p2 - DIR_VECTORS[GetDirection(p2 - p1)]*2
		end
		damage.fDelay = -1
		ret:AddSound("/weapons/enhanced_tractor")
		if p1:Manhattan(p2) == 1 and Board:IsValid(shoved) and not Board:IsTerrain(shoved,TERRAIN_MOUNTAIN) and not Board:IsBuilding(shoved) and not Board:IsPawnSpace(shoved) then
			ret:AddArtillery(p1 - DIR_VECTORS[GetDirection(p2-p1)], damage, "effects/shot_pull_U.png", FULL_DELAY)
		else
			ret:AddArtillery(damage, "effects/shot_pull_U.png", FULL_DELAY)
		end
	else
		ret:AddSound("/weapons/enhanced_tractor")
		if p1 == p2 then ret:AddDelay(FULL_DELAY) ret:AddDamage(damage) 
		else
			ret:AddArtillery(damage, "effects/shot_pull_U.png", FULL_DELAY)
		end
	end
	
	for i = DIR_START, DIR_END do
		damage = SpaceDamage(p2 + DIR_VECTORS[i], 0, i)
		damage.sAnimation = "airpush_"..i
		ret:AddDamage(damage)
	end
	return ret
end

Science_Placer_A = Science_Placer:new{
	Anywhere = true,
	TipImage = {
		Unit = Point(3,3),
		Building = Point(2,0),
		Enemy1 = Point(1,0),
		Enemy2 = Point(2,1),
		Friendly = Point(0,2),
		Enemy3 = Point(0,1),
		Enemy4 = Point(1,2),
		Target = Point(2,0),
		Second_Origin = Point(3,3),
		Second_Target = Point(0,2),
	}
}

Science_Placer_AB = Science_Placer_B:new{
	Anywhere = true,
	TipImage = {
		Unit = Point(3,3),
		Enemy1 = Point(2,2),
		Friendly1 = Point(3,2),
		Friendly2 = Point(2,3),
		Enemy2 = Point(1,2),
		Enemy3 = Point(2,1),
		Enemy4 = Point(0,2),
		Enemy5 = Point(2,0),
		Target = Point(2,2),
		Second_Click = Point(6,5),
	}
}

-------------- Science KO -----------------

Science_KO_Crack = Skill:new{
	Class = "Science",
	Icon = "advanced/weapons/Science_KO_Crack.png",
	ImpactSound = "/weapons/ko_crack",
	MinMove = 1,
	Damage = 1,
	PathSize = 1,
	Charging = false,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {1,3},
	LaunchSound = "/weapons/crack",
	BombSound = "/impact/generic/explosion",
	OnKill = "Science_KO_Crack_OnKill",
	Explosion = "",
	TipImage = 	{
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
		CustomEnemy = "Leaper1",
	}
}

function Science_KO_Crack:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)

	local doDamage = true
	local target = GetProjectileEnd(p1,p2,PATH_PROJECTILE)
	local damage = SpaceDamage(target, self.Damage, DIR_FLIP)
	damage.sAnimation = "explodrill"
	--damage.sSound = self.LaunchSound

    if self.Charging then
        if not Board:IsBlocked(target,PATH_PROJECTILE) then -- dont attack an empty edge square, just run to the edge
	    	doDamage = false
		    target = target + DIR_VECTORS[direction]
    	end
    	
    	ret:AddCharge(Board:GetSimplePath(p1, target - DIR_VECTORS[direction]), FULL_DELAY)
	else
		target = p2
	end

	if doDamage then
		damage.loc = target
		if Board:IsDeadly(damage,Pawn) then
			damage.bKO_Effect = true
		end
		ret:AddMelee(p2 - DIR_VECTORS[direction], damage, NO_DELAY)
		ret:AddBounce(target,8)
	end
	
	local Mirror = false
	
	if Board:IsPawnSpace(p2) and (Board:GetPawn(p2):GetType() == "FireflyBoss" or Board:GetPawn(p2):GetType() == "DNT_JunebugBoss") and Board:GetPawn(p2):IsQueued()then
		Mirror = true
	end
	
	if Mirror then
		local threat = Board:GetPawn(p2):GetQueuedTarget()
		local flip = (GetDirection(threat - p2)+1)%4
		local newthreat = p2 + DIR_VECTORS[flip]
		if not Board:IsValid(newthreat) then
			newthreat = p2 - DIR_VECTORS[flip]
		end
		ret:AddScript("Board:GetPawn("..p2:GetString().."):SetQueuedTarget("..newthreat:GetString()..")")
	end

	if Board:IsDeadly(damage, Pawn) then
		for i = DIR_START, DIR_END do
			local damageside = SpaceDamage(target+DIR_VECTORS[i], 0)
			damageside.iCrack = EFFECT_CREATE   
			ret:AddDamage(damageside)
			ret:AddBurst(target+DIR_VECTORS[i],"Emitter_Crack_Start",DIR_NONE)
			ret:AddBounce(target+DIR_VECTORS[i],-1)
		end
		damage.iCrack = EFFECT_CREATE   
		ret:AddBurst(target,"Emitter_Crack_Start",DIR_NONE)
		ret:AddSound("/weapons/crack_ko")
		ret:AddBounce(target,-2)
	end

	return ret
end

Science_KO_Crack_A = Science_KO_Crack:new{
	Damage = 2,
	TipImage = 	{
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
		CustomEnemy = "Digger1",
	}
}

Science_KO_Crack_B = Science_KO_Crack:new{
	Damage = 2,
	TipImage = 	{
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
		CustomEnemy = "Digger1",
	}
	--[[PathSize = 8,
	Charging = true,
	TipImage = 	{
		Unit = Point(2,4),
		Enemy = Point(2,1),
		Target = Point(2,1),
		CustomEnemy = "Leaper1",
	}]]
}

Science_KO_Crack_AB = Science_KO_Crack:new{
	Damage = 3,
	TipImage = 	{
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
		CustomEnemy = "Scorpion1",
	}
}