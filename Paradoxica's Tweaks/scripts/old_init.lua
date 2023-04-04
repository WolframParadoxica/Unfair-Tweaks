local mod = {
	id = "Unfair_Tweaks",
	name = "Unfair Tweaks",
	version = "0.5",
	requirements = {},
	dependencies = { --This requests modApiExt from the mod loader
		modApiExt = "1.18", --We can get this by using the variable `modapiext`
	},
	modApiVersion = "2.9.1",
	--icon = "img/mod_icon.png"
}

local function init(self)
    require(self.scriptPath.."weapons_prime")
    require(self.scriptPath.."weapons_brute")
    require(self.scriptPath.."weapons_ranged")
    require(self.scriptPath.."weapons_science")
    require(self.scriptPath.."weapons_passive")
    require(self.scriptPath.."weapons_support")
    require(self.scriptPath.."weapons_deploy")
    require(self.scriptPath.."weapons_technovek")	
    require(self.scriptPath.."pawns")
	require(self.scriptPath.."Dam")
	require(self.scriptPath.."Train")
	require(self.scriptPath.."pilots")
	require(self.scriptPath.."ae_pilots")
	require(self.scriptPath.."Prospero_Crack")
	require(self.scriptPath.."Gana_Shield")
end

function load(self, options, version)
--Prime
	modApi:setText("Prime_Rockmech_Description", "Throw a rock at a chosen target. Rock remains as an obstacle. Single-use.")
	modApi:setText("Prime_Rockmech_Upgrade1", "More Rocks")
	modApi:setText("Prime_Rockmech_A_UpgradeDescription", "If colliding with a target, spawn rocks on empty adjacent tiles.")
	modApi:setText("Prime_Rockmech_Upgrade2", "+1 Use")
	modApi:setText("Prime_Rockmech_B_UpgradeDescription", "Increases uses per battle by 1.")
	
	modApi:setText("Prime_RightHook_Description", "Punch an adjacent tile, damaging and pushing it to the left or right.")
	modApi:setText("Prime_RightHook_Upgrade1", "Impact")
	modApi:setText("Prime_RightHook_A_UpgradeDescription", "Launch the target any distance in a line.")
	modApi:setText("Prime_RightHook_Upgrade2", "+2 Damage")
	modApi:setText("Prime_RightHook_B_UpgradeDescription", "Increases damage by 2.")
	
	modApi:setText("Prime_Lasermech_Upgrade1", "+1 Damage")
	modApi:setText("Prime_Lasermech_A_UpgradeDescription", "Increases the starting damage by 1.")
	modApi:setText("Prime_Lasermech_Upgrade2", "Damage & Ally Immune")
	modApi:setText("Prime_Lasermech_B_UpgradeDescription", "Increases the starting damage by 1 and no longer damages friendly units.")
	
	modApi:setText("Prime_Shift_Upgrade1", "+2 Range")
	modApi:setText("Prime_Shift_A_UpgradeDescription", "Increases the range of the toss by 2.")
	modApi:setText("Prime_Shift_Upgrade2", "+1 Damage")
	modApi:setText("Prime_Shift_B_UpgradeDescription", "Increases damage by 1.")
	
	modApi:setText("Prime_Flamethrower_Upgrade2", "+1 Range, Add Flip")
	modApi:setText("Prime_Flamethrower_B_UpgradeDescription", "Extends flamethrower range by 1 tile. Flip all intermediate tiles.")
	
	modApi:setText("Prime_SpinFist_Description", "Damage and push all adjacent tiles to the left or right.")
	modApi:setText("Prime_SpinFist_Upgrade1", "Halt")
	modApi:setText("Prime_SpinFist_A_UpgradeDescription", "Avoids pushing targets into buildings and non-Mech allies.")
	
	modApi:setText("Prime_ShieldBash_Description", "Bash the enemy, flipping its attack direction, and shield self.")
	modApi:setText("Prime_ShieldBash_Upgrade1", "Diagonal Strike")
	modApi:setText("Prime_ShieldBash_A_UpgradeDescription", "Target diagonally adjacent squares.")
	modApi:setText("Prime_ShieldBash_Upgrade2", "+1 Damage, Double Strike")
	modApi:setText("Prime_ShieldBash_B_UpgradeDescription", "Increases damage by 1. Bash a second target.")
	
	modApi:setText("Prime_Spear_Description", "Stab multiple tiles and push the furthest hit tile. Flip all intermediate tiles.")
	
	modApi:setText("Prime_Flamespreader_Upgrade2", "Add Fire, Flip")
	modApi:setText("Prime_Flamespreader_B_UpgradeDescription", "Add fire and flip attacks on all hit tiles.")
	
	modApi:setText("Prime_WayTooBig_Upgrade1", "Building Immune")
	modApi:setText("Prime_WayTooBig_A_UpgradeDescription", "This attack will no longer damage Grid Buildings.")
	modApi:setText("Prime_WayTooBig_Upgrade2", "Add Flip")
	modApi:setText("Prime_WayTooBig_B_UpgradeDescription", "Flips all enemies hit.")
