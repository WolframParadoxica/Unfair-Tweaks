---------- RocketMech - Rocket Launcher ---------------------

Ranged_Rocket = LineArtillery:new{
	Class = "Ranged",
	Damage = 2,
	PowerCost = 0, --AE Change
	LaunchSound = "/weapons/rocket_launcher",
	ImpactSound = "/impact/generic/explosion_large",
	Icon = "weapons/ranged_rocket.png",
	UpShot = "effects/shotup_guided_missile.png",
	Explosion = "",
	BounceAmount = 2,
	Smoke = 0,
	Upgrades = 2,
	--UpgradeList = { "+1 Damage",  "+1 Damage"  },
	UpgradeCost = { 2,3 },
	TipImage = StandardTips.Ranged
}

function Ranged_Rocket:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	--local target = GetProjectileEnd(p1,p2)  
	
	ret:AddBounce(p1, 1)
	if not self.TwoClick then
		local smoke = SpaceDamage(p1 - DIR_VECTORS[direction],0)
		smoke.iSmoke = 1
		smoke.sAnimation = "exploout0_"..GetDirection(p1 - p2)
		ret:AddDamage(smoke)
	end
	
	local damage = SpaceDamage(p2, self.Damage)
	damage.iPush = direction
	damage.iSmoke = self.Smoke
	damage.sAnimation = "explopush2_"..direction

	ret:AddArtillery(damage, self.UpShot)
	ret:AddBounce(p2, self.BounceAmount)
	
	return ret
end

Ranged_Rocket_A = Ranged_Rocket:new{
	TwoClick = true,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy = Point(2,1),
		Enemy2 = Point(2,2),
		Enemy3 = Point(3,3),
		Second_Click = Point(3,3),
		}
}

function Ranged_Rocket_A:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	local direction = GetDirection(p2 - p1)
	
	for i = DIR_START, DIR_END do
		local curr = p1 + DIR_VECTORS[i]
		if Board:IsValid(curr) then
			ret:push_back(curr)
		end
	end
	
	return ret
end

function Ranged_Rocket_A:GetFinalEffect(p1, p2, p3)	
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local direction2 = GetDirection(p3 - p1)
	--local target = GetProjectileEnd(p1,p2)  
	
	ret:AddBounce(p1, 1)
	local smoke = SpaceDamage(p1 + DIR_VECTORS[direction2],0)
	smoke.iSmoke = 1
	smoke.sAnimation = "exploout0_"..GetDirection(p3 - p1)
	ret:AddDamage(smoke)
	
	local damage = SpaceDamage(p2, self.Damage)
	damage.iPush = direction
	damage.iSmoke = self.Smoke
	damage.sAnimation = "explopush2_"..direction

	ret:AddArtillery(damage, self.UpShot)
	ret:AddBounce(p2, self.BounceAmount)
	
	return ret
end

Ranged_Rocket_B = Ranged_Rocket:new{
	Damage = 4,
	BounceAmount = 3,
}

Ranged_Rocket_AB = Ranged_Rocket_A:new{
	Damage = 4,
	BounceAmount = 3,
}

--------------- RockartMech - RockLaunch ------------------------
Ranged_Rockthrow = ArtilleryDefault:new{-- LineArtillery:new{
	Class = "Ranged",
	Icon = "weapons/ranged_rockthrow.png",
	Sound = "",
	ArtilleryStart = 2,
	ArtillerySize = 8,
	Explosion = "",
	PowerCost = 0, --AE Change
	BounceAmount = 1,
	Damage = 2,
	LaunchSound = "/weapons/boulder_throw",
	ImpactSound = "/impact/dynamic/rock",
	Upgrades = 2,
	Push = false,
	UpgradeCost = {2,3},
	--UpgradeList = { "+1 Damage" },
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,1),
		Enemy2 = Point(3,1),
		Target = Point(2,1)
	}
}
					
