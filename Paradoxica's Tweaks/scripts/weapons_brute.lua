-------------- TankMech - Cannon  -----------------

Brute_Tankmech = TankDefault:new	{
	Class = "Brute",
	Damage = 1,
	Icon = "weapons/brute_tankmech.png",
	Explosion = "",
	Sound = "/general/combat/explode_small",
	Damage = 1,
	Push = 1,
	PowerCost = 0, --AE Change
	Upgrades = 2,
	UpgradeCost = {1,2},
	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",
	TipImage = StandardTips.Ranged,
	ZoneTargeting = ZONE_DIR,
}
			
Brute_Tankmech_A = Brute_Tankmech:new{
	Damage = 2,
}

Brute_Tankmech_B = Brute_Tankmech:new{
	Damage = 2,
}

Brute_Tankmech_AB = Brute_Tankmech:new{
	Damage = 3,
	Explo = "explopush2_",
}

-------------- JetMech - Strafe -----------------

Brute_Jetmech = Skill:new{
	Class = "Brute",
	Icon = "weapons/brute_jetmech.png",
	Rarity = 3,
	AttackAnimation = "ExploRaining1",
	Sound = "/general/combat/stun_explode",
	MinMove = 2,
	Range = 2,
	Damage = 1,
	Damage2 = 1,
	AnimDelay = 0.2,
	Smoke = 1,
	Acid = 0,
	PowerCost = 0, --AE Change
	DoubleAttack = 0, --does it attack again after stopping moving
	Upgrades = 2,
	UpgradeCost = {2,3},
	LaunchSound = "/weapons/bomb_strafe",
	BombSound = "/impact/generic/explosion",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Target = Point(2,1)
	}
}

function Brute_Jetmech:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		for k = self.MinMove, self.Range do
			if not Board:IsBlocked(DIR_VECTORS[i]*k + point, Pawn:GetPathProf()) then
				ret:push_back(DIR_VECTORS[i]*k + point)
			end
		end
	end
	
	return ret
end

function Brute_Jetmech:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	
	local move = PointList()
	move:push_back(p1)
	move:push_back(p2)
	
	local distance = p1:Manhattan(p2)
	
	ret:AddBounce(p1,2)
	if distance == 1 then
		ret:AddLeap(move, 0.5)--small delay between move and the damage, attempting to make the damage appear when jet is overhead
	else
		ret:AddLeap(move, 0.25)
	end
		
	for k = 1, (self.Range-1) do
		
		if p1 + DIR_VECTORS[dir]*k == p2 then
			break
		end
		
		local damage = SpaceDamage(p1 + DIR_VECTORS[dir]*k, self.Damage)
		
		damage.iSmoke = self.Smoke
		damage.iAcid = self.Acid
		
		damage.sAnimation = self.AttackAnimation
		damage.sSound = self.BombSound
		
		if k ~= 1 then
			ret:AddDelay(self.AnimDelay) --was 0.2
		end
		
		ret:AddDamage(damage)
		
		ret:AddBounce(p1 + DIR_VECTORS[dir]*k,3)
		
	--	ret:AddSound(self.BombLaunchSound)
	end
	
	if self.DoubleAttack == 1 then
		ret:AddDamage(SpaceDamage(p1 + DIR_VECTORS[dir]*(self.Range+1), self.Damage2))
	end
	
	
	return ret
end

Brute_Jetmech_A = Brute_Jetmech:new{
	Damage = 2, 
	Range = 3, 
	AttackAnimation = "ExploRaining2",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Target = Point(2,0)
	}
}

Brute_Jetmech_B = Brute_Jetmech:new{
	Damage = 2, 
	Range = 3, 
	AttackAnimation = "ExploRaining2",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Enemy2 = Point(2,1),
		Target = Point(2,0)
	}
}

Brute_Jetmech_AB = Brute_Jetmech:new{
	Damage = 3, 
	Range = 4, 
	AttackAnimation = "ExploRaining3",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,3),
		Enemy2 = Point(2,2),
		Enemy3 = Point(2,1),
		Target = Point(2,0)
	}
}

--------------  ChargeMech - Beetle charge  ------------
	
Brute_Beetle = Skill:new{
	Class = "Brute",
	Icon = "weapons/brute_beetle.png",	
	Rarity = 3,
	Explosion = "ExploAir1",
	Push = 1,--TOOLTIP HELPER
	Fly = 1,
	Damage = 2,
	SelfDamage = 0,
	BackSmoke = 0,
	PathSize = INT_MAX,
	Cost = "med",
	PowerCost = 0, --AE Change
	Upgrades = 2,
	UpgradeCost = {1,3},
	LaunchSound = "/weapons/charge",
	ImpactSound = "/weapons/charge_impact",
	ZoneTargeting = ZONE_DIR,
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,0),
		Enemy2 = Point(2,1),
		CustomEnemy = "FireflyBoss",
		Target = Point(2,1)
	}
}