--Brute
	modApi:setText("Brute_Jetmech_Upgrade1", "Range & Damage")
	modApi:setText("Brute_Jetmech_A_UpgradeDescription", "Increases potential hit tiles by 1 and damage on all tiles by 1.")
	modApi:setText("Brute_Jetmech_Upgrade2", "Range & Damage")
	modApi:setText("Brute_Jetmech_B_UpgradeDescription", "Increases potential hit tiles by 1 and damage on all tiles by 1.")
	
	modApi:setText("Brute_Beetle_Description", "Fly in a line and slam into the target, pushing it, and then push self forward.")
	modApi:setText("Brute_Beetle_A_UpgradeDescription", "Increases damage by 1 and damages self.")
	
	modApi:setText("Brute_Shrapnel_Upgrade1", "Shield Target")
	modApi:setText("Brute_Shrapnel_A_UpgradeDescription", "Shields the target.")
	modApi:setText("Brute_Shrapnel_Upgrade2", "Shield Friendly")
	modApi:setText("Brute_Shrapnel_B_UpgradeDescription", "Shields allied units and buildings around target.")
	
	modApi:setText("Brute_Sonic_Description", "Dash in a line, pushing adjacent tiles away and smoking all tiles behind self. Single-use.")
	modApi:setText("Brute_Sonic_Upgrade1", "Smoke Left")
	modApi:setText("Brute_Sonic_A_UpgradeDescription", "Smokes the left side of the trail instead of pushing.")
	modApi:setText("Brute_Sonic_Upgrade2", "Smoke Right")
	modApi:setText("Brute_Sonic_B_UpgradeDescription", "Smokes the right side of the trail instead of pushing.")

	modApi:setText("Brute_Grapple_Upgrade1", "Shield Friendly")
	modApi:setText("Brute_Grapple_A_UpgradeDescription", "If used on an ally or building, gives them a shield.")
	modApi:setText("Brute_Grapple_Upgrade2", "2 Hooks")
	modApi:setText("Brute_Grapple_B_UpgradeDescription", "Gain the option to grapple a second target.")
	
	modApi:setText("Brute_Mirrorshot_Upgrade1", "Manoeuvrable")
	modApi:setText("Brute_Mirrorshot_A_UpgradeDescription", "Projectiles can now turn once in the same direction before hitting their targets.")
	
	modApi:setText("Brute_TC_DoubleShot_Description", "Fire two pushing projectiles in different directions.")
	modApi:setText("Brute_TC_DoubleShot_Upgrade1", "Backburn")
	modApi:setText("Brute_TC_DoubleShot_A_UpgradeDescription", "Light the tiles behind the mech on fire.")
	
	modApi:setText("Brute_TC_GuidedMissile_Upgrade1", "Smoke Trail")
	modApi:setText("Brute_TC_GuidedMissile_A_UpgradeDescription", "Before turning, adds Smoke to each tile passed through.")

	modApi:setText("Brute_TC_Ricochet_Upgrade2", "Rebound")
	modApi:setText("Brute_TC_Ricochet_B_UpgradeDescription", "Bounce a second time, or turn once after bouncing.")
