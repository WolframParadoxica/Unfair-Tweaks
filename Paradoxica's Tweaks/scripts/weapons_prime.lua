----------- MechElectric - Chain Whip -----------------

Prime_Lightning = Prime_Lightning:new{
	PowerCost = 0,
}

----------- Rock Throw -----------------

Prime_Rockmech = Prime_Rockmech:new{
	Class = "Prime",
	Range = RANGE_PROJECTILE,
	Icon = "weapons/prime_rockmech.png",
	Rarity = 3,
	Explosion = "",
	PathSize = INT_MAX,
	Damage = 2,
	Surround = false,
	PowerCost = 0, --AE Change
	Limited = 1,
	Push = 0,
	Upgrades = 2,
	UpgradeCost = { 1,1 },
	--UpgradeList = { "+1 Damage", "+1 Damage" },
	Tags = {"Rock Weapon"},
	LaunchSound = "/weapons/boulder_throw",
	ImpactSound = "/impact/dynamic/rock",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,1),
		Mountain = Point(1,1),
		Building = Point(3,1),
	}
}

function Prime_Rockmech:IsSpaceFree(point)
	if (not Board:IsPawnSpace(point)) and (not Board:IsBuilding(point)) and (Board:GetTerrain(point) ~= TERRAIN_MOUNTAIN) then
		return true
	else
		return false
	end
end

function Prime_Rockmech:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
			
	local target = p1 + DIR_VECTORS[dir]
	local spawnRock = Point(-1,-1)
	local spawnRock2 = Point(-1,-1)
	local spawnRock3 = Point(-1,-1)
	local spawnRock4 = Point(-1,-1)
	local doDamage = false
	
	for i = 1, 8 do
		--target.x == p2. and target.y == p2.y
		if Board:IsBlocked(target,PATH_PROJECTILE) then
			doDamage = true
			local hitdamage = SpaceDamage(target, self.Damage)
			if self.Push == 1 then
				hitdamage = SpaceDamage(target, self.Damage, dir)
			end
		
			if target - DIR_VECTORS[dir] ~= p1 then
			    spawnRock = target - DIR_VECTORS[dir]
				hitdamage.sAnimation = "ExploAir1"
			else
				hitdamage.sAnimation = "rock1d" 
			end
			
			ret:AddProjectile(hitdamage,"effects/shot_mechrock")
			break
		end
		
		if target == p2 then
			spawnRock = target
			ret:AddProjectile(SpaceDamage(spawnRock),"effects/shot_mechrock")
			break
		end
		
		if not Board:IsValid(target) then
			spawnRock = target - DIR_VECTORS[dir]
			ret:AddProjectile(SpaceDamage(spawnRock),"effects/shot_mechrock")
			break
		end
		
		target = target + DIR_VECTORS[dir]
	end
	
	if Board:IsValid(spawnRock) then
		local damage = SpaceDamage(spawnRock)
		damage.sPawn = "RockThrown"
		ret:AddDamage(damage)
		target = spawnRock
	end
	if self.Surround and doDamage and GetProjectileEnd(p1,p2) - DIR_VECTORS[dir] == p1 then
		spawnRock2 = target+DIR_VECTORS[dir]
		spawnRock3 = target+DIR_VECTORS[(dir+1)%4]
		spawnRock4 = target-DIR_VECTORS[(dir+1)%4]
		if self:IsSpaceFree(spawnRock2) then
			local damage2 = SpaceDamage(spawnRock2)
			damage2.sPawn = "RockThrown"
			ret:AddDamage(damage2)
		end
		if self:IsSpaceFree(spawnRock3) then
			local damage3 = SpaceDamage(spawnRock3)
			damage3.sPawn = "RockThrown"
			ret:AddDamage(damage3)
		end
		if self:IsSpaceFree(spawnRock4) then
			local damage4 = SpaceDamage(spawnRock4)
			damage4.sPawn = "RockThrown"
			ret:AddDamage(damage4)
		end
	elseif self.Surround and doDamage then
		spawnRock2 = target+DIR_VECTORS[dir]*2
		spawnRock3 = target+DIR_VECTORS[dir]+DIR_VECTORS[(dir+1)%4]
		spawnRock4 = target+DIR_VECTORS[dir]-DIR_VECTORS[(dir+1)%4]
		if self:IsSpaceFree(spawnRock2) then
			local damage2 = SpaceDamage(spawnRock2)
			damage2.sPawn = "RockThrown"
			ret:AddDamage(damage2)
		end
		if self:IsSpaceFree(spawnRock3) then
			local damage3 = SpaceDamage(spawnRock3)
			damage3.sPawn = "RockThrown"
			ret:AddDamage(damage3)
		end
		if self:IsSpaceFree(spawnRock4) then
			local damage4 = SpaceDamage(spawnRock4)
			damage4.sPawn = "RockThrown"
			ret:AddDamage(damage4)
		end
	end
	
	return ret