function Brute_Beetle:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local burrow_alive = true
	
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
			damage.bKO_Effect = Board:IsDeadly(damage,Pawn)
			burrow_alive = not damage.bKO_Effect
			damage.bKO_Effect = false
			ret:AddDamage(damage)
			ret:AddDamage(SpaceDamage( target - DIR_VECTORS[direction] , self.SelfDamage))
		end
	end
	if doDamage then
		local damage = SpaceDamage(0)--phantom damage to stall board state
		damage.fDelay = 1.5
		if Board:IsPawnSpace(target) and ((Board:GetPawn(target):IsBurrower() and burrow_alive) or Board:IsCracked(target) or Board:IsTerrain(target,TERRAIN_HOLE)) then damage.fDelay = 0 end
		ret:AddDamage(damage)
		local afterpush = SpaceDamage (target - DIR_VECTORS[direction], 0, direction)
		afterpush.sAnimation = "airpush_"..direction
		afterpush.loc = target - DIR_VECTORS[direction]
		ret:AddDamage(afterpush)
	end
	
	return ret
end

Brute_Beetle_A = Brute_Beetle:new{
		Damage = 3,
		SelfDamage = 1,
}

Brute_Beetle_B = Brute_Beetle:new{
		Damage = 3,
}

Brute_Beetle_AB = Brute_Beetle:new{
		Damage = 4,
		SelfDamage = 1,
}

--------------  Defensive Shrapnel  -----------------
	
Brute_Shrapnel = TankDefault:new	{
	Class = "Brute",
	Damage = 0,
	Icon = "weapons/brute_shrapnel.png",
	Explosion = "",
	Sound = "/general/combat/explode_small",
	Damage = 0,
	Push = 1,
	ShieldTarget = false,
	ShieldFriendly = false,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {1,1},
	LaunchSound = "/weapons/shrapnel",
	ImpactSound = "/impact/generic/explosion",
	ZoneTargeting = ZONE_DIR,
	TipImage = {
		Unit = Point(2,4),
		Enemy1 = Point(1,2),
		Enemy2 = Point(3,2),
		Enemy3 = Point(2,1),
		Building = Point(2,2),
		Target = Point(2,2)
	}
}
			
function Brute_Shrapnel:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local target = GetProjectileEnd(p1,p2)  
	
	local damage = SpaceDamage(target, self.Damage)
	if self.ShieldTarget then damage.iShield = 1 end
	ret:AddProjectile(damage, "effects/shot_shrapnel")
--	ret.path = Board:GetSimplePath(p1, target)
	
	for dir = 0, 3 do
		local curr = target + DIR_VECTORS[dir]
		damage = SpaceDamage(curr, 0, dir)
		damage.sAnimation = "airpush_"..dir
		if dir ~= GetDirection(p1 - p2) then
			if self.ShieldFriendly and (Board:IsBuilding(curr) or (Board:IsPawnSpace(curr) and Board:IsPawnTeam(curr, TEAM_PLAYER))) then
			damage.iShield = 1
			end
			ret:AddDamage(damage)
		end
	end
	
	return ret
end

Brute_Shrapnel_A = Brute_Shrapnel:new{
		ShieldTarget = true,
	TipImage = {
		Unit = Point(2,4),
		Friendly1 = Point(1,2),
		Friendly2 = Point(3,2),
		Enemy1 = Point(2,1),
		Enemy2 = Point(2,2),
		Target = Point(2,2)
	}
}

Brute_Shrapnel_B = Brute_Shrapnel:new{
		ShieldFriendly = true,
		TipImage = {
			Unit = Point(2,4),
			Enemy = Point(1,2),
			Friendly = Point(3,2),
			Building1 = Point(2,1),
			Building2 = Point(2,2),
			Target = Point(2,2)
		}
}

Brute_Shrapnel_AB = Brute_Shrapnel_B:new{
		ShieldTarget = true,
}

--------------  Sonic Dash  ------------
	
Brute_Sonic = Brute_Sonic:new{
	SmokeLeft = false,
	SmokeRight = false,
	Limited = 1,
	PowerCost = 1,
	Upgrades = 2,
	UpgradeCost = {1,1},
	
}
			
function Brute_Sonic:GetTargetArea(point)
	local ret = PointList()
	local Pawn = Board:GetPawn(point)
	for i = DIR_START, DIR_END do
		for k = 1, 8 do
			local curr = DIR_VECTORS[i]*k + point
			if Board:IsValid(curr) and not Board:IsBlocked(curr, Pawn:GetPathProf()) then
				ret:push_back(curr)
			elseif Board:IsValid(curr) and Board:IsTerrain(curr,TERRAIN_HOLE) and Board:IsPawnSpace(curr) then
				break
			elseif Board:IsValid(curr) and Board:IsTerrain(curr,TERRAIN_HOLE) then
			--elseif Board:IsValid(curr) and Pawn:IsFlying() then
			else
				break
			end
		end
	end
	
	return ret
end

