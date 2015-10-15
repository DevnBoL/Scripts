--[[

---//==================================================\\---
--|| > About Script                                     ||--
---\\==================================================//---

	Script:     Devn's Donger
	Version:    2.00
	Build Date: 2015-10-14
	Author:     Devn

---//==================================================\\---
--|| > Changelog                                        ||--
---\\==================================================//---

	Version 0.01:
		- Private donger release.

	Version 1.00:
		- Public donger release.
		
	Version 1.01:
		- BetterTS won't target Kog'Maw during his passive anymore.
		
	Version 1.02:
		- Open sourced the script.
		- Added hitchance sliders for W and E.
		- Added target health slider for upgraded W.
		- Added enemies hit slider for upgraded E.
		- Added SkinManager.
		- Added AutoLevelManager.
		
	Version 1.03:
		- Fixed a small bug caused from open-sourcing the script.
		- Added defensive and offensive item casting.
		- Fixed ult casting.
		- Fixed predictions (was defaulting to vpred before).
		
	Version 1.04:
		- Changed HPred settings for E a bit.
		- Added W fan percent slider.
		- Fixed R>W casting if Q was ready.
		- Won't load auto-potions if "Devn's Auto-Potions" is loaded.
		
	Version 2.00:
		- Updated for new GodLib.
		- Removed a few features until I can implement them in GodLib.

--]]

---//==================================================\\---
--|| > User Settings (Can Be Modified)                  ||--
---\\==================================================//---

_G.DevnsDonger_DisableAutoUpdate = false
_G.DevnsDonger_DisableSkins = false
_G.DevnsDonger_DisableLevelSpell = false

---//==================================================\\---
--|| > Script Initialization                            ||--
---\\==================================================//---

if (myHero.charName ~= "Heimerdinger") then return end

if (FileExist(LIB_PATH.."GodLib.lua")) then
	assert(load(ReadFile(LIB_PATH.."GodLib.lua"), "GodLib", "t", _ENV))()
else
	PrintChat("Downloading GodLib, please don't reload script!")
	DownloadFile("", LIB_PATH.."GodLib.lua", function()
		PrintChat("Finsihed downloading GodLib, please reload script!")
	end)
	return
end

ScriptInfo.Name = "Devn's Donger"
ScriptInfo.Variables = "DevnsDonger"
ScriptInfo.Author = "Devn"
ScriptInfo.Version = "2.00"
ScriptInfo.Date = "2015-10-14"
ScriptInfo.LeagueVersion = "5.19"

Script:LoadSave()
Script:LoadUserSettings()

Updater.Host = UpdateHost.GitHub
Updater.ScriptPath = "DevnBoL/Scripts/master/DevnsDonger/Devn's Donger.lua"
Updater.VersionPath = "DevnBoL/Scripts/master/DevnsDonger/Current.version.lua"

if (Updater:UpdateLibrary()) then return end
if (Updater:UpdateScript()) then return end

RequiredLibraries:Add(DefaultLibrary.Orbwalker)
RequiredLibraries:Add(DefaultLibrary.Prediction)
RequiredLibraries:Add(DefaultLibrary.PermaShow)

if (not RequiredLibraries:Load()) then return end

Script:LoadScriptStatusKey("SFIHNJMLNLH")

---//==================================================\\---
--|| > Script Variables                                 ||--
---\\==================================================//---

local Config = nil
local Readme = nil
local Changelog = nil

local Spells = { }

local WaitingForW = false

---//==================================================\\---
--|| > Callback Handlers                                ||--
---\\==================================================//---

function OnLoad()
	SetupVariables()
	SetupConfig()
	SetupReadme()
	Script:ShowLoadMessage()
end
function OnTick()
	ShowReadme()
	if (myHero.dead) then return end
	if (IsEvading() or Orbwalker:IsAttacking()) then return end
	Killsteal()
	if (not Selector.Target) then return end
	PerformModes()
end
function OnDraw()
	DrawPermaShow()
	if (myHero.dead or Config.Drawing.Disabled) then return end
	DrawRanges()
end

---//==================================================\\---
--|| > Main Script Functions                            ||--
---\\==================================================//---

