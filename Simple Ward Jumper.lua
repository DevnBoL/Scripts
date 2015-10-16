--[[

---//==================================================\\---
--|| > About Script                                     ||--
---\\==================================================//---

	Script:     Simple Ward Jumper
	Version:    2.00
	Build Date: 2015-10-16
	Author:     Devn

---//==================================================\\---
--|| > Changelog                                        ||--
---\\==================================================//---

	Version 1.00:
		- Initial script release.

	Version 1.01:
		- Fixed small bug with "Low FPS" drawing.

	Version 1.02:
		- Fixed an error in my encryption.

	Version 1.03:
		- Added ally champion/minion jump support for Braum.
		- Toggle to wait until mouse is in jump range.
		- Takes into account object and wards hitbox radius.
		- Searches for wards by name instead of id now.
		- Move to mouse toggle.
		- Added drop-down to change object sort mode.
		- Closest to Mouse
		- Furthest from Hero
		
	Version 1.04:
		- Fixed small config error because I'm dumb and forgot to add a check for something.
		
	Version 1.05:
		- Added toggle to disable ward jumping.
		- Fixed bug causing this and my Jax to break eachother.
		
	Version 2.00:
		- Updated for new GodLib.

--]]

---//==================================================\\---
--|| > User Settings (Can Be Modified)                  ||--
---\\==================================================//---

_G.SimpleWardJumper_DisableAutoUpdate = false

---//==================================================\\---
--|| > Script Initialization                            ||--
---\\==================================================//---

if (FileExist(LIB_PATH.."GodLib.lua")) then
	assert(load(ReadFile(LIB_PATH.."GodLib.lua"), "GodLib", "t", _ENV))()
else
	PrintChat("Downloading GodLib, please don't reload script!")
	DownloadFile("https://raw.githubusercontent.com/DevnBoL/Scripts/master/Common/GodLib.lua?rand="..math.random(1, 10000), LIB_PATH.."GodLib.lua", function()
		PrintChat("Finsihed downloading GodLib, please reload script!")
	end)
	return
end

ScriptInfo.Name = "Simple Ward Jumper"
ScriptInfo.Variables = "SimpleWardJumper"
ScriptInfo.Author = "Devn"
ScriptInfo.Version = "2.00"
ScriptInfo.Date = "2015-10-16"
ScriptInfo.LeagueVersion = "5.20"

Script:LoadUserSettings()

Updater.Host = UpdateHost.GitHub
Updater.ScriptPath = "DevnBoL/Scripts/master/Simple Ward Jumper.lua"
Updater.VersionPath = "DevnBoL/Scripts/master/Versions/Simple Ward Jumper.version"

if (Updater:UpdateLibrary()) then return end
if (Updater:UpdateScript()) then return end

---//==================================================\\---
--|| > Script Variables                                 ||--
---\\==================================================//---

local Config = nil
local Readme = nil
local Changelog = nil

local Spell = nil
local Minions = nil
local LastWard = nil

local Spells = {
	LeeSin = {
		Key = _W,
		Range = 700,
	},
	Katarina = {
		Key = _E,
		Range = 700,
	},
	Jax = {
		Key = _Q,
		Range = 700,
	},
	Braum = {
		Key = _W,
		Range = 650,
	},
}

---//==================================================\\---
--|| > Callback Handlers                                ||--
---\\==================================================//---

function OnLoad()
	if (not CheckCompatibleChampion()) then return end
	SetupVariables()
	SetupConfig()
	SetupReadme()
	Script:LoadScriptStatusKey("WJMKRQLJQPP")
	Script:ShowLoadMessage()
end
function OnTick()
	ShowReadme()
	if (myHero.dead) then return end
	if (IsEvading() or Orbwalker:IsAttacking()) then return end
	WardJump()
end
function OnDraw()
	if (myHero.dead or not Config.Draw or not DrawManager:CanDraw()) then return end
	DrawJumpRange()
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
	if (not Config.Readme) then return end
	Config.Readme = false
	Config:Save()
	if (Readme.Visible or Changelog.Visible) then return end
	Readme:Show()
end