function Ranged_Rockthrow:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local damage = SpaceDamage(p2, self.Damage)
	
	if Board:IsValid(p2) and not Board:IsBlocked(p2,PATH_PROJECTILE) then
		damage.sPawn = "RockThrown"
		damage.sAnimation = ""
		damage.iDamage = 0
	else 
		damage.sAnimation = "rock1d" 
	end
	
	ret:AddBounce(p1, 1)
	ret:AddArtillery(damage,"effects/shotdown_rock.png")
	ret:AddBounce(p2, self.BounceAmount)
	ret:AddBoardShake(0.15)

	local damagepush = SpaceDamage(p2 + DIR_VECTORS[(dir+1)%4], 0, (dir+1)%4)
	damagepush.sAnimation = "airpush_"..((dir+1)%4)
	ret:AddDamage(damagepush) 
	damagepush = SpaceDamage(p2 + DIR_VECTORS[(dir-1)%4], 0, (dir-1)%4)
	damagepush.sAnimation = "airpush_"..((dir-1)%4)
	ret:AddDamage(damagepush)
	
	
	return ret
end

Ranged_Rockthrow_A = Ranged_Rockthrow:new{
	UpgradeDescription = "Increases damage by 1.",
	Damage = 3,
	BounceAmount = 3,
}

Ranged_Rockthrow_B = Ranged_Rockthrow:new{
	TwoClick = true,
	Damage = 2,
	BounceAmount = 1,
	UpgradeDescription = "Fire a second rock in a different direction.",
	TipImage = {
		Unit = Point(1,3),
		Target = Point(1,1),
		Friendly = Point(3,2),
		Enemy = Point(1,1),
		Enemy2 = Point(2,1),
		Enemy3 = Point(3,4),
		Second_Click = Point(3,3),
		Length = 9,
	}
}

function Ranged_Rockthrow_B:GetSecondTargetArea(p1, p2)  --This is a copy of the GetTargetArea for LineArtillery
	local ret = PointList()
	local dir = GetDirection(p2 - p1)
	for j = 1, 3 do
		for i = 2, 8 do
			local curr = Point(p1 + DIR_VECTORS[(dir+j)%4] * i)
			if not Board:IsValid(Point(p1 + DIR_VECTORS[(dir+j)%4] * i)) then  
				break
			end
			ret:push_back(curr)
		end
	end
	return ret
end

function Ranged_Rockthrow_B:GetFinalEffect(p1, p2, p3)
	local d1 = GetDirection(p2 - p1)
	local d2 = GetDirection(p3 - p1)
	local ret = SkillEffect()
	
	local damage = SpaceDamage(p2,self.Damage)
	if Board:IsValid(p2) and not Board:IsBlocked(p2,PATH_PROJECTILE) then
		damage.sPawn = "RockThrown"
		damage.sAnimation = ""
		damage.iDamage = 0
	else 
		damage.sAnimation = "rock1d" 
	end
	
	ret:AddBounce(p1, 1)
	ret:AddArtillery(damage,"effects/shotdown_rock.png")
	ret:AddBounce(p2, self.BounceAmount)
	ret:AddBoardShake(0.15)

	local damagepush = SpaceDamage(p2 + DIR_VECTORS[(d1+1)%4], 0, (d1+1)%4)
	damagepush.sAnimation = "airpush_"..((d1+1)%4)
	ret:AddDamage(damagepush) 
	damagepush = SpaceDamage(p2 + DIR_VECTORS[(d1-1)%4], 0, (d1-1)%4)
	damagepush.sAnimation = "airpush_"..((d1-1)%4)
	ret:AddDamage(damagepush)

	ret:AddDelay(FULL_DELAY)

	damage = SpaceDamage(p3,self.Damage)
	if Board:IsValid(p3) and not Board:IsBlocked(p3,PATH_PROJECTILE) then
		damage.sPawn = "RockThrown"
		damage.sAnimation = ""
		damage.iDamage = 0
	else 
		damage.sAnimation = "rock1d" 
	end
	
	ret:AddSound("/weapons/boulder_throw")
	ret:AddBounce(p1, 1)
	ret:AddArtillery(damage,"effects/shotdown_rock.png")
	ret:AddBounce(p3, self.BounceAmount)
	ret:AddBoardShake(0.15)

	local damagepush = SpaceDamage(p3 + DIR_VECTORS[(d2+1)%4], 0, (d2+1)%4)
	damagepush.sAnimation = "airpush_"..((d2+1)%4)
	ret:AddDamage(damagepush) 
	damagepush = SpaceDamage(p3 + DIR_VECTORS[(d2-1)%4], 0, (d2-1)%4)
	damagepush.sAnimation = "airpush_"..((d2-1)%4)
	ret:AddDamage(damagepush)
	
	return ret
	
end