--Ranged
	modApi:setText("Ranged_Rocket_Upgrade1", "Redirect Exhaust")
	modApi:setText("Ranged_Rocket_A_UpgradeDescription", "Smoke any adjacent tile.")
	modApi:setText("Ranged_Rocket_Upgrade2", "+2 Damage")
	modApi:setText("Ranged_Rocket_B_UpgradeDescription", "Increases damage by 2.")
	
	modApi:setText("Ranged_Rockthrow_Upgrade2", "2 Rocks")
	modApi:setText("Ranged_Rockthrow_B_UpgradeDescription", "Fire a second rock in a different direction.")
	
	modApi:setText("Ranged_Ignite_Upgrade1", "Sideburn")
	modApi:setText("Ranged_Ignite_A_UpgradeDescription", "Light any adjacent tile on fire.")
	
	modApi:setText("Ranged_Ice_Upgrade1", "Cluster Strike")
	modApi:setText("Ranged_Ice_A_UpgradeDescription", "Gain the option to increase the area of effect by 1 tile, damaging, freezing and shielding self.")
	
	modApi:setText("Ranged_Fireball_Upgrade2", "Add Push")
	modApi:setText("Ranged_Fireball_B_UpgradeDescription", "Pushes all tiles adjacent to target.")
	
	modApi:setText("Ranged_Arachnoid_Description", "Damage target, creating a web-immune friendly robot spider on kill.")
	modApi:setText("Ranged_Arachnoid_Upgrade1", "+2 Damage")
	modApi:setText("Ranged_Arachnoid_A_UpgradeDescription", "Increases the artillery attack damage by 2.")
	
	modApi:setText("Ranged_TC_BounceShot_Upgrade2", "Ricochet")
	modApi:setText("Ranged_TC_BounceShot_B_UpgradeDescription", "Bounce to a second target perpendicular to the first.")
--Science
	modApi:setText("Science_Pullmech_Upgrade1", "Beam")
	modApi:setText("Science_Pullmech_A_UpgradeDescription", "Pulls all units in a line.")
	
	modApi:setText("Science_Gravwell_Upgrade1", "Double Shot")
	modApi:setText("Science_Gravwell_A_UpgradeDescription", "Fire a second shot.")
	
	modApi:setText("Science_Repulse_Description", "Push four tiles at any distance.")
	modApi:setText("Science_Repulse_B_UpgradeDescription", "Shield adjacent ally or building.")
	
	modApi:setText("Science_Swap_Upgrade1", "+1 Size")
	modApi:setText("Science_Swap_A_UpgradeDescription", "Extends target area of the swap by 1 tile.")
	modApi:setText("Science_Swap_Upgrade2", "+2 Size")
	modApi:setText("Science_Swap_B_UpgradeDescription", "Extends target area of the swap by 2 tiles.")
	
	modApi:setText("Science_AcidShot_Description", "Fire an artillery shot that applies A.C.I.D. and pushes in the chosen direction.")
	
	modApi:setText("Science_Confuse_Description", "Fire a projectile that changes the target tile of an enemy's attack.")
	
	modApi:setText("Science_SmokeDefense_Upgrade1", "+1 Size")
	modApi:setText("Science_SmokeDefense_A_UpgradeDescription", "Area of effect increased by 1 tile.")
	
	modApi:setText("Science_LocalShield_Upgrade1", "Ignore Enemy")
	modApi:setText("Science_LocalShield_A_UpgradeDescription", "No longer shields enemies when used.")
	
	modApi:setText("Science_FireBeam_Upgrade1", "Unlimited Use")
	modApi:setText("Science_FireBeam_A_UpgradeDescription", "Removes use restriction in battles.")
	modApi:setText("Science_FireBeam_Upgrade2", "Add Flip")
	modApi:setText("Science_FireBeam_B_UpgradeDescription", "Flips the attacks of all enemies hit.")
	
	modApi:setText("Science_PushBeam_Upgrade2", "Omnidirectional")
	modApi:setText("Science_PushBeam_B_UpgradeDescription", "Gain the option to fire in all four directions.")
	
	modApi:setText("Science_TC_Enrage_Upgrade1", "Exhausted")
	modApi:setText("Science_TC_Enrage_A_UpgradeDescription", "Cancel the enraged unit's attack.")
	
	modApi:setText("Science_Placer_Upgrade2", "+2 Range")
	modApi:setText("Science_Placer_B_UpgradeDescription", "Can target two additional tiles away.")
	
	modApi:setText("Science_MassShift_Upgrade2", "Shield Friendly")
	modApi:setText("Science_MassShift_B_UpgradeDescription", "Shield adjacent ally or building.")
	
	modApi:setText("Science_TelePush_Upgrade1", "Telefrag")
	modApi:setText("Science_TelePush_A_UpgradeDescription", "Kill an enemy by teleporting into it, damaging self.")
	modApi:setText("Science_TelePush_Upgrade2", "No Self Damage")
	modApi:setText("Science_TelePush_B_UpgradeDescription", "Telefragging will no longer damage the Mech.")
	
	modApi:setText("Science_Placer_Upgrade1", "Maximum Area")
	modApi:setText("Science_Placer_A_UpgradeDescription", "Target any tile.")
	modApi:setText("Science_Placer_Upgrade2", "Cryo-Shielding")
	modApi:setText("Science_Placer_B_UpgradeDescription", "Gain the option to freeze the target before shielding it.")