end

Prime_Rockmech_A = Prime_Rockmech:new{
	Surround = true,
}

Prime_Rockmech_B = Prime_Rockmech:new{
	Limited = 2,
}
		
Prime_Rockmech_AB = Prime_Rockmech:new{
	Surround = true,
	Limited = 2,
}	

--------------  Right Hook -------------------

Prime_RightHook = Prime_RightHook:new{  
	Class = "Prime",
	Icon = "weapons/prime_righthook.png",
	Rarity = 3,
	TwoClick = true,
	Explosion = "ExploAir2",
	LaunchSound = "/weapons/titan_fist",
	Range = 1, -- Tooltip?
	PathSize = 1,
	Damage = 2,
	Push = 1, --Mostly for tooltip, but you could turn it off for some unknown reason
	PowerCost = 0, --AE Change
	Upgrades = 2,
	UpgradeCost = { 1, 3 },
	TipImage = {
		Unit = Point(1,2),
		Enemy = Point(1,1),
		Target = Point(1,1),
		Second_Click = Point(2,1),
	}
}

function Prime_RightHook:IsSpaceFree(point)
	if (not Board:IsPawnSpace(point)) and (not Board:IsBuilding(point)) and (Board:GetTerrain(point) ~= TERRAIN_MOUNTAIN) then
		return true
	else
		return false
	end
end

function Prime_RightHook:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		ret:push_back(point + DIR_VECTORS[i])
	end
	return ret
end

function Prime_RightHook:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	local damage = SpaceDamage(p2,self.Damage)
	ret:AddDamage(damage)

	return ret
end	

function Prime_RightHook:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	local dir = GetDirection(p2-p1)
	ret:push_back(DIR_VECTORS[(dir+1)%4] + p2)
	ret:push_back(DIR_VECTORS[(dir+3)%4] + p2)
	return ret
end

function Prime_RightHook:GetFinalEffect(p1,p2,p3)
	local ret = SkillEffect()
	local dir = GetDirection(p3-p2)
	
	local damage = SpaceDamage(p2,self.Damage, dir)
	damage.sAnimation = "explopunch1_"..dir
	ret:AddMelee(p1,damage)
	
	return ret
end

Prime_RightHook_A = Prime_RightHook:new{
	TipImage = {
		Unit = Point(1,2),
		Enemy = Point(1,1),
		Target = Point(1,1),
		Second_Click = Point(4,1),
	}
}