Ranged_Rockthrow_AB = Ranged_Rockthrow_B:new{
	Damage = 3,
	BounceAmount = 3,
}

---------- IgniteMech - Ignite Shot ---------------------

Ranged_Ignite = LineArtillery:new{
	Class = "Ranged",
	Icon = "weapons/ranged_ignite.png",
	Rarity = 3,
	UpShot = "effects/shotup_ignite_fireball.png",
	BuildingDamage = true,
	PowerCost = 0, --AE Change
	Damage = 0,
	BounceAmount = 1,
	Upgrades = 2,
	UpgradeCost = {1,3},
--	UpgradeList = { "Backburn", "+2 Damage"  },
	LaunchSound = "/weapons/fireball",
	ImpactSound = "/props/fire_damage",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		--Fire = Point(2,2),
		Enemy2 = Point(3,1),
		--Enemy3 = Point(2,1),
		Target = Point(2,1),
		Mountain = Point(2,2)
	}
}

function Ranged_Ignite:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p1 - p2)
	
	ret:AddBounce(p1, 1)
	if self.Backhit == 1 then
		local back = SpaceDamage(p1 + DIR_VECTORS[direction], 0)
		back.iFire = 1
		--back.sAnimation = "explopush1_"..direction
		ret:AddDamage(back)
	end
	
	local damage = SpaceDamage(p2,self.Damage)
	damage.sAnimation = "ExploArt2"
	damage.iFire = 1
	ret:AddArtillery(damage, self.UpShot)
	
	for dir = DIR_START, DIR_END do
		damage = SpaceDamage(p2 + DIR_VECTORS[dir], 0)
		damage.iPush = dir
		damage.sAnimation = "airpush_"..dir
		ret:AddDamage(damage)
	end
	ret:AddBounce(p2, self.BounceAmount)
	
	return ret
end

Ranged_Ignite_A = Ranged_Ignite:new{
	TwoClick = true,
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		--Fire = Point(2,2),
		Enemy2 = Point(3,1),
		Enemy3 = Point(1,3),
		Target = Point(2,1),
		Mountain = Point(2,2),
		Second_Click = Point(1,3)
	}
}

function Ranged_Ignite_A:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	local direction = GetDirection(p2 - p1)
	
	for i = DIR_START, DIR_END do
		local curr = p1 + DIR_VECTORS[i]
		if Board:IsValid(curr) then
			ret:push_back(curr)
		end
	end
	
	return ret
end

function Ranged_Ignite_A:GetFinalEffect(p1, p2, p3)	
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local direction2 = GetDirection(p3 - p1)
	
	ret:AddBounce(p1, 1)
	if self.TwoClick then
		local back = SpaceDamage(p1 + DIR_VECTORS[direction2], 0)
		back.iFire = 1
		--back.sAnimation = "explopush1_"..direction
		ret:AddDamage(back)
	end
	
	local damage = SpaceDamage(p2,self.Damage)
	damage.sAnimation = "ExploArt2"
	damage.iFire = 1
	ret:AddArtillery(damage, self.UpShot)
	
	for dir = DIR_START, DIR_END do
		damage = SpaceDamage(p2 + DIR_VECTORS[dir], 0)
		damage.iPush = dir
		damage.sAnimation = "airpush_"..dir
		ret:AddDamage(damage)
	end
	ret:AddBounce(p2, self.BounceAmount)
	
	return ret
end

Ranged_Ignite_B = Ranged_Ignite:new{
	Damage = 2,
	BounceAmount = 2,
}
			
Ranged_Ignite_AB = Ranged_Ignite_A:new{
	Damage = 2,
	BounceAmount = 2,
}

--------------- IceMech - Ranged Ice ------------------

Ranged_Ice = ArtilleryDefault:new{-- LineArtillery:new{
	Class = "Ranged",
	Icon = "weapons/ranged_ice.png",
	Sound = "",
	ArtilleryStart = 2,
	ArtillerySize = 8,
	Explosion = "ExplIce1",
	PowerCost = 1, --AE Change
	Damage = 0,
	Wide = false,
	LaunchSound = "/weapons/ice_throw",
	ImpactSound = "/impact/generic/ice",
	Upgrades = 1,
	UpgradeCost = {2},
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,1)
	}
}
					
