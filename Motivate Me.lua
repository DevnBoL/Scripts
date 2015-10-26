--[[

---//==================================================\\---
--|| > About Script                                     ||--
---\\==================================================//---

	Script:     Motivate Me
	Version:    1.02
	Build Date: 2015-10-26
	Author:     Devn

---//==================================================\\---
--|| > Changelog                                        ||--
---\\==================================================//---

	Version 1.00:
		- Initial script release.
	
	Version 1.01:
		- Added drop-down to change motivator.
		- Added Spongebob.
		- Added Barack Obama.
		- Added script status link.
		
	Version 1.02:
		- Shows motivators full name instead of short name.
		
	Version 2.00:
		- Updated for new GodLib.
		- Added Devn/NordQuell motivation speakers.

--]]

---//==================================================\\---
--|| > User Settings (Can Be Modified)                  ||--
---\\==================================================//---

_G.MotivateMe_DisableAutoUpdate = false
_G.MotivateMe_DisableScriptStatus = false

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

ScriptInfo.Name = "Motivate Me"
ScriptInfo.Variables = "MotivateMe"
ScriptInfo.Author = "Devn"
ScriptInfo.Version = "2.00"
ScriptInfo.Date = "'15-10-26"
ScriptInfo.LeagueVersion = "5.20"

Script:LoadUserSettings()

Updater.Host = UpdateHost.GitHub
Updater.ScriptPath = "DevnBoL/Scripts/master/Motivate Me.lua"
Updater.VersionPath = "DevnBoL/Scripts/master/Versions/Motivate Me.version"

if (Updater:UpdateLibrary()) then return end
if (Updater:UpdateScript()) then return end

local Config = nil
local Readme = nil
local Changelog = nil
local Quote = nil
local LastMotivator = nil
local LastQuote = nil

local Motivators = { "Shia", "Spongebob", "Obama", "Devn", "NordQuell" }

local AvailableMotivators = {
	["Shia"] = "Shia Labeouf",
	["Spongebob"] = "Spongebob Squarepants",
	["Obama"] = "Barack Obama",
	["Devn"] = "Devn",
	["NordQuell"] = "NordQuell",
}
local Quotes = {
	["Shia"] = {
		[1] = "Do it. Just do it.",
		[2] = "Don't let your dreams be dreams.",
		[3] = "If your tired of starting over, stop giving up.",
		[4] = "Yes you can. Just do it.",
		[5] = "Some people dream of success, while your gunna wake up and work hard at it.",
	},
	["Spongebob"] = {
		[1] = "... and say hello to used napkin.",
		[2] = "I'm abosrbing his blows like I was made of some sort of spongy material.",
		[3] = "I, am a man!",
		[4] = "I love you.",
		[5] = "Ohh, east? I thought you said weast.",
	},
	["Obama"] = {
		[1] = "If you work hard and meet your responsibilities, you can get ahead!",
		[2] = "Money is not the only answer, but it makes a difference.",
		[3] = "The future rewards those who press on.",
		[4] = "Change will not come if we wait for some other person or some other time.",
		[5] = "People of Berlin - people of the world - this is our moment. This is our time.",
	},
	["Devn"] = {
		[1] = "YOU FUCKING GOT THIS MAN!",
		[2] = "If you lose this... you don't deserve VIP...",
		[3] = "Please... just don't die again. OK?",
		[4] = "Blame it on the support man, wasn't your fault.",
		[5] = "Blame it on the ah-ah-ah-ah-ah-alcohal!",
		[6] = "/muteall is your friend...",
		[7] = "Shit team, you got the next one!",
	},
	["NordQuell"] = {
		[1] = "Its okay you got lategame.",
		[2] = "Calm down friend you are smurfing you got this!",
		[3] = "Just mute them all and focus on your game.",
		[4] = "Master yourself, master the enemy!",
		[5] = "Relax brother, it's just a game.",
		[6] = "Unlucky, go next game.",
		[7] = "Nigga don't be mad, fuck them now!",
	},
}

---//==================================================\\---
--|| > Callback Handlers                                ||--
---\\==================================================//---

function OnLoad()
	SetupVariables()
	SetupConfig()