function Prime_RightHook_A:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	local dir = GetDirection(p2-p1)
	--get the squares that obstruct the grapple line of sight, and go one past the edge of the board if the edge of the board is a free space
	stop1 = GetProjectileEnd(p2,p2+DIR_VECTORS[(dir+1)%4])
	if self:IsSpaceFree(stop1) and Board:IsEdge(stop1) then
		stop1 = stop1+DIR_VECTORS[(dir+1)%4]
	end
	stop2 = GetProjectileEnd(p2,p2+DIR_VECTORS[(dir+3)%4])
	if self:IsSpaceFree(stop2) and Board:IsEdge(stop2) then
		stop2 = stop2+DIR_VECTORS[(dir+3)%4]
	end
	
	local target = p2 + DIR_VECTORS[(dir+1)%4]
	if Board:IsValid(target) then
		ret:push_back(target)
	end
	local curr = target

	while curr ~= stop1 and Board:IsValid(curr) do
		if curr ~= p2 + DIR_VECTORS[(dir+1)%4] then
			ret:push_back(curr)
		end
		curr = curr + DIR_VECTORS[(dir+1)%4]
	end
	
	target = p2 + DIR_VECTORS[(dir+3)%4]
	if Board:IsValid(target) then
		ret:push_back(target)
	end
	curr = target

	while curr ~= stop2 and Board:IsValid(curr) do
		if curr ~= p2 + DIR_VECTORS[(dir+3)%4] then
			ret:push_back(curr)
		end
		curr = curr + DIR_VECTORS[(dir+3)%4]
	end
	
	return ret
end

function Prime_RightHook_A:GetFinalEffect(p1,p2,p3)
	ret = SkillEffect()
	local dir = GetDirection(p3-p2)
	local damage = SpaceDamage(p2,self.Damage,dir)
	
	if p2:Manhattan(p3) > 1 then--remove push if targetting more than one square away
		damage = SpaceDamage(p2,self.Damage)
	end
	
	damage.sAnimation = "explopunch1_"..dir
	if p2:Manhattan(p3) > 1 then--launching requires shorter delay to be seamless
		ret:AddMelee(p1,damage,0.2)
	else
		ret:AddMelee(p1,damage,FULL_DELAY)
	end
	
	if p2:Manhattan(p3) > 1 then
		ret:AddSound("/weapons/grapple")--"/weapons/charge"
		ret:AddCharge(Board:GetSimplePath(p2, p3),FULL_DELAY)
	end
	return ret
end

Prime_RightHook_B = Prime_RightHook:new{	
	Damage = 4,
}

Prime_RightHook_AB = Prime_RightHook_A:new{
	Damage = 4,
}

------------LaserMech - Burst Beam -----------------

Prime_Lasermech = LaserDefault:new{
	Class = "Prime",
	Icon = "weapons/prime_lasermech.png",
	Rarity = 3,
	Explosion = "",
	Sound = "",
	Damage = 3,
	PowerCost = 0, --AE Change
	MinDamage = 1,
	FriendlyDamage = true,
	ZoneTargeting = ZONE_DIR,
	Upgrades = 2,
	UpgradeList = { "Ally Immune", "+2 Damage" },
	UpgradeCost = { 1,3 },
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Friendly = Point(2,1),
		Target = Point(2,2),
		Mountain = Point(2,0)
	}
}

Prime_Lasermech_A = Prime_Lasermech:new{
	Damage = 4,
}
Prime_Lasermech_B = Prime_Lasermech:new{
	Damage = 4,
	FriendlyDamage = false,
}
Prime_Lasermech_AB = Prime_Lasermech:new{
	Damage = 5,
	FriendlyDamage = false,
}

----- JudoMech - Vice Fist -----

Prime_Shift = Prime_Shift:new{
	Class = "Prime",
	Icon = "weapons/prime_shift.png",
	Damage = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {1,2},
	Range = 2,
	LaunchSound = "/weapons/shift",
	TipImage = {
	Unit = Point(2,1),
	Target = Point(2,3),
  Enemy = Point(2,0),
}
}

function Prime_Shift:GetTargetArea(p1)
local ret = PointList()
  for dir = DIR_START, DIR_END do
    local curr = p1 - DIR_VECTORS[dir]
    if Board:IsPawnSpace(curr) and not Board:GetPawn(curr):IsGuarding() then
    for i = 1, self.Range do
      local curr = p1 + DIR_VECTORS[dir]*i
      if not Board:IsBlocked(curr, PATH_FLYER) then
      ret:push_back(curr)
      end
    end
    end
  end
return ret
end