function Ranged_Ice:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	
	ret:AddBounce(p1, 1)
	
	damage = SpaceDamage(p1, 0)
	damage.iFrozen = EFFECT_CREATE
	ret:AddDamage(damage)
	
	local damage = SpaceDamage(p2, self.Damage)
	damage.iFrozen = EFFECT_CREATE
	ret:AddArtillery(damage,"effects/shotup_ice.png")
	
	ret:AddBounce(p2, 2)
	
	return ret
end

Ranged_Ice_A = Ranged_Ice:new{
	TwoClick = true,
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Friendly = Point(1,2),
		Building = Point(2,3),
		Mountain = Point(3,2),
		Target = Point(2,2),
		Second_Click = Point(6,4)
	}
}

function Ranged_Ice_A:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	
	for j = 2,5 do
		if Point(1,j)~= p2 then ret:push_back(Point(1,j)) end
		if Point(2,j)~= p2 then ret:push_back(Point(2,j)) end
		if Point(5,j)~= p2 then ret:push_back(Point(5,j)) end
		if Point(6,j)~= p2 then ret:push_back(Point(6,j)) end
	end
	
	return ret
end

function Ranged_Ice_A:GetFinalEffect(p1, p2, p3)	
	local ret = SkillEffect()

	if p3.x == 1 or p3.x == 2 then
		self.Wide = false
	elseif p3.x == 5 or p3.x == 6 then
		self.Wide = true
	end
	
	ret:AddBounce(p1, 1)
	
	if self.Wide then 
		local damage = (SpaceDamage( p1 , 1))
		damage.sAnimation = "ExploAir1"
		ret:AddDamage(damage)
	end
	
	damage = SpaceDamage(p1, 0)
	damage.iFrozen = EFFECT_CREATE
	ret:AddDamage(damage)
	
	damage = SpaceDamage(p2,0)
	damage.iFrozen = EFFECT_CREATE
	
	ret:AddArtillery(damage,"effects/shotup_ice.png")
	ret:AddBounce(p2, 2)
	
	if self.Wide then 
		for i = DIR_START, DIR_END do
			damage.loc = p2 + DIR_VECTORS[i]
			damage.iFrozen = EFFECT_CREATE
			ret:AddDamage(damage)
			ret:AddBounce(p2 + DIR_VECTORS[i], 2)
		end
		
		damage = SpaceDamage(p1,0)
		damage.iShield = 1
		ret:AddDamage(damage)
	end
	
	return ret
end

-------------------------------- Gemini Missiles ----------------------------------

Ranged_Dual = ArtilleryDefault:new{
	Class = "Ranged",
	Icon = "weapons/ranged_dual.png",
	Rarity = 1,
	Explosion = "",
	ExploArt = "explopush1_",
	Damage = 3,
	BounceAmount = 2,
	PowerCost = 1, --AE Change
	Upgrades = 2,
	Limited = 1,
	UpgradeCost = {1,1},
	--UpgradeList = {  "+1 Use","+1 Damage" },
	LaunchSound = "/weapons/dual_missiles",
	ImpactSound = "/impact/generic/explosion",
	TwoClick = true,
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(1,2),
		Enemy2 = Point(3,2),
		Target = Point(2,2),
		Second_Click = Point(3,3),
	}
}		

function Ranged_Dual:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	local dir = GetDirection(p2 - p1)
	for i = 3,4 do
		for j = 1,6 do
			if dir%2 == 1 then
				if Point(j,i)~= p2 then ret:push_back(Point(j,i)) end
			else
				if Point(i,j)~= p2 then ret:push_back(Point(i,j)) end
			end
		end
	end
	return ret
end

function Ranged_Dual:GetSkillEffect(p1, p2)	
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local damage = SpaceDamage(p2 + DIR_VECTORS[(direction+1)%4], self.Damage)
	local damage2 = SpaceDamage(p2 + DIR_VECTORS[(direction-1)%4], self.Damage)
	ret:AddArtillery(SpaceDamage(p2),"")
	ret:AddDamage(damage)
	ret:AddDamage(damage2)
	return ret
end