function Brute_Sonic:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local Pawn = Board:GetPawn(p1)
	local distance = p1:Manhattan(p2)  --target

	ret:AddCharge(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)
	
	for i = 0, distance do
		ret:AddDelay(0.06)
		ret:AddBounce(p1 + DIR_VECTORS[dir]*i, -3)

		local damagehind = SpaceDamage(p1 + DIR_VECTORS[dir]*(i-1), 0)
		damagehind.iSmoke = 1
		
		local damageleft = SpaceDamage(p1, 0)
		local damageright = SpaceDamage(p1, 0)

		if self.SmokeLeft then
			damageleft = SpaceDamage(p1 + DIR_VECTORS[dir]*i + DIR_VECTORS[(dir-1)%4], 0)
			damageleft.iSmoke = 1
		else
			damageleft = SpaceDamage(p1 + DIR_VECTORS[dir]*i + DIR_VECTORS[(dir-1)%4], 0, (dir-1)%4)
			damageleft.sAnimation = "exploout0_"..(dir-1)%4
		end

		if self.SmokeRight then
			damageright = SpaceDamage(p1 + DIR_VECTORS[dir]*i + DIR_VECTORS[(dir+1)%4], 0)
			damageright.iSmoke = 1
		else
			damageright = SpaceDamage(p1 + DIR_VECTORS[dir]*i + DIR_VECTORS[(dir+1)%4], 0, (dir+1)%4)
			damageright.sAnimation = "exploout0_"..(dir+1)%4
		end
		
		ret:AddDamage(damagehind)
		ret:AddDamage(damageleft)
		ret:AddDamage(damageright)
	end
	
	return ret
end

Brute_Sonic_A = Brute_Sonic:new{
		SmokeLeft = true,
}

Brute_Sonic_B = Brute_Sonic:new{
		SmokeRight = true,
}

Brute_Sonic_AB = Brute_Sonic:new{
		SmokeLeft = true,
		SmokeRight = true,
}

-------------- WallMech - Grapple  -----------------