function ShowReadme()
	if (Script.JustUpdated) then
		local title = Changelog.Title
		Changelog.Title = "Updated to v"..ScriptInfo.Version
		Changelog.Callback = function() Changelog.Title = title end
		Changelog:Show()
		Script.JustUpdated = false
		return
	end
	if (not Config.Misc.Readme) then return end
	Config.Misc.Readme = false
	Config.Misc:Save()
	if (Readme.Visible or Changelog.Visible) then return end
	Readme:Show()
end
function Killsteal()
	local config = Config.Killstealing
	if (not config.Enabled or (config.RecallDisable and RecallTracker.IsRecalling)) then return end
	if (not config.W and not config.E) then return end
	for _, enemy in ipairs(GetEnemiesInRange(Spells.W.Range)) do
		if (config.W and Spells.W.Ready and HaveEnoughMana(config.WMana) and Spells.W:WillKill(enemy)) then
			local castPos, hitchance = Spells.W:GetPrediction(enemy)
			if (castPos and (hitchance >= Hitchance.Medium)) then
				Spells.W:CastAt(castPos)
				break
			end
		end
		if (config.E and Spells.E.Ready and HaveEnoughMana(config.EMana) and Spells.E:WillKill(enemy)) then
			local castPos, hitchance = Spells.E:GetPrediction(enemy)
			if (castPos and (hitchance >= Hitchance.Medium)) then
				Spells.E:CastAt(castPos)
				break
			end
		end
	end
end
function PerformModes()
	if (ModeHandler.Keys.Combo) then ComboMode() end
	if (ModeHandler.Keys.Harass) then HarassMode() end
end