function Prime_Shift:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
  local target = p1+DIR_VECTORS[(direction+2)%4]
	
	for i = 1, self.Range do
		local curr = p1 + DIR_VECTORS[direction]*i
		if Board:IsValid(curr) and Board:IsBlocked(curr, PATH_FLYER) then
			local block_image = SpaceDamage(curr,0)
			block_image.sImageMark = "advanced/combat/icons/icon_throwblocked_glow.png"
			ret:AddDamage(block_image)
		end
	end
	
  ret:AddMelee(p1,SpaceDamage(target,0))
  local move = PointList()
  move:push_back(p1-DIR_VECTORS[direction])
  move:push_back(p2)
  ret:AddLeap(move, FULL_DELAY)
  ret:AddDamage(SpaceDamage(p2,self.Damage))
  ret:AddBounce(p2,3)

	return ret
end


Prime_Shift_A = Prime_Shift:new{
	Damage = 1,
  Range = 4,
	TipImage = {
	Unit = Point(2,1),
	Target = Point(2,5),
  Enemy = Point(2,0),
}
}

Prime_Shift_B = Prime_Shift:new{
	Damage = 2,
}

Prime_Shift_AB = Prime_Shift_A:new{
	Damage = 2,
}

---------------- Prime Flamethrower ------------------------

Prime_Flamethrower = Prime_Flamethrower:new{  
	Class = "Prime",
	Icon = "weapons/prime_flamethrower.png",
	Rarity = 3,
	Explosion = "",
--	LaunchSound = "/weapons/titan_fist",
	Range = 1, -- Tooltip?
	PathSize = 1,
	Flip = false,
	Damage = 2,
	FireDamage = 2,
	Push = 1, --Mostly for tooltip, but you could turn it off for some unknown reason
	PowerCost = 0, --AE Change
	Upgrades = 2,
	UpgradeList = { "+1 Range",  "+1 Range"  },
	UpgradeCost = { 1 , 3 },
	TipImage = StandardTips.Melee,
	LaunchSound = "/weapons/flamethrower"
}

function Prime_Flamethrower:FireFlyBossFlip(point)
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

function Prime_Flamethrower:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		for k = 1, self.PathSize do
			local curr = DIR_VECTORS[i]*k + point
			ret:push_back(curr)
			if not Board:IsValid(curr) then  -- AE change or Board:GetTerrain(curr) == TERRAIN_MOUNTAIN 
				break
			end
		end
	end
	
	return ret
end
				
function Prime_Flamethrower:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)
	local dor = DIR_NONE
	if self.Flip then dor = DIR_FLIP end
	for i = 1, distance do
		local curr = p1 + DIR_VECTORS[direction]*i
		local exploding = Board:IsPawnSpace(curr) and Board:GetPawn(curr):IsFire()
		local push = (i == distance) and direction*self.Push or dor
		local damage = SpaceDamage(curr,0, push)
		if exploding then
			damage.iDamage = damage.iDamage + self.FireDamage
			damage.sAnimation = "ExploAir1"
		end
		damage.iFire = EFFECT_CREATE
		if i == distance then damage.sAnimation = "flamethrower"..distance.."_"..direction end
		if (i ~= distance) and self.Flip then ret:AddScript(self:FireFlyBossFlip(curr)) end
		ret:AddDamage(damage)
	end
	return ret
end	

Prime_Flamethrower_A = Prime_Flamethrower:new{
	PathSize = 2, 
	Range = 2,
	TipImage = StandardTips.Ranged,
}

Prime_Flamethrower_B = Prime_Flamethrower:new{
	PathSize = 2, 
	Range = 2,
	Flip = true,
	TipImage = {
		Unit = Point(2,3),
		Enemy1 = Point(2,1),
		Enemy2 = Point(2,2),
		Friendly = Point(1,2),
		Queued2 = Point(1,2),
		Target = Point(2,1),
	}
}

Prime_Flamethrower_AB = Prime_Flamethrower:new{
	PathSize = 3, 
	Range = 3,
	Flip = true,
	TipImage = {
		Unit = Point(2,4),
		Enemy1 = Point(2,1),
		Enemy2 = Point(2,2),
		Friendly = Point(1,2),
		Queued2 = Point(1,2),
		Target = Point(2,1),
	}
}

-------------- Prime - Spinfist ---------------------------