function Ranged_Dual:GetFinalEffect(p1, p2, p3)	
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local dir = direction
	local dir2 = direction
	if direction%2 == 1 then
		if p3.x == 1 or p3.x == 2 then
			dir = 3
			dir2 = 3
		elseif p3.x == 5 or p3.x == 6 then
			dir = 1
			dir2 = 1
		else
			dir = (direction+1)%4
			dir2 = (direction-1)%4
		end
	else
		if p3.y == 1 or p3.y == 2 then
			dir = 0
			dir2 = 0
		elseif p3.y == 5 or p3.y == 6 then
			dir = 2
			dir2 = 2
		else
			dir = (direction+1)%4
			dir2 = (direction-1)%4
		end
	end
	
	local damage = SpaceDamage(p2 + DIR_VECTORS[(direction+1)%4], self.Damage, dir)
	local damage2 = SpaceDamage(p2 + DIR_VECTORS[(direction-1)%4], self.Damage, dir2)
	
	ret:AddBounce(p1, 1)

	local dummy = SpaceDamage(damage.loc)
	dummy.bHide = true
	dummy.sAnimation = self.ExploArt..dir
	ret:AddArtillery(dummy,"effects/shotup_guided_missile.png",NO_DELAY)
	dummy.loc = damage2.loc
	dummy.sAnimation = self.ExploArt..dir2
	ret:AddArtillery(dummy,"effects/shotup_guided_missile.png",NO_DELAY)
	
	ret:AddArtillery(SpaceDamage(p2),"")
	ret:AddDamage(damage)
	ret:AddDamage(damage2)
	
	ret:AddBounce(p2 + DIR_VECTORS[(direction+1)%4], self.BounceAmount)
	ret:AddBounce(p2 + DIR_VECTORS[(direction-1)%4], self.BounceAmount)
	return ret
end

Ranged_Dual_A = Ranged_Dual:new{
		Limited = 2,
	--	UpgradeDescription = "Increases uses per battle by 1."
}

Ranged_Dual_B = Ranged_Dual:new{
		Damage = 4,
		ExploArt = "explopush2_",
		BounceAmount = 3,
		--UpgradeDescription = "Increases damage by 1."
}

Ranged_Dual_AB = Ranged_Dual:new{
		Damage = 4,
		Limited = 2,
		ExploArt = "explopush2_",
		BounceAmount = 3,
}

------------------ Fireball ----------------------------

Ranged_Fireball = 	{
	Class = "Ranged",
	Icon = "weapons/ranged_fireball.png",
	Rarity = 1,
	Explosion = "",
	Damage = 0,
	SelfDamage = 1,
	Push = false,--TOOLTIP INFO
	Cost = "med",
	PowerCost = 0, --AE Change
	Upgrades = 2,
	UpgradeCost = { 2,2 },
	LaunchSound = "/weapons/fireball",
	ImpactSound = "/impact/generic/explosion",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Enemy2 = Point(3,1),
		Target = Point(2, 1)
	}
}		
Ranged_Fireball = ArtilleryDefault:new(Ranged_Fireball)

function Ranged_Fireball:GetSkillEffect(p1, p2)	
	local ret = SkillEffect()
	
	ret:AddBounce(p1, 1)
	
	local damage = (SpaceDamage( p1 , self.SelfDamage))
	damage.sAnimation = "ExploAir1"
	if self.SelfDamage ~= 0 then ret:AddDamage(damage) end
	
	damage = SpaceDamage(p2,self.Damage)
	damage.iFire = 1
	damage.sAnimation = "explo_fire1"
	
	ret:AddArtillery(damage,"effects/shotup_fireball.png")
	ret:AddBounce(p2, 2)
	
	for i = DIR_START, DIR_END do
		damage.loc = p2 + DIR_VECTORS[i]
		if self.Push then damage.iPush = i end
		damage.sAnimation = "exploout2_"..i
		ret:AddDamage(damage)
		ret:AddBounce(p2 + DIR_VECTORS[i], 2)
	end
	
	return ret
end		

Ranged_Fireball_A = Ranged_Fireball:new{
	SelfDamage = 0,
}

Ranged_Fireball_B = Ranged_Fireball:new{
	Push = true,
}

Ranged_Fireball_AB = Ranged_Fireball:new{
	SelfDamage = 0,
	Push = true,
}

-------------------------------- Ranged Aracnoid ----------------------------------

Ranged_Arachnoid = Ranged_Arachnoid:new{
UpgradeCost = {3,1},
}

Ranged_Arachnoid_A = Ranged_Arachnoid:new{
	Damage = 3,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy1 = Point(2,1),
		Enemy2 = Point(3,1),
		CustomEnemy = "Firefly1",
		Second_Origin = Point(2,1),
		Second_Target = Point(3,1),
		Length = 6,
	},
}

