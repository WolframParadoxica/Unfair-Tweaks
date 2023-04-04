--------------  DeploySkill_PullTank  ------------
	
Deploy_PullTank = Pawn:new{
	Name = "Pull_Tank",
	Health = 1,
	MoveSpeed = 3,
	Image = "PullTank1",
	SkillList = { "Deploy_PullTankShot" },
	--SoundLocation = "/support/civilian_tank/", -- not implemented
	SoundLocation = "/mech/brute/tank",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Corpse = false,
--Corporate = true
}

Deploy_PullTankA = Deploy_PullTank:new{ Health = 3, MoveSpeed = 4, }

Deploy_PullTankB = Deploy_PullTank:new{Flying = true, Image = "PullTank2", }

Deploy_PullTankAB = Deploy_PullTank:new{Health = 3, MoveSpeed = 4, Flying = true, Image = "PullTank2", }

---

Deploy_PullTankShot = Science_Pullmech:new{ Class = "Unique", } --Weapon for the actual tank
				
--
DeploySkill_PullTank = Deployable:new{
	Icon = "weapons/deployskill_pulltank.png",
	Rarity = 1,
	Deployed = "Deploy_PullTank",
	Projectile = "effects/shotup_pulltank.png",
	Cost = "med",
	PowerCost = 2,
	Upgrades = 2,
	UpgradeCost = {2,1},
	LaunchSound = "/weapons/deploy_tank",
	ImpactSound = "/impact/generic/mech",
	TipImage = {
		Unit = Point(1,3),
		Target = Point(1,1),
		Enemy = Point(3,1),
		Second_Origin = Point(1,1),
		Second_Target = Point(2,1),
	},
}

DeploySkill_PullTank_A = DeploySkill_PullTank:new{
		Deployed = "Deploy_PullTankA",
}
DeploySkill_PullTank_B = DeploySkill_PullTank:new{
		Deployed = "Deploy_PullTankB",
		OnlyEmpty = false,
		ImpactSound = "",
}

function DeploySkill_PullTank_B:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		for k = 2, 7 do
			local curr = DIR_VECTORS[i]*k + point
			if (not Board:IsPawnSpace(curr)) and (not Board:IsBlocked(curr, PATH_FLYER)) then ret:push_back(DIR_VECTORS[i]*k + point) end
		end
	end
	return ret
end

function DeploySkill_PullTank_B:GetSkillEffect(p1, p2)	
	local ret = SkillEffect()	
	local damage = SpaceDamage(p2,0)
	damage.sPawn = self.Deployed
	ret:AddArtillery(damage,self.Projectile)
	ret:AddSound("/impact/generic/mech")
	return ret
end

DeploySkill_PullTank_AB = DeploySkill_PullTank_B:new{
		Deployed = "Deploy_PullTankAB",
}

--------------  DeploySkill_ShieldTank  ------------

Deploy_ShieldTank = Pawn:new{
	Name = "Shield_Tank",
	Health = 1,
	MoveSpeed = 3,
	Image = "ShieldTank1",
	SkillList = { "Deploy_ShieldTankShot" },
	--SoundLocation = "/support/civilian_tank/", -- not implemented
	SoundLocation = "/mech/brute/tank",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Corpse = false,
--Corporate = true
}

Deploy_ShieldTankA = Deploy_ShieldTank:new{ Health = 3 }

Deploy_ShieldTankB = Deploy_ShieldTank:new{ SkillList = {"Deploy_ShieldTankShot2"} }

Deploy_ShieldTankAB = Deploy_ShieldTank:new{Health = 3, SkillList = {"Deploy_ShieldTankShot2"}}

---

Deploy_ShieldTankShot = Skill:new{  
	Icon = "weapons/deploy_shieldtank.png",
	--Explosion = "ExploAir2",
	LaunchSound = "/weapons/area_shield",
	Range = 1, -- Tooltip?
	PathSize = 1,
	Class = "Unique",
	Damage = 0,
	TipImage = {
		Unit = Point(2,2),
		Building = Point(2,1),
		Target = Point(2,1),
		CustomPawn = "Deploy_ShieldTank"
	}
}
				
function Deploy_ShieldTankShot:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	
	damage = SpaceDamage(p2,0)
	damage.iShield = 1
	ret:AddMelee(p1,damage)
	
	return ret
end	

Deploy_ShieldTankShot2 = ArtilleryDefault:new {
	Rarity = 0,
	Damage = 0,
	Icon = "weapons/deploy_shieldtank.png",
	ProjectileArt = "effects/shot_pull",
	Push = 0,
	Class = "Unique",
	Explosion = "",
	Shield = 1,
	LaunchSound = "/weapons/area_shield",
	--ImpactSound = "/impact/generic/explosion",
	TipImage = {
		Unit = Point(2,3),
		Building1 = Point(2,1),
		Building2 = Point(2,2),
		Target = Point(2,1),
		CustomPawn = "Deploy_ShieldTank"
	}
}

function Deploy_ShieldTankShot2:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	
	local damage = SpaceDamage(p2, self.Damage)
	damage.iShield = self.Shield
	ret:AddArtillery(damage, "effects/shot_pull_U.png", NO_DELAY)
	
	return ret
end
--
Deploy_ShieldTankB = Deploy_ShieldTank:new{ SkillList = {"Deploy_ShieldTankShot2"} }

DeploySkill_ShieldTank = Deployable:new{
	Icon = "weapons/deployskill_shieldtank.png",
	Rarity = 1,
	Deployed = "Deploy_ShieldTank",
	Projectile = "effects/shotup_shieldtank.png",
	Cost = "med",
	PowerCost = 2,
	Upgrades = 2,
	UpgradeCost = {1,1},
	LaunchSound = "/weapons/deploy_tank",
	ImpactSound = "/impact/generic/mech",
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Friendly = Point(3,1),
		Second_Origin = Point(2,1),
		Second_Target = Point(3,1),
	},
}

DeploySkill_ShieldTank_A = DeploySkill_ShieldTank:new{
		Deployed = "Deploy_ShieldTankA",
}
DeploySkill_ShieldTank_B = DeploySkill_ShieldTank:new{
		Deployed = "Deploy_ShieldTankB",
		TipImage = {
			Unit = Point(1,3),
			Target = Point(1,1),
			Friendly = Point(3,1),
			Enemy = Point(2,1),
			Second_Origin = Point(1,1),
			Second_Target = Point(3,1),
		},
}
DeploySkill_ShieldTank_AB = DeploySkill_ShieldTank_B:new{
		Deployed = "Deploy_ShieldTankAB",
}

---- just to preserve obsolete versions of the game -----
DeploySkill_SGenerator = DeploySkill_ShieldTank
DeploySkill_SGenerator_A = DeploySkill_ShieldTank_A
DeploySkill_SGenerator_B = DeploySkill_ShieldTank_B
DeploySkill_SGenerator_AB = DeploySkill_ShieldTank_AB