function ComboMode()
	local config = Config.Combo
	local upgrade = config.Upgrade
	local useR = (config.R and Spells.R.Ready and not WaitingForW and HaveEnoughMana(config.RMana))
	if (useR and upgrade.Q and (#GetEnemiesInRange(650) >= upgrade.QEnemies)) then
		Spells.R:Cast()
		Spells.Q:CastAt(Spells.Q:VectorOut(Selector.Target))
	elseif (config.Q and Spells.Q.Ready and HaveEnoughMana(config.QMana) and (#GetEnemiesInRange(650) > 0)) then
		Spells.Q:CastAt(Spells.Q:VectorOut(Selector.Target))
	end
	if (Spells.E:InRange(Selector.Target) and Spells.E.Ready) then
		local casted = false
		if (useR and upgrade.E) then
			if ((#GetEnemiesInRange(Spells.RE.Width, Selector.Target) >= upgrade.EHit) or (#GetEnemiesInRange(Spells.REStun.Width, Selector.Target) >= upgrade.EStun)) then
				local castPos, hitchance = Spells.REStun:GetPrediction(Selector.Target)
				if (castPos and (hitchance >= Hitchances[config.EHitchance])) then
					casted = true
					Spells.R:Cast()
					Spells.E:CastAt(castPos)
				end
			end
		end
		if (not casted and config.E and HaveEnoughMana(config.EMana)) then
			if (config.EStun) then
				Spells.EStun:PredictedCast(Selector.Target, config.EHitchance)
			else
				Spells.E:PredictedCast(Selector.Target, config.EHitchance)
			end
		end
	end
	if (Spells.W:InRange(Selector.Target) and Spells.W.Ready) then
		local casted = false
		if (useR and upgrade.W) then
			if (HealthUnderPercent(upgrade.WHealth, Selector.Target) or (Spells.W:CalculateDamage(Selector.Target) * 2.2 > Selector.Target.health)) then
				local castPos, hitchance = Spells.W:GetPrediction(Selector.Target)
				if (castPos and (hitchance >= Hitchances[config.WHitchance])) then
					casted = true
					Spells.R:Cast()
					WaitingForW = true
					DelayAction(function()
						WaitingForW = false
						CastW(castPos)
					end, 1)
				end
			end
		end
		if (not casted and config.W and HaveEnoughMana(config.WMana)) then
			PredictedCastW(Selector.Target, config.WHitchance)
		end
	end
end
function HarassMode()
	local config = Config.Harass
	if (config.Q and Spells.Q.Ready and HaveEnoughMana(config.QMana) and (#GetEnemiesInRange(650) > 0)) then
		Spells.Q:CastAt(Spells.Q:VectorOut(Selector.Target))
	end
	if (config.E and Spells.E.Ready and HaveEnoughMana(config.EMana) and Spells.E:InRange(Selector.Target)) then
		if (config.EStun) then
			Spells.EStun:PredictedCast(Selector.Target, config.EHitchance)
		else
			Spells.E:PredictedCast(Selector.Target, config.EHitchance)
		end
	end
	if (config.W and Spells.W.Ready and HaveEnoughMana(config.WMana)) then
		PredictedCastW(Selector.Target, config.WHitchance)
	end
end

function CastW(castPos, target)
	local target = target or Selector.Target
	local distance = math.max(GetDistance(target) * Config.Misc.WFan, 300)
	local pos = VectorOut(castPos, distance)
	Spells.W:CastAt(pos)
end
function PredictedCastW(target, minHitchance)
	local castPos, hitchance = Spells.W:GetPrediction(target)
	if (castPos and (hitchance >= Hitchances[minHitchance])) then
		CastW(castPos, target)
	end
end

---//==================================================\\---
--|| > Draw Functions                                   ||--
---\\==================================================//---

function DrawPermaShow()
	local config = Config.Drawing
	local title = Format("              {1}", ScriptInfo.Name)
	if (not config.PermaShow) then
		CustomPermaShow(title, "", false)
		CustomPermaShow("---------------------------------------------------", "", false)
		CustomPermaShow("No Mode Active", "", false)
		CustomPermaShow("Comb Mode:", "", false)
		CustomPermaShow("Harass Mode:", "", false)
	end
	local active = "      Active"
	local color = ParseColor(config.PermaShowColor, true, 150)
	CustomPermaShow(title, "", true)
	CustomPermaShow("---------------------------------------------------", "", true)
	CustomPermaShow("No Mode Active", "", not ModeHandler.Keys.Combo and not ModeHandler.Keys.Harass)
	CustomPermaShow("Combo Mode:", active, ModeHandler.Keys.Combo, color, color)
	CustomPermaShow("Harass Mode:", active, ModeHandler.Keys.Harass, color, color)
end
function DrawRanges()
	local config = Config.Drawing
	if (config.Target and Selector.Target and IsOnScreen(Selector.Target)) then
		DrawCircleAt(Selector.Target, 200, config.TargetColor)
	end
	if (config.SelectedTarget and Selector.SelectedTarget and IsOnScreen(Selector.SelectedTarget)) then
		DrawCircleAt(Selector.SelectedTarget, 250, config.SelectedTargetColor)
	end
	if (IsOnScreen(myHero)) then
		if (config.Q and (Spells.Q:GetLevel() > 0)) then DrawCircleAt(myHero, Spells.Q.Range, config.QColor) end
		if (config.W and (Spells.W:GetLevel() > 0)) then DrawCircleAt(myHero, Spells.W.Range, config.WColor) end
		if (config.E and (Spells.E:GetLevel() > 0)) then DrawCircleAt(myHero, Spells.E.Range, config.EColor) end
	end
end

---//==================================================\\---
--|| > Script Setup                                     ||--
---\\==================================================//---

function SetupVariables()
	Config = MenuConfig(ScriptInfo.Variables, ScriptInfo.Name)
	Spells["Q"] = SpellData("Q", _Q, "H-28 Turret", 325):AutoTrack()
	Spells["W"] = SpellData("W", _W, "Hextech Rockets", 1100):SetSkillshot(40, 0.5, 3000, true, SkillshotType.Linear):SetDamage(DamageType.Magic, 30, 30, DamageType.Magic, ScalingStat.AbilityPower, 0.45):AutoTrack()
	Spells["E"] = SpellData("E", _E, "CH Grenade", 925):SetSkillshot(210, 0.5, 1200, false, SkillshotType.Circular):SetDamage(DamageType.Magic, 20, 40, DamageType.Magic, ScalingStat.AbilityPower, 0.6):SetAccuracy(SpellAccuracy.Low):AutoTrack()
	Spells["EStun"] = SpellData("EStun", nil, nil, Spells.E.Range, 135):SetSkillshot(Spells.E.Delay, Spells.E.Speed, Spells.E.Collision, Spells.E.Type):SetAccuracy(SpellAccuracy.VeryLow)
	Spells["RE"] = SpellData("RE", nil, nil, Spells.E.Range, 420):SetSkillshot(Spells.E.Delay, Spells.E.Speed, Spells.E.Collision, Spells.E.Type)
	Spells["REStun"] = SpellData("REStun", nil, nil, Spells.E.Range, 270):SetSkillshot(Spells.E.Delay, Spells.E.Speed, Spells.E.Collision, Spells.E.Type):SetAccuracy(SpellAccuracy.Low)
	Spells["R"] = SpellData("R", _R, "UPGRADE!!!", 600):AutoTrack()
	RecallTracker:Initialize()
	Prediction:Initialize()
	Orbwalker:Initialize(true)
	Selector:Initialize(SelectorMode.LessCastMagic, Spells.W.Range)
end
function SetupConfig()
	Orbwalker:LoadToConfig(Config)
	ModeHandler:LoadToConfig(Config, true, true)
	Selector:LoadToConfig(Config)
	SetupComboConfig()
	SetupHarassConfig()
	SetupKillstealingConfig()
	SetupDrawingConfig()
	SetupMiscConfig()
	Config:Separator()
	ScriptInfo:LoadToConfig(Config)
end
function SetupReadme()
	Readme = DialogBox("Readme")
	Readme:Add(Format("{1} Casting:", Spells.R.Name))
	Readme:Add("Spells are casted in the order Q>E>W. W is only casted if the enemy can be killed by it")
	Readme:Add("or if your target's health is below the set percent during combo mode. Killstealing does")
	Readme:Add("not support ultimate casting as the cooldown is too long in my opinion to be used for")
	Readme:Add("killstealing.")
	Readme:Add()
	Readme:Add(Format("{1} Fan Percent:", Spells.W.Name))
	Readme:Add("-t- 0.0: Cast in front of hero.")
	Readme:Add("-t- 0.5: Cast between you and target.")
	Readme:Add("-t- 1.0: Cast at target.")
	Readme:Add()
	Readme:Add("Bugs/Errors:")
	Readme:Add("If you get any bugs or errors while using this script please take a screenshot (if you")
	Readme:Add("can) and report it to the forum thread!")
	Readme:Add()
	Readme:Add("If you like this script please leave a like on the forum thread and on script status! :D")
	Readme:AddButton("Show Changelog", function()
		Readme:Close()
		Changelog:Show()
	end, 150)
	Changelog = DialogBox("Changelog")
	Changelog:Add("Version 0.01:")
	Changelog:Add("-t- Private donger release.")
	Changelog:Add()
	Changelog:Add("Version 1.00:")
	Changelog:Add("-t- Public donger release.")
	Changelog:Add()
	Changelog:Add("Version 1.01:")
	Changelog:Add("-t- BetterTS won't target Kog'Maw during his passive anymore.")
	Changelog:Add()
	Changelog:Add("Version 1.02:")
	Changelog:Add("-t- Added hitchance sliders for W and E.")
	Changelog:Add("-t- Added target health slider for upgraded W.")
	Changelog:Add("-t- Added enemies hit slider for upgraded E.")
	Changelog:Add("-t- Added SkinManager.")
	Changelog:Add("-t- Added AutoLevelManager.")
	Changelog:Add()
	Changelog:Add("Version 1.03:")
	Changelog:Add("-t- Fixed a small bug caused from open-sourcing the script.")
	Changelog:Add("-t- Added defensive and offensive item casting.")
	Changelog:Add("-t- Fixed ult casting.")
	Changelog:Add("-t- Fixed predictions (was defaulting to vpred before).")
	Changelog:Add()
	Changelog:Add("Version 1.04:")
	Changelog:Add("-t- Changed HPred settings for E a bit.")
	Changelog:Add("-t- Added W fan percent slider. (Check Readme)")
	Changelog:Add("-t- Fixed R>W casting if Q was ready.")
	Changelog:Add()
	Changelog:Add("Version 2.00:")
	Changelog:Add("-t- Updated for new GodLib.")
	Changelog:AddButton("Readme", function()
		Changelog:Close()
		Readme:Show()
	end)
end

function SetupComboConfig()
	local config = Config:Menu("Combo", "Combo Mode")
	local upgrade = config:Menu("Upgrade", Format("{1} Settings", Spells.R.Name))
	upgrade:Toggle("Q", Format("Upgrade {1}", Spells.Q.Name), true)
	upgrade:Slider("QEnemies", "Minimum Enemies Near", 2, 1, 5)
	upgrade:Separator()
	upgrade:Toggle("W", Format("Upgrade {1}", Spells.W.Name), true)
	upgrade:Slider("WHealth", "Use When Target Below Percent", 50, 0, 100)
	upgrade:Separator()
	upgrade:Toggle("E", Format("Upgrade {1}", Spells.E.Name), true)
	upgrade:Slider("EHit", "Minimum Enemies to Hit", 4, 1, 5)
	upgrade:Slider("EStun", "Minimum Enemies to Stun", 3, 1, 5)
	config:Separator()
	config:Toggle("Q", Format("Use {1}", Spells.Q.Name), true)
	config:Slider("QMana", "Minimum Mana Percent", 0, 0, 100)
	config:Separator()
	config:Toggle("W", Format("Use {1}", Spells.W.Name), true)
	config:DropDown("WHitchance", "Spell Hitchance", 2, HitchanceOptions)
	config:Slider("WMana", "Minimum Mana Percent", 0, 0, 100)
	config:Separator()
	config:Toggle("E", Format("Use {1}", Spells.E.Name), true)
	config:Toggle("EStun", "Only to Stun", false)
	config:DropDown("EHitchance", "Spell Hitchance", 2, HitchanceOptions)
	config:Slider("EMana", "Minimum Mana Percent", 0, 0, 100)
	config:Separator()
	config:Toggle("R", Format("Use {1}", Spells.R.Name), true)
	config:Slider("RMana", "Minimum Mana Percent", 0, 0, 100)
end
function SetupHarassConfig()
	local config = Config:Menu("Harass", "Harass Mode")
	config:Toggle("Q", Format("Use {1}", Spells.Q.Name), true)
	config:Slider("QMana", "Minimum Mana Percent", 50, 0, 100)
	config:Separator()
	config:Toggle("W", Format("Use {1}", Spells.W.Name), true)
	config:DropDown("WHitchance", "Spell Hitchance", 3, HitchanceOptions)
	config:Slider("WMana", "Minimum Mana Percent", 50, 0, 100)
	config:Separator()
	config:Toggle("E", Format("Use {1}", Spells.E.Name), true)
	config:Toggle("EStun", "Only to Stun", true)
	config:DropDown("EHitchance", "Spell Hitchance", 3, HitchanceOptions)
	config:Slider("EMana", "Minimum Mana Percent", 50, 0, 100)
end
function SetupKillstealingConfig()
	local config = Config:Menu("Killstealing", "Killsteal Settings")
	config:Toggle("Enabled", "Enable Killstealing", true)
	config:Toggle("RecallDisable", "Disable While Recalling", false)
	config:Separator()
	config:Toggle("W", Format("Use {1}", Spells.W.Name), true)
	config:Slider("WMana", "Minimum Mana Percent", 0, 0, 100)
	config:Separator()
	config:Toggle("E", Format("Use {1}", Spells.E.Name), true)
	config:Slider("EMana", "Minimum Mana Percent", 0, 0, 100)
end
function SetupDrawingConfig()
	local config = Config:Menu("Drawing", "Drawing Options")
	DrawManager:LoadToConfig(config)
	config:Separator()
	config:Toggle("PermaShow", "Show PermaShow Menu", true)
	config:ColorBox("PermaShowColor", "PermaShow Color", "Light Gray")
	config:Separator()
	config:Toggle("Target", "Draw Current Target", true)
	config:ColorBox("TargetColor", "Circle Color", "Red")
	config:Separator()
	config:Toggle("SelectedTarget", "Draw Selected Target", true)
	config:ColorBox("SelectedTargetColor", "Circle Color", "Purple")
	config:Separator()
	config:Toggle("Q", Format("Draw {1} Range", Spells.Q.Name), true)
	config:ColorBox("QColor", "Range Circle Color", "Magenta")
	config:Separator()
	config:Toggle("W", Format("Draw {1} Range", Spells.W.Name), true)
	config:ColorBox("WColor", "Range Circle Color")
	config:Separator()
	config:Toggle("E", Format("Draw {1} Range", Spells.E.Name), true)
	config:ColorBox("EColor", "Range Circle Color")
end
function SetupMiscConfig()
	local config = Config:Menu("Misc", "Miscellaneous Settings")
	Prediction:LoadToConfig(config)
	config:Separator()
	config:Slider("WFan", Format("{1} Fan Percent", Spells.W.Name), 0.7, 0, 1, 1)
	config:Separator()
	config:Toggle("Readme", "Show Readme & Changelog", true)
end

-- End of Devn's Donger.