Prime_SpinFist = Prime_SpinFist:new{  
	Class = "Prime",
	Icon = "weapons/prime_spinfist.png",
	Rarity = 3,
	Explosion = "ExploAir1",
	LaunchSound = "/weapons/titan_fist",
	Range = 1, -- Tooltip?
	PathSize = 1,
	Damage = 2,
	Push = 1,
	TwoClick = true,
	Halt = false,
	PowerCost = 1, --AE Change
	Upgrades = 2,
	ZoneTargeting = ZONE_ALL,
--	UpgradeList = { "+1 Damage Each",  "+1 Damage"  },
	UpgradeCost = { 1 , 3 },
	TipImage = {
		Unit = Point(2,2),
		Enemy1 = Point(2,1),
		Target = Point(2,1),
		Enemy2 = Point(1,2),
		Friendly = Point(1,3),
		Building = Point(1,1),
		Second_Click = Point(1,1),
	}
}

function Prime_SpinFist:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		ret:push_back(point + DIR_VECTORS[i])
	end
	return ret
end

function Prime_SpinFist:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local damage = SpaceDamage(p1,0)
	
	for i = DIR_START,DIR_END do
	damage = SpaceDamage(p1 + DIR_VECTORS[i],self.Damage)
	ret:AddDamage(damage)
	end
	
	return ret
end	

function Prime_SpinFist:GetSecondTargetArea(p1,p2)
-- Force you to target left or right for your click#1
	local ret = PointList()
	local dir = GetDirection(p2 - p1)
	ret:push_back(p2+DIR_VECTORS[(dir+1)%4])
	ret:push_back(p2+DIR_VECTORS[(dir+3)%4])
	return ret
end

function Prime_SpinFist:GetCollateral(q1)
	if Board:IsBuilding(q1) then
		return true
	elseif (Board:IsPawnSpace(q1) and Board:IsPawnTeam(q1, TEAM_MECH)) then--mechs can tank damage whereas most allied units cannot
		return false
	elseif (Board:IsPawnSpace(q1) and Board:IsPawnTeam(q1, TEAM_PLAYER)) then
		return true
	else
		return false
	end
end

function Prime_SpinFist:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()
	local aim = GetDirection(p2 - p1)
	local turn = GetDirection(p3 - p2)
	local clockwise = ((aim - turn)%4==3)
	local damage = SpaceDamage(p1, 0)
	local collat = Point(-1,-1)
	if clockwise then
		for i = DIR_START,DIR_END do
			collat = p1 + DIR_VECTORS[i]+DIR_VECTORS[(i+1)%4]
			if self.Halt and self:GetCollateral(collat) then
				damage = SpaceDamage(p1 + DIR_VECTORS[i],self.Damage)
				damage.sAnimation = self.Explosion
			else
				damage = SpaceDamage(p1 + DIR_VECTORS[i],self.Damage, (i+1)%4)
				damage.sAnimation = "explopunch1_"..((i+1)%4)
			end
			ret:AddDamage(damage)
		end
	else
		for i = DIR_START,DIR_END do
			collat = p1 + DIR_VECTORS[i]+DIR_VECTORS[(i-1)%4]
			if self.Halt and self:GetCollateral(collat) then
				damage = SpaceDamage(p1 + DIR_VECTORS[i],self.Damage)
				damage.sAnimation = self.Explosion
			else
				damage = SpaceDamage(p1 + DIR_VECTORS[i],self.Damage, (i-1)%4)
				damage.sAnimation = "explopunch1_"..((i-1)%4)
			end
			ret:AddDamage(damage)
		end
	end
	
	return ret
end

Prime_SpinFist_A = Prime_SpinFist:new{
		Halt = true,
}

Prime_SpinFist_B = Prime_SpinFist:new{	
		Damage = 3,
		Explosion = "ExploAir2",
}

Prime_SpinFist_AB = Prime_SpinFist:new{
		Halt = true,
		Damage = 3,
		Explosion = "ExploAir2",
}

------------ GuardMech - Shield Bash -----------------