--Passive
	modApi:setText("Passive_FlameImmune_Upgrade1", "Third Degree Burns")
	modApi:setText("Passive_FlameImmune_A_UpgradeDescription", "Enemies take more damage when burning for the first time.")
	
	--modApi:setText("Passive_Leech_Upgrade1", "+2 Heal")
	--modApi:setText("Passive_Leech_A_UpgradeDescription", "Increase healing to 3.")
--Support
	modApi:setText("Support_Boosters_Upgrade1", "Double Strike")
	modApi:setText("Support_Boosters_A_UpgradeDescription", "Leap directly to anywhere, pushing adjacent tiles and then call in an air strike on an intermediate tile.")

	modApi:setText("Support_Refrigerate_Description", "Freeze a target in one direction and ignite a target in another. Single-use.")
	
	modApi:setText("Support_Force_Upgrade1", "A.C.I.D. Strike")
	modApi:setText("Support_Force_A_UpgradeDescription", "Apply A.C.I.D. to all pushed tiles.")
	modApi:setText("Support_Force_Upgrade2", "Ignite")
	modApi:setText("Support_Force_B_UpgradeDescription", "Light the target on fire.")

	modApi:setText("Support_Confuse_Upgrade1", "Board Flip")
	modApi:setText("Support_Confuse_A_UpgradeDescription", "Flip all enemies.")
	modApi:setText("Support_Confuse_Upgrade2", "Unlimited Uses")
	modApi:setText("Support_Confuse_B_UpgradeDescription", "Removes use restriction in battles.")

	modApi:setText("Support_Waterdrill_Description", "Convert any liquid Tile or A.C.I.D. Tile to a Chasm, spreading the liquid to nearby tiles.")
	
	modApi:setText("Support_TC_GridAtk_Upgrade1", "Projectile")
	modApi:setText("Support_TC_GridAtk_A_UpgradeDescription", "Launch a damaging projectile instead.")
	modApi:setText("Support_TC_GridAtk_Upgrade2", "Ignite")
	modApi:setText("Support_TC_GridAtk_B_UpgradeDescription", "Light the target on fire.")
	
--Deploy
	modApi:setText("DeploySkill_PullTank_Upgrade1", "Skilled")
	modApi:setText("DeploySkill_PullTank_A_UpgradeDescription", "Increases the Pull-Tank's max health to 3 and move distance to 4.")
	modApi:setText("DeploySkill_ShieldTank_Upgrade2", "Artillery")
	modApi:setText("DeploySkill_ShieldTank_B_UpgradeDescription", "The Shield-Tank instead fires an artillery shot, allowing you to Shield distant targets.")
--Techno-Vek
	modApi:setText("Vek_Beetle_Upgrade2", "+1 Damage")
	modApi:setText("Vek_Beetle_B_UpgradeDescription", "Increases damage by 1.")
	modApi:setText("Vek_Hornet_Upgrade2", "Range, Damage & Flip")
	modApi:setText("Vek_Hornet_B_UpgradeDescription", "Increases potential hit tiles by 1 and damage on all tiles by 1. Flip all intermediate tiles.")
--Hooks
	require(self.scriptPath.."Dam"):load()
end

return {
    id = "Para_Tweaks",
    name = "Paradoxica's Tweaks",
    version = "0.5",
    init = init,
    load = load
}