--[[Brute_Grapple = {
	Class = "Brute",
	Rarity = 1,
	Icon = "weapons/brute_grapple.png",	
	Explosion = "",
	Shield = 0,
	ShieldFriendly = 0,
	HookTwo = false,
	Damage = 0,
	Range = RANGE_PROJECTILE,--TOOLTIP info
	Cost = "low",
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 1,2 },
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
	TwoClick = true,
	HookTwo = true,
	TipImage = {
		Unit = Point(2,2),
		Friendly = Point(1,0),
		Target = Point(0,2),
		Building = Point(0,2),
		Second_Click = Point(1,0),
	},
}

function Brute_Grapple_B:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	
	local grab = GetProjectileEnd(p1,p2)--target unit of first shot
	local dir = GetDirection(p2-p1)--direction vector of first shot
	local terminal = grab - DIR_VECTORS[dir]--endpoint of mech for stable target
	local front = p1 + DIR_VECTORS[dir]
	
	if Board:IsPawnSpace(grab) and not Board:GetPawn(grab):IsGuarding() then--target can be pulled in
		--DO TILE SEARCH
		for i = 1, 3 do
			local this_path = {}
			
			local target = p1 + DIR_VECTORS[(dir+i)%4]

			while not Board:IsBlocked(target, PATH_PROJECTILE) do
				this_path[#this_path+1] = target
				target = target + DIR_VECTORS[(dir+i)%4]
			end
			
			if Board:IsValid(target) and target:Manhattan(p1) > 1 then
				this_path[#this_path+1] = target
				for i,v in ipairs(this_path) do 
					ret:push_back(v)
				end
			end
		end
		--Check if target would die and vanish when pulled to that square and search for target behind
		if (((Board:GetItem(front) == "Item_Mine" and (not (Board:GetPawn(grab)):IsMech()))) or
		(Board:IsTerrain(front, TERRAIN_HOLE) and ((not (Board:GetPawn(grab)):IsFlying()) or (Board:GetPawn(grab)):IsFrozen())) or
		(Board:IsTerrain(front, TERRAIN_WATER) and ((not _G[Board:GetPawn(grab):GetType()].Massive) and (((not (Board:GetPawn(grab)):IsFlying())) or (Board:GetPawn(grab)):IsFrozen()))))
		then
			local that_path = {}
			
			local target = front

			while not Board:IsBlocked(target, PATH_PROJECTILE) do
				if p2 ~= target then
					that_path[#that_path+1] = target
				end
				target = target + DIR_VECTORS[dir]
				if target == GetProjectileEnd(p1, front) then
					target = target + DIR_VECTORS[dir]
				end
			end
			
			if Board:IsValid(target) and target:Manhattan(p1) > 1 then
				that_path[#that_path+1] = target
				for i,v in ipairs(that_path) do 
					ret:push_back(v)
				end
			end
		end
	elseif Board:IsBlocked(grab, Pawn:GetPathProf()) then--target is stable
			--DO TILE SEARCH
			for i = 1, 3 do
				local this_path = {}
				
				local target = terminal + DIR_VECTORS[(dir+i)%4]

				while not Board:IsBlocked(target, PATH_PROJECTILE) do
					this_path[#this_path+1] = target
					target = target + DIR_VECTORS[(dir+i)%4]
					if p1 == target then target = target + DIR_VECTORS[(dir+i)%4] end
				end
				
				if Board:IsValid(target) and target:Manhattan(terminal) > 1 then
					this_path[#this_path+1] = target
					for i,v in ipairs(this_path) do 
						ret:push_back(v)
					end
				end
			end
			--repeating this section to also get the tiles in the other direction to the first hook
			local that_path = {}
			local backtarget = p1 - DIR_VECTORS[dir]
			while not Board:IsBlocked(backtarget, PATH_PROJECTILE) do
				that_path[#that_path+1] = backtarget
				backtarget = backtarget - DIR_VECTORS[dir]
			end
			
			if Board:IsValid(backtarget) then
				that_path[#that_path+1] = backtarget
				for i,v in ipairs(that_path) do 
					ret:push_back(v)
				end
			end
		--end
	end
	if ret:size() > 0 then ret:push_back(p1) end
	return ret
end

function Brute_Grapple_B:IsTwoClickException(p1,p2)
	if (self:GetSecondTargetArea(p1,p2)):size() == 0 then
		return true
	end
	return false
end

function Brute_Grapple_B:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()

	local direction = GetDirection(p2 - p1)

	local front = p1 + DIR_VECTORS[direction]

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
	
	--ret:AddDelay(FULL_DELAY)
	--ret:AddDelay(0.3)
	if p3 == p1 then return ret end
	ret:AddSound(self.LaunchSound)
	--Second Grapple
	local terminal = Point(-1,-1)
	
	if Board:IsPawnSpace(target) and not Board:GetPawn(target):IsGuarding() then
		terminal = p1
	elseif Board:IsBlocked(target, Pawn:GetPathProf()) then--check if mech has moved and define location accordingly
		terminal = target - DIR_VECTORS[direction]--endpoint of mech for stable target
	end
	
	direction = GetDirection(p3 - terminal)--direction of second grapple
	target = terminal + DIR_VECTORS[direction]
	
	if p1 == GetProjectileEnd(terminal, target) then--case where the two grapples are fired in opposite directions and the first one struck a stable target
		target = p1 + DIR_VECTORS[direction]
	end
	
	if GetProjectileEnd(p1,p2) == GetProjectileEnd(terminal, target) then--case where the two grapples are fired in the same direction and the first target died
		target = GetProjectileEnd(p1,p2) + DIR_VECTORS[direction]
	end
	
	while not Board:IsBlocked(target, PATH_PROJECTILE) do
		target = target + DIR_VECTORS[direction]
	end
	
	if not Board:IsValid(target) then
		return ret
	end
	
	local damage2 = SpaceDamage(target)
	damage2.bHidePath = true
	ret:AddProjectile(terminal,damage2,"effects/shot_grapple")
	
	if Board:IsPawnSpace(target) and not Board:GetPawn(target):IsGuarding() then	-- If it's a pawn

		ret:AddCharge(Board:GetPath(target, terminal + DIR_VECTORS[direction], PATH_FLYER), FULL_DELAY)

		if Board:IsPawnTeam(target, TEAM_PLAYER) then
			local shielddamage = SpaceDamage(terminal + DIR_VECTORS[direction],0)
			shielddamage.iShield = self.ShieldFriendly
			ret:AddDamage(shielddamage)
		end
	elseif Board:IsBlocked(target, Pawn:GetPathProf()) then     --If it's an obstruction
		ret:AddCharge(Board:GetPath(terminal, target - DIR_VECTORS[direction], PATH_FLYER), FULL_DELAY)	
		if Board:IsBuilding(target) or Board:IsPawnTeam(target, TEAM_PLAYER) then
			local spaceDamage = SpaceDamage(target)
			spaceDamage.iShield = self.ShieldFriendly
			ret:AddDamage(spaceDamage)
		end
	end
	return ret
end

Brute_Grapple_AB = Brute_Grapple_B:new{
	ShieldFriendly = 1,
}]]

-------------- MirrorMech - Mirror Cannon  ------------

Brute_Mirrorshot = Skill:new{
	Class = "Brute",
	Icon = "weapons/brute_mirror.png",
	Sound = "/general/combat/explode_small",
	Damage = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {1,3},
	ProjectileArt = "effects/shot_mechtank",
	LaunchSound = "/weapons/mirror_shot",
	ImpactSound = "/impact/generic/explosion",
	Explo = "explopush1_",
	TurnSound = "/weapons/bomb_strafe",
	ZoneTargeting = ZONE_DIR,
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(1,2),
		Enemy2 = Point(4,2),
		Target = Point(1,2)
	}
}

function Brute_Mirrorshot:GetTargetArea(p1)
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

function Brute_Mirrorshot:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local undirection = GetDirection(p1 - p2)
	local target = GetProjectileEnd(p1,p2,PATH_PROJECTILE)  
	
	local damage = SpaceDamage(target, self.Damage, direction)
	damage.sAnimation = self.Explo..direction
	
	ret:AddProjectile(damage, self.ProjectileArt, NO_DELAY)
	--backshot
	local target2 = GetProjectileEnd(p1,p1 - DIR_VECTORS[direction])

	if target2 ~= p1 then
		damage = SpaceDamage(target2, self.Damage, undirection)
		damage.sAnimation = self.Explo..undirection
		ret:AddProjectile(damage,self.ProjectileArt)
	end
	return ret
end

Brute_Mirrorshot_A = Skill:new{ 
	Icon = "weapons/brute_mirror.png",
	Class = "Brute",
	TwoClick = true, 
	PathSize = INT_MAX,
	ProjectileArt = "effects/shot_mechtank",
	LaunchSound = "/weapons/mirror_shot",
	Exploart = "explopush1_",
	ImpactSound = "/impact/generic/explosion",
	TurnSound = "/weapons/bomb_strafe",
	Damage = 1,
	TipImage = {
		Unit = Point(2,3),
		Enemy1 = Point(1,1),
		Enemy2 = Point(3,2),
		Target = Point(1,3),
		Second_Click = Point(1,1),
	}
}

function Brute_Mirrorshot_A:GetTargetArea(p1)
	--This new target style doesn't let you select a unit, only empty tiles.
	local ret = PointList()

	for dir = DIR_START, DIR_END do
		for i = 1, 8 do
			local curr = Point(p1 + DIR_VECTORS[dir] * i)
			if not Board:IsValid(curr) then
				break
			end
		
			ret:push_back(curr)  --Normally, this would go before the if statement above.
			
			if Board:IsBlocked(curr,PATH_PROJECTILE) then
				break
			end
		end
	end

	return ret
	
end

function Brute_Mirrorshot_A:IsTwoClickException(p1,p2)
	if Board:IsBlocked(p2, PATH_PROJECTILE) then
		return true
	end
	
	return false
end

function Brute_Mirrorshot_A:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local backdir = GetDirection(p1 - p2)
	local backtarget = GetProjectileEnd(p1,p1 + DIR_VECTORS[backdir])
	local distance = p1:Manhattan(p2)
	local opposite = p1 + DIR_VECTORS[backdir]*distance
	if Board:IsBlocked(p2, PATH_PROJECTILE) then
		-- create main attack
		local damage = SpaceDamage(p2, self.Damage, dir)
		damage.sAnimation = self.Exploart..dir
		ret:AddProjectile(damage, self.ProjectileArt, NO_DELAY)
		-- create backshot
		if backtarget ~= p1 then
			local backdamage = SpaceDamage(backtarget, self.Damage, backdir)
			backdamage.sAnimation = self.Exploart..backdir
			ret:AddProjectile(backdamage, self.ProjectileArt, NO_DELAY)
		end
	else
		-- create pre-turn attack
		local damage = SpaceDamage(p2, 0)
		damage.sSound = self.TurnSound
		ret:AddProjectile(damage, self.ProjectileArt, NO_DELAY)
		-- create backshot
		if backtarget ~= p1 then
			if (p1:Manhattan(backtarget)<p1:Manhattan(opposite)) or Board:IsBlocked(opposite, PATH_PROJECTILE) then
			-- case 1: backshot collides before it turns
				local backdamage = SpaceDamage(backtarget, self.Damage, backdir)
				backdamage.sAnimation = self.Exploart..backdir
				ret:AddProjectile(backdamage, self.ProjectileArt, NO_DELAY)
			else-- case 2: backshot is able to turn
				local backdamage = SpaceDamage(opposite, 0)
				damage.sSound = self.TurnSound
				ret:AddProjectile(backdamage, self.ProjectileArt, NO_DELAY)
			end
		end
		
	end
	return ret
end

function Brute_Mirrorshot_A:GetSecondTargetArea(p1,p2)
-- Force you to target left or right for your click#1 - it then moves like a tankshot
	if Board:IsBlocked(p2, PATH_PROJECTILE) then
		return PointList()
	end
	
	local ret = TankDefault:GetTargetArea(p2)  --Changed this to the tank shot style
	self:RemoveBackwards(ret,p1,p2)
	self:RemoveForwards(ret,p1,p2)  --added this as well
	return ret
end

function Brute_Mirrorshot_A:GetFinalEffect(p1,p2,p3)
	
	local target = GetProjectileEnd(p2,p3,PATH_PROJECTILE)
	
	local ret = self:GetSkillEffect(p1,p2)
	local direction = GetDirection(p3-p2)
	local backdir = GetDirection(p1-p2)
	local backtarget = GetProjectileEnd(p1,p1 + DIR_VECTORS[backdir])
	local reverse_dir = ((direction + 2) % 4)
	local distance = p1:Manhattan(p2)
	local opposite = p1 + DIR_VECTORS[backdir]*distance
	local opp_turn = opposite + DIR_VECTORS[direction]
	ret:AddDelay(distance*0.1)
	
	local damagepush = SpaceDamage(p2,0)  --smoke when it turns
	damagepush.sAnimation = "airpush_"..reverse_dir
	ret:AddDamage(damagepush)
	
	local final_damage = SpaceDamage(target,self.Damage,direction)
	final_damage.sAnimation = self.Exploart..direction
	final_damage.sSound = "/impact/generic/explosion"
	ret:AddProjectile(p2, final_damage, self.ProjectileArt, NO_DELAY)
	
	if (not Board:IsBlocked(opposite, PATH_PROJECTILE)) and (backtarget ~= p1) and (not (p1:Manhattan(backtarget)<p1:Manhattan(opposite))) then
		-- create second turning shot
		opp_target = GetProjectileEnd(opposite,opp_turn,PATH_PROJECTILE)
		
		local opp_damagepush = SpaceDamage(opposite,0)  --smoke when it turns
		opp_damagepush.sAnimation = "airpush_"..reverse_dir
		ret:AddDamage(opp_damagepush)
		
		local opp_final_damage = SpaceDamage(opp_target,self.Damage,direction)
		opp_final_damage.sAnimation = self.Exploart..direction
		opp_final_damage.sSound = "/impact/generic/explosion"
		ret:AddProjectile(opposite, opp_final_damage, self.ProjectileArt, NO_DELAY)
	end
	return ret
end

Brute_Mirrorshot_B = Brute_Mirrorshot:new{
	Damage = 2,
}

Brute_Mirrorshot_AB = Brute_Mirrorshot_A:new{
	Damage = 2,
}

--------------Brute Doubleshot -------------

Brute_TC_DoubleShot = TankDefault:new{
	Icon = "advanced/weapons/Brute_TC_DoubleShot.png",
	LaunchSound = "/weapons/doubleshot",
	ImpactSound = "/impact/generic/explosion",
	ProjectileArt = "effects/shot_quickfire",
	Exploart = "explopush1_",
	Class = "Brute",
	TwoClick = true,
	ZoneTargeting = DIR,
	Damage = 1,
	Push = 1,
	Backburn = false,
	Upgrades = 2,
	UpgradeCost = {2,3},
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Enemy2 = Point(3,3),
		Target = Point(2,1),
		Second_Click = Point(3,3),
	}
}

function Brute_TC_DoubleShot:GetSecondTargetArea(p1,p2)
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

function Brute_TC_DoubleShot:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	
	local pathing = self.Phase and PATH_PHASING or PATH_PROJECTILE
	local target1 = GetProjectileEnd(p1,p2,pathing)  
	
	ret:AddBounce(p1,3)
	
	local damage = SpaceDamage(target1, self.Damage)
	if self.Push == 1 then
		damage.iPush = dir
	end
	damage.iAcid = self.Acid
	damage.iFrozen = self.Freeze
	damage.iShield = self.Shield
	damage.sAnimation = self.Exploart..dir
	
	ret:AddProjectile(damage, self.ProjectileArt, NO_DELAY)
	
	if self.Backburn then
		local back1 = SpaceDamage(p1 - DIR_VECTORS[dir], 0)
		back1.iFire = 1
		ret:AddDamage(back1)
	end
	
	dir = GetDirection(p3-p1)
	local target2 = GetProjectileEnd(p1,p3,pathing)  
	 damage = SpaceDamage(target2, self.Damage)
	if self.Push == 1 then
		damage.iPush = dir
	end
	damage.sAnimation = self.Exploart..dir
	ret:AddProjectile(damage, self.ProjectileArt, NO_DELAY)
	
	if self.Backburn then
		local back2 = SpaceDamage(p1 - DIR_VECTORS[dir], 0)
		back2.iFire = 1
		ret:AddDamage(back2)
	end
	
	return ret
end

Brute_TC_DoubleShot_A = Brute_TC_DoubleShot:new{
	Backburn = true,
}
Brute_TC_DoubleShot_B = Brute_TC_DoubleShot:new{
	Damage = 2,
	Exploart = "explopush2_",
}
Brute_TC_DoubleShot_AB = Brute_TC_DoubleShot:new{
	Backburn = true,
	Damage = 2,
	Exploart = "explopush2_",
}

------------------------------- Guided Missile --------------------------

Brute_TC_GuidedMissile = Skill:new{ 
	Icon = "advanced/weapons/Brute_TC_GuidedMissile.png",
	Class = "Brute",
	TwoClick = true, 
	PathSize = INT_MAX,
	ProjectileArt = "effects/shot_smokerocket",
	LaunchSound = "/weapons/modified_cannons",
	Exploart = "explopush1_",
	ImpactSound = "",
	TurnSound = "/weapons/bomb_strafe",
	PowerCost = 1,
	Damage = 2,
	SmokeA = false,
	SmokeB = false,
	Upgrades = 2,
	UpgradeCost = {2, 1},
	TipImage = {
		Unit = Point(1,3),
		Enemy2 = Point(3,1),
		Target = Point(1,1),
		Second_Click = Point(3,1),
	}
}

function Brute_TC_GuidedMissile:GetTargetArea(p1)
	--This new target style doesn't let you select a unit, only empty tiles.
	local ret = PointList()

	for dir = DIR_START, DIR_END do
		for i = 1, 8 do
			local curr = Point(p1 + DIR_VECTORS[dir] * i)
			if not Board:IsValid(curr) then
				break
			end
		
			ret:push_back(curr)  --Normally, this would go before the if statement above.
			
			if Board:IsBlocked(curr,PATH_PROJECTILE) then
				break
			end
		end
	end

	return ret
	
end

function Brute_TC_GuidedMissile:IsTwoClickException(p1,p2)
	if Board:IsBlocked(p2, PATH_PROJECTILE) then
		return true
	end
	
	return false
end

function Brute_TC_GuidedMissile:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	if Board:IsBlocked(p2, PATH_PROJECTILE) then
		local damage = SpaceDamage(p2, self.Damage, dir)
		damage.sAnimation = self.Exploart..dir
		ret:AddProjectile(damage, self.ProjectileArt, NO_DELAY)
	else
		local damage = SpaceDamage(p2 + DIR_VECTORS[dir], 0)
		damage.sSound = self.TurnSound
		ret:AddProjectile(damage, self.ProjectileArt, NO_DELAY)
	end
	
	if self.SmokeA then
		local point = p1 + DIR_VECTORS[dir]
		local damage = SpaceDamage(point,0)
		damage.iSmoke = 1
		while p2 ~= point do 
			--ret:AddBounce(target, 1)
			ret:AddDelay(0.1)
			damage.loc = point
			ret:AddDamage(damage)
			point = point + DIR_VECTORS[dir]
		end 
	end
	
	ret:AddDelay(FULL_DELAY)
	
	return ret
end

function Brute_TC_GuidedMissile:GetSecondTargetArea(p1,p2)
-- Force you to target left or right for your click#1 - it then moves like a tankshot
	if Board:IsBlocked(p2, PATH_PROJECTILE) then
		return PointList()
	end
	
	local ret = TankDefault:GetTargetArea(p2)  --Changed this to the tank shot style
	self:RemoveBackwards(ret,p1,p2)
	self:RemoveForwards(ret,p1,p2)  --added this as well
	return ret
end

function Brute_TC_GuidedMissile:GetFinalEffect(p1,p2,p3)
	local target = GetProjectileEnd(p2,p3,PATH_PROJECTILE)
	local ret = self:GetSkillEffect(p1,p2)
	local direction = GetDirection(p3-p2)
	local reverse_dir = ((direction + 2) % 4)
	
	
	local damagepush = SpaceDamage(p2,0)  --smoke when it turns
	damagepush.sAnimation = "airpush_"..reverse_dir
	ret:AddDamage(damagepush)
	
	local final_damage = SpaceDamage(target,self.Damage,direction)
	final_damage.sAnimation = self.Exploart..direction
	final_damage.sSound = "/impact/generic/explosion"
	ret:AddProjectile(p2, final_damage, self.ProjectileArt, NO_DELAY)
		
	if self.SmokeB then
		local point = p2
		local damage = SpaceDamage(point,0)
		damage.iSmoke = 1
		while target ~= point do 
			--ret:AddBounce(target, 1)
			ret:AddDelay(0.1)
			damage.loc = point
			ret:AddDamage(damage)
			point = point + DIR_VECTORS[direction]
		end 
	end
	return ret
end


Brute_TC_GuidedMissile_A = Brute_TC_GuidedMissile:new{
	SmokeA = true,
	Exploart = "explopush2_",
}

Brute_TC_GuidedMissile_B = Brute_TC_GuidedMissile:new{
	SmokeB = true,
}

Brute_TC_GuidedMissile_AB = Brute_TC_GuidedMissile:new{
	SmokeA = true,
	SmokeB = true,
	Exploart = "explopush2_",
}

-------------- Ricochet --------------------------

Brute_TC_Ricochet = TankDefault:new{ 
	Icon = "advanced/weapons/Brute_TC_Ricochet.png",
	Class = "Brute",
	LaunchSound = "/weapons/modified_cannons",
	Exploart = "explopush1_",
	TurnSound = "/weapons/bomb_strafe",
	ImpactSound = "",
	TwoClick = true,
	Anywhere = false,
--	ZoneTargeting = ZONE_DIR,
	Damage = 1,
	ZoneTargeting = ZONE_DIR,
	BuildingDamage = true,
	AllyDamage = true,
	Upgrades = 2,
	UpgradeCost = {3, 2},
	TipImage = {
		Unit = Point(1,3),
		Enemy = Point(1,1),
		Enemy2 = Point(3,1),
		Target = Point(1,1),
		Second_Click = Point(3,1),
	}
}

function Brute_TC_Ricochet:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)

	local target = GetProjectileEnd(p1,p2,PATH_PROJECTILE)  
	local damage = SpaceDamage(target, self.Damage, direction)
	if not self.AllyDamage and Board:IsPawnTeam(target, TEAM_PLAYER) then damage.iDamage = DAMAGE_ZERO 	end 
	--if not self.BuildingDamage and Board:IsBuilding(target) then	damage.iDamage = DAMAGE_ZERO 	end 
	damage.sSound = "/impact/generic/ricochet"
	ret:AddProjectile(damage, self.ProjectileArt, NO_DELAY)--"effects/shot_mechtank")
		
	return ret
end

function Brute_TC_Ricochet:GetSecondTargetArea(p1, p2)
	local direction = GetDirection(p2 - p1)
	local ret = PointList()
	local target = GetProjectileEnd(p1,p2,PATH_PROJECTILE)  
	local dirs = {(direction + 1) % 4, (direction - 1) % 4}
	local dars = {direction, (direction+2)%4}
	
	for j, dir in ipairs(dirs) do
		for i = 1, 8 do
			local curr = Point(target + DIR_VECTORS[dir] * i)
			if not Board:IsValid(curr) then
				break
			end
			ret:push_back(curr)
			if self.Anywhere then
				for k, dar in ipairs(dars) do
					for z = 1, 8 do
						local corr = Point(curr + DIR_VECTORS[dar] * z)
						if not Board:IsValid(corr) then
							break
						end
						ret:push_back(corr)
						if Board:IsBlocked(corr,PATH_PROJECTILE) then
							break
						end
					end
				end
			end
			if Board:IsBlocked(curr,PATH_PROJECTILE) then
				break
			end
		end
	end
	
	return ret	
end

--this is only used for touch controls, customizing what counts as the same "group" for targeting purposes
function Brute_TC_Ricochet:GetSecondTargetZone(points)	
	local origin = points:index(1)
	local p1 = points:index(2)
	local p2 = points:index(3)
	
	local targets = self:GetSecondTargetArea(origin, p1)
	local ret = PointList()
		
	local dir = GetDirection(p2-p1)
	for i = 1, targets:size() do
		if GetDirection(targets:index(i) - p1) == dir then
			ret:push_back(targets:index(i))
		end
	end

	return ret
end

function Brute_TC_Ricochet:TranslateFirstClick(p1, p2)
	return GetProjectileEnd(p1,p2,PATH_PROJECTILE)  
end

--strange ordering of events needed to make sure the projectile bounces immediately and isn't delayed
--by the push animation. WHY ISN'T THIS NEEDED FOR ARTILLERY PROJECTILES!?
function Brute_TC_Ricochet:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()
	local first_dir = GetDirection(p2 - p1)
	local first_tar = GetProjectileEnd(p1,p2,PATH_PROJECTILE)  

	local second_dir = GetDirection(p3 - p2)
	local second_tar = GetProjectileEnd(p2,p3,PATH_PROJECTILE)  
	
	local pushdam = SpaceDamage(p1,0)
	pushdam.sAnimation = "airpush_"..(first_dir+2)%4
	ret:AddDamage(pushdam)
	
	ret:AddProjectile(SpaceDamage(first_tar), self.ProjectileArt)
	
	if first_tar.x == p3.x or first_tar.y == p3.y then
		if Board:IsValid(p3) then
			local damage = SpaceDamage(second_tar,self.Damage,second_dir)
			damage.sSound = "/impact/generic/explosion"
			damage.sAnimation = self.Exploart..second_dir
			if not self.AllyDamage and Board:IsPawnTeam(second_tar, TEAM_PLAYER) then 
				damage.iDamage = DAMAGE_ZERO 	
				damage.sAnimation = "airpush_"..second_dir
			end 
			--if not self.BuildingDamage and Board:IsBuilding(second_tar) then	damage.iDamage = DAMAGE_ZERO 	end 
			ret:AddProjectile(p2, damage, self.ProjectileArt, NO_DELAY)
		end
		
		local damage = SpaceDamage(first_tar, self.Damage, first_dir)
		damage.sSound = "/impact/generic/ricochet"
		damage.sAnimation = self.Exploart..first_dir
		if not self.AllyDamage and Board:IsPawnTeam(first_tar, TEAM_PLAYER) then 
			damage.iDamage = DAMAGE_ZERO 	
			damage.sAnimation = "airpush_"..first_dir
		end 
		--if not self.BuildingDamage and Board:IsBuilding(first_tar) then	damage.iDamage = DAMAGE_ZERO 	end 
		ret:AddDamage(damage)
	else
		local turn_point = Point(-1,-1)
		if first_dir%2 == 0 then
			turn_point = Point(p3.x,first_tar.y)
		else
			turn_point = Point(first_tar.x,p3.y)
		end
		
		local turn_dir = GetDirection(p3 - turn_point)
		local third_tar = GetProjectileEnd(turn_point,p3)

		-- damage and push first target
		local damage = SpaceDamage(first_tar, self.Damage, first_dir)
		damage.sSound = "/impact/generic/ricochet"
		damage.sAnimation = self.Exploart..first_dir
		if not self.AllyDamage and Board:IsPawnTeam(first_tar, TEAM_PLAYER) then 
			damage.iDamage = DAMAGE_ZERO 	
			damage.sAnimation = "airpush_"..first_dir
		end 
		ret:AddDamage(damage)
		if Board:IsBlocked(turn_point,PATH_PROJECTILE) then
			-- second ricochet
			local damage = SpaceDamage(turn_point, self.Damage, GetDirection(turn_point - first_tar))
			damage.sSound = "/impact/generic/ricochet"
			damage.sAnimation = self.Exploart..GetDirection(turn_point - first_tar)
			if not self.AllyDamage and Board:IsPawnTeam(turn_point, TEAM_PLAYER) then 
				damage.iDamage = DAMAGE_ZERO 	
				damage.sAnimation = "airpush_"..GetDirection(turn_point - first_tar)
			end 
			ret:AddProjectile(first_tar, damage, self.ProjectileArt, first_tar:Manhattan(turn_point)*0.1)
		else
			-- turning animation
			local damage = SpaceDamage(turn_point, 0)
			damage.sSound = self.TurnSound
			ret:AddProjectile(first_tar, damage, self.ProjectileArt, first_tar:Manhattan(turn_point)*0.1)
			local damagepush = SpaceDamage(turn_point,0)  --smoke when it turns
			damagepush.sAnimation = "airpush_"..(turn_dir+2)%4
			ret:AddDamage(damagepush)
		end	
		-- damage and push final target
		local final_damage = SpaceDamage(third_tar,self.Damage,turn_dir)
		final_damage.sAnimation = self.Exploart..turn_dir
		final_damage.sSound = "/impact/generic/explosion"
		ret:AddProjectile(turn_point, final_damage, self.ProjectileArt, NO_DELAY)
	
	end
	
	return ret
end

Brute_TC_Ricochet_A = Brute_TC_Ricochet:new{
	Damage = 2, 
	Exploart = "explopush2_",
}

Brute_TC_Ricochet_B = Brute_TC_Ricochet:new{
	Anywhere = true,
	TipImage = {
		Unit = Point(1,3),
		Enemy1 = Point(1,1),
		Enemy2 = Point(3,1),
		Enemy3 = Point(3,3),
		Target = Point(1,1),
		Second_Click = Point(3,2),
	}
}

Brute_TC_Ricochet_AB = Brute_TC_Ricochet:new{
	Damage = 2, 
	Exploart = "explopush2_",
	Anywhere = true,
	TipImage = {
		Unit = Point(1,3),
		Enemy1 = Point(1,1),
		Enemy2 = Point(3,1),
		Enemy3 = Point(3,3),
		Target = Point(1,1),
		Second_Click = Point(3,2),
	}
}
