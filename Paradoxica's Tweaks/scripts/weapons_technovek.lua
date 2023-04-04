--------------  ChargeMech - Beetle charge  ------------
	
Vek_Beetle = Skill:new{
	Class = "TechnoVek",
	Portrait = "",
	Icon = "weapons/vek_beetle.png",	
	Rarity = 3,
	Explosion = "",
	Push = 1,--TOOLTIP HELPER
	Fly = 1,
	Damage = 2,
	SelfDamage = 0,
	BackSmoke = 0,
	PathSize = INT_MAX,
	Cost = "med",
	PowerCost = 0, --AE Change
	Upgrades = 2,
	UpgradeCost = {1,2},
	LaunchSound = "/weapons/charge",
	ImpactSound = "/weapons/charge_impact",
	ZoneTargeting = ZONE_DIR,
	TipImage = {
		Unit = Point(0,2),
		Enemy = Point(3,2),
		Target = Point(3,2),
		CustomPawn = "BeetleMech"
	}
}
			
function Vek_Beetle:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)

	local pathing = PATH_PROJECTILE
	if self.Fly == 0 then pathing = Pawn:GetPathProf() end

	local doDamage = true
	local target = GetProjectileEnd(p1,p2,pathing)
	local distance = p1:Manhattan(target)
	
	if not Board:IsBlocked(target,pathing) then -- dont attack an empty edge square, just run to the edge
		doDamage = false
		target = target + DIR_VECTORS[direction]
	end
	
	if self.BackSmoke == 1 then
		local smoke = SpaceDamage(p1 - DIR_VECTORS[direction], 0)
		smoke.iSmoke = 1
		ret:AddDamage(smoke)
	end
	
	local damage = SpaceDamage(target, self.Damage, direction)
	damage.sAnimation = "ExploAir2"
	damage.sSound = self.ImpactSound
	
	if distance == 1 and doDamage then
		ret:AddMelee(p1,damage, NO_DELAY)
		if doDamage then ret:AddDamage(SpaceDamage( target - DIR_VECTORS[direction] , self.SelfDamage)) end
	else
		ret:AddCharge(Board:GetSimplePath(p1, target - DIR_VECTORS[direction]), NO_DELAY)--FULL_DELAY)

		local temp = p1 
		while temp ~= target  do 
			ret:AddBounce(temp,-3)
			temp = temp + DIR_VECTORS[direction]
			if temp ~= target then
				ret:AddDelay(0.07)
			end
		end
		
		if doDamage then
			ret:AddDamage(damage)
			ret:AddDamage(SpaceDamage( target - DIR_VECTORS[direction] , self.SelfDamage))
		end
	
	end
	

	return ret
end
			
Vek_Beetle_A = Vek_Beetle:new{
		BackSmoke = 1,
		TipImage = {
		Unit = Point(1,2),
		Enemy = Point(3,2),
		Target = Point(3,2),
		CustomPawn = "BeetleMech"
		}
}

Vek_Beetle_B = Vek_Beetle:new{
		Damage = 3,
}

Vek_Beetle_AB = Vek_Beetle:new{
		BackSmoke = 1,
		Damage = 3,
		TipImage = {
		Unit = Point(1,2),
		Enemy = Point(3,2),
		Target = Point(3,2),
		CustomPawn = "BeetleMech"
		}
}

Vek_Hornet = Prime_Spear:new{  
	Class = "TechnoVek",
	Icon = "weapons/vek_hornet.png",
	Explosion = "",
	Range = 1, 
	PathSize = 1,
	Damage = 1,
	Push = 1,
	Flip = false,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 2 , 3 },
	LaunchSound = "/enemy/hornet_1/attack",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Target = Point(2,2),
		CustomPawn = "HornetMech"
	}
}

function Vek_Hornet:FireFlyBossFlip(point)
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

function Vek_Hornet:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)
	local dor = DIR_NONE
	if self.Flip then dor = DIR_FLIP end
	for i = 1, distance do
		local push = (i == distance) and direction*self.Push or dor
		local damage = SpaceDamage(p1 + DIR_VECTORS[direction]*i,self.Damage, push)
		damage.sAnimation = "explohornet_"..direction
		damage.fDelay = 0.15
		ret:AddDamage(damage)
		if (i ~= distance) and self.Flip then ret:AddScript(self:FireFlyBossFlip(p1 + DIR_VECTORS[direction]*i)) end
	end

	return ret
end	

Vek_Hornet_A = Vek_Hornet:new{
	PathSize = 2, 
	Range = 2,
	Damage = 2,
	TipImage = {
		Unit = Point(2,3),
		Enemy1 = Point(2,2),
		Enemy2 = Point(2,1),
		Target = Point(2,1),
		CustomPawn = "HornetMech"
	}
}