Prime_ShieldBash = Prime_Punchmech:new{  
	Flip = true,
	Shield = true,
	TwoClick = false,
	Icon = "weapons/prime_shieldbash.png",
	Upgrades = 2,
	LaunchSound = "/weapons/shield_bash",
	Damage = 2,
	UpgradeCost = { 1 , 3 },
	TipImage = {
        Unit = Point(3,1),
		Friendly = Point(2,2),
        Enemy1 = Point(2,1),
        Queued1 = Point(2,2),
        Target = Point(2,1),
        CustomEnemy = "Firefly2",
    },
}

function Prime_ShieldBash:FireFlyBossFlip(point)
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

function Prime_ShieldBash:GetTargetArea(p1)
local ret = PointList()
	for dir = DIR_START, DIR_END do
		local curr = p1 + DIR_VECTORS[dir]
		if Board:IsValid(curr) then
			ret:push_back(curr)
		end
		curr = curr + DIR_VECTORS[(dir+1)%4]
		if Board:IsValid(curr) and self.Diagonal then
			ret:push_back(curr)
		end
	end
return ret
end

function Prime_ShieldBash:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	
	local shield = SpaceDamage(p1,0)
	shield.iShield = 1
	ret:AddDamage(shield)
	
	local damage = SpaceDamage(p2,self.Damage,DIR_FLIP)
	ret:AddMelee(p1,damage)
	
	ret:AddScript(self:FireFlyBossFlip(p2))
	return ret
end

Prime_ShieldBash_A = Prime_ShieldBash:new{
	Diagonal = true,
	TipImage = {
        Unit = Point(3,2),
		Friendly = Point(2,2),
        Enemy1 = Point(2,1),
        Queued1 = Point(2,2),
        Target = Point(2,1),
        CustomEnemy = "Firefly2",
    },
}

Prime_ShieldBash_B = Prime_ShieldBash:new{
	Damage = 3,
	TwoClick = true,
	TipImage = {
        Unit = Point(3,1),
		Friendly = Point(2,2),
        Enemy1 = Point(2,1),
        Queued1 = Point(2,2),
        Enemy2 = Point(3,2),
        Queued2 = Point(2,2),
        Target = Point(2,1),
		Second_Click = Point(3,2),
        CustomEnemy = "Firefly2",
    },
}

function Prime_ShieldBash_B:GetSecondTargetArea(p1,p2)
local ret = PointList()
	for dir = DIR_START, DIR_END do
		local curr = p1 + DIR_VECTORS[dir]
		if Board:IsValid(curr) and curr ~= p2 then
			ret:push_back(curr)
		end
		curr = curr + DIR_VECTORS[(dir+1)%4]
		if Board:IsValid(curr) and self.Diagonal and curr ~= p2 then
			ret:push_back(curr)
		end
	end
return ret
end

function Prime_ShieldBash_B:GetFinalEffect(p1,p2,p3)
	local ret = self:GetSkillEffect(p1,p2)
	
	local damage = SpaceDamage(p3,self.Damage,DIR_FLIP)
	damage.fDelay = -1
	ret:AddMelee(p1,damage)
	
	ret:AddScript(self:FireFlyBossFlip(p3))
	return ret
end

Prime_ShieldBash_AB = Prime_ShieldBash_B:new{
	Diagonal = true,
	Damage = 3,
	TwoClick = true,
	TipImage = {
        Unit = Point(3,2),
		Friendly = Point(2,2),
        Enemy1 = Point(2,1),
        Queued1 = Point(2,2),
        Enemy2 = Point(3,3),
        Queued2 = Point(3,2),
        Target = Point(2,1),
		Second_Click = Point(3,3),
        CustomEnemy = "Firefly2",
    },
}

---------------- Prime Spear ------------------------

Prime_Spear = Prime_Spear:new{  
	Class = "Prime",
	Icon = "weapons/prime_spear.png",
	Explosion = "",
	Range = 2, 
	PathSize = 2,
	Damage = 2,
	Push = 1,
	Acid = 0,
	PowerCost = 1, --AE Change
	Upgrades = 2,
	UpgradeCost = { 1 , 2 },
	LaunchSound = "/weapons/sword",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Target = Point(2,1)
	}
}