function WardJump()
	if (myHero.dead or not Config.Jump) then return end
	if (not Spell or not SpellIsReady(Spell.Key)) then
		MoveHero()
		return
	end
	if ((myHero.charName == "LeeSin") and (myHero:GetSpellData(Spell.Key).name == "blindmonkwtwo")) then
		MoveHero()
		return
	end
	if (not InRange(mousePos, Spell.Range) and Config.WaitMouse) then
		MoveHero()
		return
	end
	local position = mousePos
	if (Config.MaxRange) then
		position = VectorOut(mousePos, Spell.Range)
	end
	local objects = { }
	if (myHero.charName ~= "Braum") then
		if (Config.Wards) then
			for i = 1, objManager.iCount do
				local object = objManager:getObject(i)
				if (object and object.valid and (object.type == "obj_AI_Minion") and object.name:lower():find("ward") and InRange(object, Config.Distance, position)) then
					table.insert(objects, object)
				end
			end
		end
		if (Config.Enemies) then
			for _, enemy in ipairs(GetEnemiesInRange(Config.Distance, position)) do
				table.insert(objects, enemy)
			end
		end
	end
	if (Config.Minions) then
		Minions:update()
		for _, minion in ipairs(Minions.objects) do
			if (InRange(minion, Config.Distance, position)) then
				table.insert(objects, minion)
			end
		end
	end
	if (Config.Allies) then
		for _, ally in ipairs(GetAlliesInRange(Config.Distance, position)) do
			table.insert(objects, ally)
		end
	end
	if (#objects > 0) then
		table.sort(objects, function(a, b)
			if (Config.Mode == 1) then
				return (GetDistanceSqr(a, position) < GetDistanceSqr(b, position))
			else
				return (GetDistanceSqr(a, position) > GetDistanceSqr(b, position))
			end
		end)
		CCastSpell(Spell.Key, objects[1])
		return
	end
	if (myHero.charName ~= "Braum") then
		if (not LastWard or (GetInGameTimer() > LastWard + 2)) then
			local slot = GetWardSlot()
			if (slot) then
				if (GetDistanceSqr(position) > math.pow(600, 2)) then
					position = VectorOut(position, 600)
				end
				CastSpellAt(slot, position)
				LastWard = GetInGameTimer()
				DelayAction(function()
					for i = 1, objManager.iCount do
						local object = objManager:getObject(i)
						if (object and object.valid and (object.type == "obj_AI_Minion") and object.name:lower():find("ward") and InRange(object, Config.Distance, position)) then
							CCastSpell(Spell.Key, object)
						end
					end
				end, 0.3)
			end
		end
	end
	MoveHero()
end
function MoveHero()
	if (not Config.Move) then return end
	local pos = VectorOut(mousePos, 500)
	myHero:MoveTo(pos.x, pos.z)
end

---//==================================================\\---
--|| > Draw Functions                                   ||--
---\\==================================================//---

function DrawJumpRange()
	if (not Spell or not SpellIsReady(Spell.Key)) then return end
	if ((myHero.charName == "LeeSin") and (myHero:GetSpellData(Spell.Key).name == "blindmonkwtwo")) then return end
	DrawCircleAt(myHero, Spell.Range, Config.RangeColor)
end

---//==================================================\\---
--|| > Script Setup                                     ||--
---\\==================================================//---

function CheckCompatibleChampion()
	if (not Spells[myHero.charName]) then
		PrintLocal("Not compatible with the current champion!", MessageType.Warning)
		return false
	elseif (myHero.charName == "Braum") then
		PrintLocal("Braum cannot ward jump but this script will still attempt to jump to ally champions/minions!", MessageType.Warning)
	end
	return true
end

function SetupVariables()
	Orbwalker:Initialize()
	Config = MenuConfig(ScriptInfo.Variables, ScriptInfo.Name)
	Spell = Spells[myHero.charName]
	Minions = minionManager(MINION_ALL, Spell.Range, myHero, MINION_SORT_HEALTH_ASC)
end
function SetupConfig()
	DrawManager:LoadToConfig(Config, false, true, true)
	Config:Separator()
	if (myHero.charName == "Braum") then
		Config:KeyBinding("Jump", "Ally Jump Active", false, "T")
	else
		Config:KeyBinding("Jump", "Ward Jump Active", false, "T")
	end
	Config:Toggle("Move", "Move to Mouse", true)
	Config:Separator()
	Config:Toggle("WaitMouse", "Only Jump if Mouse in Range", true)
	Config:Toggle("MaxRange", "Jump at Max Range", true)
	Config:Slider("Distance", "Distance to Look for Objects", 250, 100, 700)
	Config:DropDown("Mode", "Object Sort Mode", 2, { "Closest to Mouse", "Furthest from Hero" })
	Config:Separator()
	Config:Toggle("Minions", "Jump to Minions", true)
	Config:Toggle("Allies", "Jump to Ally Heroes", true)
	if (myHero.charName == "Braum") then
		Config.Enemies = false
		Config.Wards = false
	else
		Config:Toggle("Enemies", "Jump to Enemy Heroes", false)
		Config:Toggle("Wards", "Jump to Wards", true)
	end
	Config:Separator()
	Config:Toggle("Draw", "Draw Jump Range", true)
	Config:ColorBox("RangeColor", "Range Indicator Color", "Magenta")
	Config:Separator()
	Config:Toggle("Readme", "Show Readme & Changelog", true)
	Config:Separator()
	ScriptInfo:LoadToConfig(Config)
end
function SetupReadme()
	Readme = DialogBox("Readme")
	Readme:Add("Note When Using Braum:")
	Readme:Add(" - Braum cannot ward jump.")
	Readme:Add(" - Will still attempt to jump to ally minions and allies.")
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
	Changelog:Add("Version 1.00:")
	Changelog:Add("-t- Initial script release.")
	Changelog:Add()
	Changelog:Add("Version 1.01:")
	Changelog:Add("-t- Fixed small bug with 'Low FPS' drawing.")
	Changelog:Add()
	Changelog:Add("Version 1.02:")
	Changelog:Add("-t- Fixed an error in my encryption.")
	Changelog:Add()
	Changelog:Add("Version 1.03:")
	Changelog:Add("-t- Added ally champion/minion jump support for Braum.")
	Changelog:Add("-t- Toggle to wait until mouse is in jump range.")
	Changelog:Add("-t- Takes into account object and wards hitbox radius.")
	Changelog:Add("-t- Searches for wards by name instead of id now.")
	Changelog:Add("-t- Move to mouse toggle.")
	Changelog:Add("-t- Added drop-down to change object sort mode.")
	Changelog:Add("-t-t- Closest to Mouse")
	Changelog:Add("-t-t- Furthest from Hero")
	Changelog:Add()
	Changelog:Add("Version 1.04:")
	Changelog:Add("-t- Fixed small config error because I'm dumb and")
	Changelog:Add("-t-t-tforgot to add a check for something.")
	Changelog:Add()
	Changelog:Add("Version 1.05:")
	Changelog:Add("-t- Added toggle to disable ward jumping.")
	Changelog:Add("-t- Fixed bug causing this and my Jax to break eachother.")
	Changelog:Add()
	Changelog:Add("Version 2.00:")
	Changelog:Add("-t- Updated for new GodLib.")
	Changelog:AddButton("Readme", function()
		Changelog:Close()
		Readme:Show()
	end)
end

-- End of Simple Ward Jumper.