end
function OnTick()
	ShowReadme()
	ShowQuote()
end

---//==================================================\\---
--|| > Main Script Functions                            ||--
---\\==================================================//---

function ShowReadme()
	if (JustUpdated) then
		local title = Changelog.Title
		Changelog.Title = "Updated to v"..CurrentVersion
		Changelog.Callback = function() Changelog.Title = title end
		Changelog:Show()
		JustUpdated = false
		return
	end
	if (not Config.Extra.Readme) then return end
	Config.Extra.Readme = false
	Config.Extra:save()
	if (Readme.Visible or Changelog.Visible) then return end
	Readme:Show()
end
function ShowQuote()
	if (not myHero.dead) then
		if (Quote and Quote.Visible) then
			Quote:Remove()
		end
		Quote = nil
	elseif (not Quote) then
		local quote = nil
		local name = nil
		if (Config.Motivator == 1) then
			while (true) do
				math.randomseed(os.time())
				for i = 1, 3 do math.random() end
				local index = math.random(1, #Motivators)
				if (not LastMotivator or (index ~= LastMotivator)) then
					name = Motivators[index]
					LastMotivator = index
					break
				end
			end
		else
			name = Motivators[Config.Motivator - 1]
		end
		local quotes = Quotes[name]
		while (true) do
			math.randomseed(os.time())
			for i = 1, 3 do math.random() end
			local index = math.random(1, #quotes)
			if (not LastQuote or (index ~= LastQuote)) then
				quote = quotes[index]
				LastQuote = index
				break
			end
		end
		if (quote) then
			quote = Format("{1}: \"{2}\"", AvailableMotivators[name], quote)
			Quote = Alerter(Config.Extra.PosX, Config.Extra.PosY, quote, Config.Extra.Size, 120, Config.Extra.Color, "Black", 1)
		end
	end
end

---//==================================================\\---
--|| > Script Setup                                     ||--
---\\==================================================//---

function SetupVariables()
	SetupClassVariables()
	SetupReadmeVariables()
end
function SetupConfig()
	local extra = Config:Menu("Extra", "Extra Settings")
	extra:ColorBox("Color", "Text Color", "White")
	extra:Slider("Size", "Text Size", 35, 20, 50)
	extra:Separator()
	extra:Slider("PosX", "Horizontal Position (X)", 15, 0, WINDOW_W - 500)
	extra:Slider("PosY", "Vertical Position (Y)", 10, 0, WINDOW_H - 50)
	extra:Separator()
	extra:Toggle("Readme", "Show Readme & Changelog", true)
	Config:Separator()
	Config:Toggle("Draw", "Draw Quote While Dead", true)
	local motivators = { "Random" }
	for _, motif in ipairs(Motivators) do
		table.insert(motivators, AvailableMotivators[motif])
	end
	Config:DropDown("Motivator", "Current Motivator", 1, motivators)
	Config:Separator()
	ScriptInfo:LoadToConfig(Config)
end

function SetupClassVariables()
	Config = MenuConfig(ScriptInfo.Variables, ScriptInfo.Name)
end
function SetupReadmeVariables()
	Readme = DialogBox("Readme")
	Readme:Add("About Script:")
	Readme:Add("This is a small script that will draw motivational quotes onto the screen while you are")
	Readme:Add("dead. If there are any quotes you would like added please comment them on this scripts")
	Readme:Add("forum thread.")
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
	Changelog:Add("-t- Added drop-down to change motivator.")
	Changelog:Add("-t- Added Spongebob.")
	Changelog:Add("-t- Added Barack Obama.")
	Changelog:Add("-t- Added script status link.")
	Changelog:Add()
	Changelog:Add("Version 1.02:")
	Changelog:Add("-t- Shows motivators full name instead of short name.")
	Changelog:Add()
	Changelog:Add("Version 2.00:")
	Changelog:Add("-t- Updated for new GodLib.")
	Changelog:Add("-t- Added Devn/NordQuell motivation speakers.")
	Changelog:AddButton("Readme", function()
		Changelog:Close()
		Readme:Show()
	end)
end

-- End of Motivate Me.