function Prime_Spear:FireFlyBossFlip(point)
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

function Prime_Spear:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		for k = 1, self.PathSize do
			local curr = DIR_VECTORS[i]*k + point
			ret:push_back(curr)
			if not Board:IsValid(curr) then --or Board:GetTerrain(curr) == TERRAIN_MOUNTAIN then
				break
			end
		end
	end
	
	return ret
end
				
function Prime_Spear:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)

	for i = 1, distance do
		local push = (i == distance) and direction*self.Push or DIR_FLIP--DIR_NONE
		local damage = SpaceDamage(p1 + DIR_VECTORS[direction]*i,self.Damage, push)
		if i == distance then damage.iAcid = self.Acid end
		if i == 1 then damage.sAnimation = "explospear"..distance.."_"..direction end
		if i ~= distance then ret:AddScript(self:FireFlyBossFlip(p1 + DIR_VECTORS[direction]*i)) end
		ret:AddDamage(damage)
	end

	return ret
end	

Prime_Spear_A = Prime_Spear:new{
	Acid = 1,
}

Prime_Spear_B = Prime_Spear:new{
	PathSize = 3, 
	Range = 3,
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Target = Point(2,1)
	}
}

Prime_Spear_AB = Prime_Spear:new{
	Acid = 1,
	PathSize = 3, 
	Range = 3,
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Target = Point(2,1)
	}
}

--[[------------------- Punt -------------------

Prime_TC_Punt_B = Prime_TC_Punt:new{
	Damage = 2,
}

Prime_TC_Punt_AB = Prime_TC_Punt:new{
	Range = 4,
	Damage = 2,
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,3),
		Target = Point(2,3),
		Second_Click = Point(2,0),
	}
}]]

-------------- Prime_Flamespreader -----------------

Prime_Flamespreader = Prime_Flamespreader:new{
	Flip = false,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy = Point(2,1),
		Enemy2 = Point(2,2),
		Friendly = Point(3,2),
		Queued2 = Point(3,2),
	},
}

function Prime_Flamespreader:FireFlyBossFlip(point)
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

function Prime_Flamespreader:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		for k = 1, self.PathSize do
			local curr = DIR_VECTORS[i]*k + point
			ret:push_back(curr)
			if not Board:IsValid(curr) then --  or Board:GetTerrain(curr) == TERRAIN_MOUNTAIN 
				break
			end
		end
	end
	
	return ret
end
				
function Prime_Flamespreader:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)
	
	
	for i = 1, distance do
		local curr = p1 + DIR_VECTORS[direction]*i
		local dor = DIR_NONE
		if self.Flip then dor = DIR_FLIP end
		local damage = SpaceDamage(curr,self.Damage,dor)
		
		damage.iFire = self.Fire
		
		if i == distance then 	
			damage.sAnimation = "flamethrower"..distance.."_"..direction 
		end
		
		ret:AddDamage(damage)
		if self.Flip then ret:AddScript(self:FireFlyBossFlip(curr)) end
		
		--Push left and right of area affected
		local damagepush = SpaceDamage(curr + DIR_VECTORS[(direction+1)%4],0,(direction+1)%4)
		damagepush.sAnimation = "airpush_"..((direction+1)%4)
		ret:AddDamage(damagepush)
		damagepush = SpaceDamage(curr + DIR_VECTORS[(direction-1)%4],0,(direction-1)%4)
		damagepush.sAnimation = "airpush_"..((direction-1)%4)
		ret:AddDamage(damagepush)
		
		ret:AddBounce(p1 + DIR_VECTORS[direction]*i,2)
	end

	return ret
end	

Prime_Flamespreader_A = Prime_Flamespreader:new{
	PathSize = 4,
	TipImage = {
		Unit = Point(2,4),
		Target = Point(2,0),
		Enemy = Point(1,0),
		Enemy2 = Point(3,1),
		Enemy3 = Point(2,2),
		Friendly = Point(3,2),
		Queued3 = Point(3,2),
	},
}
Prime_Flamespreader_B = Prime_Flamespreader:new{
	Fire = 1,
	Flip = true,
}
Prime_Flamespreader_AB = Prime_Flamespreader_A:new{
	Fire = 1,
	Flip = true,
}

