--[[

---//==================================================\\---
--|| > About Script                                     ||--
---\\==================================================//---

	Script:     Challenger Emotes
	Version:    1.01
	Build Date: 2015-10-31
	Author:     Devn

---//==================================================\\---
--|| > Changelog                                        ||--
---\\==================================================//---

	Version 1.00:
​		- Initial script release.

	Version 1.01:
		- Updated for new GodLib.
		- Added mastery emote support.
		- Added emote on enemy death.

--]]

---//==================================================\\---
--|| > User Settings (Can Be Modified)                  ||--
---\\==================================================//---

_G.ChallengerEmotes_DisableAutoUpdate = false
_G.ChallengerEmotes_DisableScriptStatus = false
_G.ChallengerEmotes_EnableDebugMode = false

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

ScriptInfo.Name = "Challenger Emotes"
ScriptInfo.Variables = "ChallengerEmotes"
ScriptInfo.Author = "Devn"
ScriptInfo.Version = "1.01"
ScriptInfo.Date = "'15-10-31"
ScriptInfo.LeagueVersion = "5.21"

Script:LoadUserSettings()

Updater.Host = UpdateHost.GitHub
Updater.ScriptPath = "DevnBoL/Scripts/master/Challenger Emotes.lua"
Updater.VersionPath = "DevnBoL/Scripts/master/Versions/Challenger Emotes.version"

if (Updater:UpdateLibrary()) then return end
if (Updater:UpdateScript()) then return end

---//==================================================\\---
--|| > Script Variables                                 ||--
---\\==================================================//---

local Config = nil
local Readme = nil
local Changelog = nil
local DrawStayDistance = nil
local DrawKillRange = nil
local LastTick = nil

local Enemies = { }
local Emotes = { "Laugh", "Taunt", "Joke", "Dance", "Mastery", "Random" }

---//==================================================\\---
--|| > Callback Handlers                                ||--
---\\==================================================//---

function OnLoad()
	SetupVariables()
	SetupConfig()
	SetupReadme()
	Script:LoadScriptStatusKey("QDGELKHLCGJ")
	Script:ShowLoadMessage()
end
function OnTick()
	if (myHero.dead or RecallTracker.IsRecalling) then return end
	local emotes = { "/laugh", "/taunt", "/joke", "/dance", "/masterybadge" }
	if (Config.KillEnabled) then
		for i = 1, #GetEnemyHeroes() do
			local enemy = GetEnemyHeroes()[i]
			if (enemy.dead) then
				if (Enemies[enemy.networkID]) then
					local sendEmote = true
					if (Config.KillSafe and (#GetEnemiesInRange(Config.KillRange) > 0)) then
						PrintDebug("Enemy in range, not going to do death emote: "..enemy.charName)
						sendEmote = false
					end
					if (sendEmote) then
						local emote = nil
						if (Config.KillEmote == 6) then
							emote = emotes[math.random(1, #emotes)]
						else
							emote = emotes[Config.KillEmote]
						end
						PrintDebug("Emoting on enemy death: "..enemy.charName)
						DelayAction(function(emote)
							SendChat(emote)
						end, Config.KillDelay, { emote })
					end
					Enemies[enemy.networkID] = false
				end
			elseif (enemy.visible and InRange(enemy, Config.KillRange)) then
				Enemies[enemy.networkID] = true
			else
				Enemies[enemy.networkID] = false
			end
		end
	end
	if (not Config.Spam) then return end
	if (not LastTick or (GetInGameTimer() > LastTick + (Config.Delay / 1000))) then
		LastTick = GetInGameTimer()
		local emote = nil
		if (Config.Emote == 6) then
			emote = emotes[math.random(1, #emotes)]
		else
			emote = emotes[Config.Emote]
		end
		PrintDebug("Emoting: "..emote)
		SendChat(emote)
	end
	if (Config.Move) then
		local pos = VectorTo(mousePos, 500)
		if (not InRange(pos, Config.StayDistance)) then
			myHero:MoveTo(pos.x, pos.z)
		end
	end
end
function OnDraw()
	if (DrawStayDistance and (os.clock() < DrawStayDistance + 1)) then
		DrawCircleMinimapAt(myHero, Config.StayDistance, 2, "White")
		DrawCircle3DAt(myHero, Config.StayDistance, 1, "White")
	else
		DrawStayDistance = nil
	end
	if (DrawKillRange and (os.clock() < DrawKillRange + 1)) then
		DrawCircleMinimapAt(myHero, Config.KillRange, 2, "White")
		DrawCircle3DAt(myHero, Config.KillRange, 1, "White")
	else
		DrawKillRange = nil
	end
end

---//==================================================\\---
--|| > Script Setup                                     ||--
---\\==================================================//---

function SetupVariables()
	Config = MenuConfig(ScriptInfo.Variables, ScriptInfo.Name)
	RecallTracker:Initialize()
	for i = 1, #GetEnemyHeroes() do
		Enemies[GetEnemyHeroes()[i].networkID] = false
	end
end
function SetupConfig()
	Config:Dynamic("Spam", "Spam Emote", SCRIPT_PARAM_ONKEYDOWN, false, "T", false)
	Config:Separator()
	Config:DropDown("Emote", "Emote to Spam", 1, Emotes)
	Config:Slider("Delay", "Delay Between Emotes (ms)", 250, 0, 2000, 100)
	Config:Toggle("Move", "Move to Mouse", true)
	Config:Slider("StayDistance", "Mouse Distance to Stop Move", 200, MAX_OBJ_DISTANCE, 250):SetCallback(function()
		DrawStayDistance = os.clock()
	end)
	Config:Separator()
	Config:Toggle("KillEnabled", "Emote on Enemy Death", true)
	Config:Toggle("KillSafe", "Don't Emote if Other Enemies Near", true)
	Config:DropDown("KillEmote", "Emote to Send", 1, Emotes)
	Config:Slider("KillDelay", "Delay Before Sending (Seconds)", 2, 0, 5)
	Config:Slider("KillRange", "Max Range of Enemy", 1500, 500, 3000, 100):SetCallback(function()
		DrawKillRange = os.clock()
	end)
	Config:Separator()
	ScriptInfo:LoadToConfig(Config)
end
function SetupReadme()
	Readme = DialogBox("Readme")
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
	Changelog:Add("-t- Updated for new GodLib.")
	Changelog:Add("-t- Added mastery emote support.")
	Changelog:Add("-t- Added emote on enemy death.")
	Changelog:AddButton("Readme", function()
		Changelog:Close()
		Readme:Show()
	end)
end

-- End of Challenger Emotes.