Vek_Hornet_B = Vek_Hornet:new{
	PathSize = 2, 
	Range = 2,
	Damage = 2,
	Flip = true,
	TipImage = {
		Unit = Point(2,3),
		Enemy1 = Point(2,2),
		Enemy2 = Point(2,1),
		Friendly = Point(1,2),
		Queued1 = Point(1,2),
		Target = Point(2,1),
		CustomPawn = "HornetMech"
	}
}

Vek_Hornet_AB = Vek_Hornet:new{
	PathSize = 3, 
	Range = 3,
	Damage = 3,
	Flip = true,
	TipImage = {
		Unit = Point(2,4),
		Enemy1 = Point(2,2),
		Enemy2 = Point(2,1),
		Friendly = Point(1,2),
		Queued1 = Point(1,2),
		Target = Point(2,1),
		CustomPawn = "HornetMech"
	}
}

Vek_Scarab = 	ArtilleryDefault:new{
	Class = "TechnoVek",
	Icon = "weapons/vek_scarab.png",
	Rarity = 3,
	UpShot = "effects/shotup_ant1.png",
	ArtilleryStart = 2,
	ArtillerySize = 8,
	BuildingDamage = true,
	TwoClick = false,
	Push = 1,
	DamageOuter = 0,
	DamageCenter = 1,
	PowerCost = 0,
	Damage = 1,---USED FOR TOOLTIPS
	Explosion = "",
	ExplosionCenter = "ExploArt1",
	ExplosionOuter = "",
	Upgrades = 2,
	UpgradeCost = {1,3},
	LaunchSound = "/enemy/scarab_1/attack",
	ImpactSound = "/impact/generic/explosion",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(3,2),
		Enemy3 = Point(2,1),
		Target = Point(2,2),
		Mountain = Point(2,3),
		CustomPawn = "ScarabMech"
	}
}

function Vek_Scarab:GetSkillEffect(p1, p2)	
	local ret = SkillEffect()
	direction = GetDirection(p2 - p1)
	
	local damage = SpaceDamage(p2,self.DamageCenter)
	damage.sAnimation = self.ExplosionCenter
	ret:AddArtillery(damage, self.UpShot)
	
	if not self.TwoClick then
		for dir = 0, 3 do
			damage = SpaceDamage(p2 + DIR_VECTORS[dir],  self.DamageOuter, dir)
			damage.sAnimation = "airpush_"..dir
			ret:AddDamage(damage)
		end
	end

	return ret
end

Vek_Scarab_A = Vek_Scarab:new{
	TwoClick = true,
	ExplosionCenter = "ExploArt1",
	TipImage = {
		Unit = Point(2,4),
		Enemy1 = Point(2,2),
		Enemy2 = Point(3,2),
		Enemy3 = Point(2,1),
		Target = Point(2,2),
		Second_Click = Point(2,3),
		Mountain = Point(2,3),
		CustomPawn = "ScarabMech"
	}
}

function Vek_Scarab_A:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	ret:push_back(p1)
	for i = 0,3 do if Board:IsValid(p2+DIR_VECTORS[i]) then ret:push_back(p2+DIR_VECTORS[i]) end end
	return ret
end

function Vek_Scarab_A:GetFinalEffect(p1,p2,p3)
	local ret = SkillEffect()
	if p3 == p1 then 
		ret = self:GetSkillEffect(p1,p2)
		for dir = 0, 3 do
			damage = SpaceDamage(p2 + DIR_VECTORS[dir],  self.DamageOuter, dir)
			damage.sAnimation = "airpush_"..dir
			ret:AddDamage(damage)
		end
		return ret
	end

	direction = GetDirection(p3 - p2)
	
	local damage = SpaceDamage(p2,self.DamageCenter)
	damage.sAnimation = self.ExplosionCenter
	ret:AddArtillery(damage, self.UpShot)
	
	damage = SpaceDamage(p2 + DIR_VECTORS[direction], self.DamageCenter)
	ret:AddDamage(damage)

	for dir = 0, 2 do
		damage = SpaceDamage(p2 + DIR_VECTORS[(direction-dir-1)%4],  self.DamageOuter, (direction-dir-1)%4 )
		damage.sAnimation = "airpush_"..(direction-dir-1)%4
		ret:AddDamage(damage)
	end
	for dir = 0, 2 do
		damage = SpaceDamage(p2 + DIR_VECTORS[direction]+DIR_VECTORS[(direction+dir-1)%4],  self.DamageOuter, (direction+dir-1)%4 )
		damage.sAnimation = "airpush_"..(direction+dir-1)%4
		ret:AddDamage(damage)
	end
	
	return ret
end

Vek_Scarab_B = Vek_Scarab:new{
	DamageCenter = 3,
	Damage = 3,---USED FOR TOOLTIPS
	ExplosionCenter = "ExploArt2",
	ImpactSound = "/impact/generic/explosion_large",
}

Vek_Scarab_AB = Vek_Scarab_A:new{
		DamageCenter = 3,
		Damage = 3,---USED FOR TOOLTIPS
		ExplosionCenter = "ExploArt2",
		ImpactSound = "/impact/generic/explosion_large",
	}