--------------  Way Too Big Rocket   -----------------

Prime_WayTooBig = Prime_WayTooBig:new {
	Range = RANGE_PROJECTILE,
	Class = "Prime",
	Icon = "advanced/weapons/Prime_WayTooBig.png",
	Explosion = "ExploAir2",
	Damage = 3,
	BuildingImmune = false,
	Flip = false,
	MinDamage = 1,
	MaxDamage = 3,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 2, 1 },
	--Limited = 1,
	SelfDamage = 2,
	Sound = "/general/combat/explode_small",
	LaunchSound = "/weapons/heavy_rocket", 
	ImpactSound = "/impact/generic/explosion_large",
	TipImage = {
		Unit = Point(2,3),
		Enemy1 = Point(2,2),
		Enemy2 = Point(3,1),
		Enemy3 = Point(1,0),
		Enemy4 = Point(2,1),
		Building = Point(1,1),
		Target = Point(2,2)
	}
}

function Prime_WayTooBig:FireFlyBossFlip(point)
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

function Prime_WayTooBig:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local target = GetProjectileEnd(p1,p2)  

	local self_damage = SpaceDamage(p1,self.SelfDamage,(dir+2)%4)
	self_damage.sAnimation = "explopush2_"..(dir+2)%4
	ret:AddDamage(self_damage)
	
	local damage = SpaceDamage(target, self.Damage)
	damage.sAnimation = "explopush2_"..dir
	if self.BuildingImmune and Board:IsBuilding(target) then damage.iDamage = 0 damage.sAnimation = "ExploRepulse1" end
	if self.Flip then damage.iPush = DIR_FLIP end
	ret:AddProjectile(damage,"advanced/effects/shot_bigone")
	if self.Flip then ret:AddScript(self:FireFlyBossFlip(target)) end
	
	for i = -1, 1 do
		local curr = target + DIR_VECTORS[dir] + (DIR_VECTORS[(dir-1)%4]) * i
		damage = SpaceDamage(curr, 2)
		damage.sAnimation = "ExploAir2"
		if self.BuildingImmune and Board:IsBuilding(curr) then damage.iDamage = 0 damage.sAnimation = "ExploRepulse1" end
		if self.Flip then damage.iPush = DIR_FLIP end
		ret:AddDamage(damage)
		if self.Flip then ret:AddScript(self:FireFlyBossFlip(curr)) end
	end
	
	for i = -2, 2 do
		local curr = target + (DIR_VECTORS[dir]*2) + (DIR_VECTORS[(dir-1)%4]) * i
		damage = SpaceDamage(curr, 1)
		damage.sAnimation = "ExploAir1"
		if self.BuildingImmune and Board:IsBuilding(curr) then damage.iDamage = 0 damage.sAnimation = "ExploRepulseSmall" end
		if self.Flip then damage.iPush = DIR_FLIP end
		ret:AddDamage(damage)
		if self.Flip then ret:AddScript(self:FireFlyBossFlip(curr)) end
	end
	
	return ret
end

Prime_WayTooBig_A = Prime_WayTooBig:new{
	BuildingImmune = true,
}

Prime_WayTooBig_B = Prime_WayTooBig:new{
	Flip = true,
	TipImage = {
		Unit = Point(2,3),
		Enemy1 = Point(2,2),
		Enemy2 = Point(3,1),
		Enemy3 = Point(1,0),
		Enemy4 = Point(2,1),
		Building1 = Point(1,1),
		Building2 = Point(3,2),
		Queued1 = Point(3,2),
		Queued2 = Point(3,2),
		Queued3 = Point(1,1),
		Queued4 = Point(1,1),
		Target = Point(2,2)
	}
}

Prime_WayTooBig_AB = Prime_WayTooBig_B:new{
	BuildingImmune = true,
} 