Ranged_Arachnoid_AB = Ranged_Arachnoid:new{
	Damage = 3,
	MyPawn = "DeployUnit_AracnoidB",
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy1 = Point(2,1),
		Enemy2 = Point(3,1),
		CustomEnemy = "Firefly1",
		Second_Origin = Point(2,1),
		Second_Target = Point(3,1),
		Length = 6,
	},
}

------------------- Bounce Shot----------------------------

Ranged_TC_BounceShot = Ranged_TC_BounceShot:new{ 
	Icon = "advanced/weapons/Ranged_TC_BounceShot.png",
	Class = "Ranged",
	LaunchSound = "/weapons/artillery_volley",
	ImpactSound = "/impact/generic/explosion",
	TwoClick = true,
	BuildingDamage = true,
	Ricochet = false,
	PowerCost = 1,
	Damage = 2,
	Upgrades = 2,
	UpgradeCost	= { 2, 1 },
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Target = Point(2,2),
		Second_Click = Point(2,1),
	},
}

function Ranged_TC_BounceShot:GetTargetArea(point)  --This is a copy of the GetTargetArea for LineArtillery
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		for i = 2, 8 do
			local curr = Point(point + DIR_VECTORS[dir] * i)
			if not Board:IsValid(Point(point + DIR_VECTORS[dir] * i)) then  --if you dont want it to hit the last tile: "i" to "(i+1)"
				break
			end
			
			if not self.OnlyEmpty or not Board:IsBlocked(curr,PATH_GROUND) then
				ret:push_back(curr)
			end

		end
	end
	
	return ret
end


function Ranged_TC_BounceShot:IsTwoClickException(p1,p2)
	if self:GetSecondTargetArea(p1,p2):size() == 0 then return true else return false end
end


function Ranged_TC_BounceShot:GetSkillEffect(p1, p2)
	local direction = GetDirection(p2 - p1)
	local ret = SkillEffect()
	local damage = SpaceDamage(p2, self.Damage, GetDirection(p1 - p2))
	if not self.BuildingDamage and Board:IsBuilding(p2) then	
		damage.iDamage = DAMAGE_ZERO 	
		damage.sAnimation = "ExploRepulse1"
	end 
	ret:AddBounce(p1,3)
	ret:AddArtillery(damage, "effects/shot_artimech.png")  
	ret:AddBounce(p2,3)
	return ret
end

function Ranged_TC_BounceShot:GetSecondTargetArea(p1, p2)
	local dir = GetDirection(p1 - p2)
	local ret = PointList()
	local curr = p2
	
	if self.Ricochet then
		for i = 1,3 do
			curr = p2
			for j = 1,7 do
				curr = curr + DIR_VECTORS[(dir+i)%4]
				if Board:IsValid(curr) then
					ret:push_back(curr)
				end
			end
		end
	else
		dir = GetDirection(p2 - p1)
		curr = p2 + DIR_VECTORS[dir]
		
		if not Board:IsValid(curr) then
			return PointList()
		end
		
		while Board:IsValid(curr) do
			ret:push_back(curr)
			curr = curr + DIR_VECTORS[dir]
		end
	end
	return ret
end

function Ranged_TC_BounceShot:GetFinalEffect(p1, p2, p3)
	local ret = self:GetSkillEffect(p1,p2)
	local direction = GetDirection(p2 - p1)
	if Board:IsValid(p3) then
		local damage = SpaceDamage(p3, self.Damage, GetDirection(p3 - p2))
		if not self.BuildingDamage and Board:IsBuilding(p3) then	
			damage.iDamage = DAMAGE_ZERO 	
			damage.sAnimation = "ExploRepulse1"
		end 
		ret:AddArtillery(p2, damage, "effects/shot_artimech.png", FULL_DELAY)
	end
	
	return ret
end

Ranged_TC_BounceShot_A = Ranged_TC_BounceShot:new{
		Damage = 3, 
}

Ranged_TC_BounceShot_B = Ranged_TC_BounceShot:new{
		Ricochet = true, 
		TipImage = {
			Unit = Point(1,3),
			Enemy1 = Point(1,1),
			Enemy2 = Point(3,1),
			Target = Point(1,1),
			Second_Click = Point(3,1),
		},
}

Ranged_TC_BounceShot_AB = Ranged_TC_BounceShot_B:new{
		Damage = 3,
}