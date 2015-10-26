--[[

---//==================================================\\---
--|| > About Library                                    ||--
---\\==================================================//---

	Library:    GodLib
	Version:    3.01
	Build Date: 2015-10-16
	Author:     Devn

---//==================================================\\---
--|| > Changelog                                        ||--
---\\==================================================//---

	Version 1.00:
		- Initial library release.

	Version 2.00:
		- Library re-write for personal use.

	Version 3.00:
		- Library re-write for public use.

	Version 3.01:
		- Added 'WardNames' table.
		- Added 'CastSpellAt' function.
		- Changed 'AutoPotions' to use 'OnProcessSpell' callback.
		- SAC:R notification will only be shown once across multiple scripts.
		- Added 'POTION_DURATION' variable.
		- Fixed error in 'Selector' printing target names on new selection.
		- Added 'Notifications' class, credits to BlueCore.
		- Added 'Selector.Targets' table.
		- Removed 'SpellData.Update' function.
		- Added 'SpellData.UpdateRange' and 'SpellData.UpdateWidth'.

--]]

---//==================================================\\---
--|| > Script Variables                                 ||--
---\===================================================//---

LIB_VERSION = 3.01

UPDATE_SAFE_TIMER = 180 -- Script will stop attempting to update after this time (ms) has passed in-game.
ORBWALKER_ATTACK_RESET = 2 -- Orbwalker 'Attacking' variable will be reset after this time incase 'OnAfterAttack' doesn't get called.
MAX_OBJ_DISTANCE = 50 -- Max distance object can be from unit to be valid.
LEVEL_SPELL_DELAY = 1 -- Delay in seconds between leveling spells.

MIN_VISION_RANGE = 1000 -- The minimum range script can look for enemies.
DEF_VISION_RANGE = 2500 -- The default range script will look for enemies.
MAX_VISION_RANGE = 5000 -- The max range script can look for enemies.

POTION_DURATION = 15 -- Duration for health and mana potions.

NOTIFICATION_THICKNESS = 66
NOTIFICATION_LENGTH = 276
NOTIFICATION_DURATION = 5

Assert = _G.assert
PrintDebug = function() end

SelectorMode = { }

HitchanceOptions = { "Low", "Medium", "High" }
AccuracyOptions = { "Default", "Low", "Very Low" }
WardNames = { "TrinketTotemLvl1", "TrinketTotemLvl3", "ItemMiniWard", "ItemGhostWard", "TrinketTotemLvl4", "SightWard", "VisionWard" }

DefaultLibrary = {
	Orbwalker = { "SxOrbWalk", "" },
	Prediction = { "VPrediction", "", true },
	PermaShow = { "CustomPermaShow", "", true },
}
UpdateHost = {
	GitHub = "raw.githubusercontent.com",
	BitBucket = "bitbucket.org",
}
MessageType = {
	Info = "BEF781",
	Warning = "F781BE",
	Error = "F78183",
	Debug = "81BEF7",
}
SkillshotType = {
	Targeted = 1,
	Linear = 2,
	Circular = 3,
	Cone = 4,
}
DamageType = {
	Magic = 1,
	Physical = 2,
	True = 3,
}
ScalingStat = {
	AbilityPower = 1,
	AttackDamage = 2,
	BonusAttackDamage = 3,
	Health = 4,
	Armor = 5,
	MagicResist = 6,
	MaxHealth = 7,
	MaxMana = 8,
}
Hitchance = {
	None = 0,
	Low = 1,
	Medium = 2,
	High = 3,
}
SpellAccuracy = {
	Normal = 1,
	Low = 2,
	VeryLow = 3,
}
SummonerSpell = {
	Ignite = "Ignite",
	Heal = "Heal",
	Barrier = "Barrier",
	Smite = "Smite",
	Cleanse = "Cleanse",
}
Hitchances = {
	[1] = Hitchance.Low,
	[2] = Hitchance.Medium,
	[3] = Hitchance.High,
}
BuffType = {
	Aura = 1,
	CombatEnchancer = 2,
	CombatDehancer = 3,
	SpellShield = 4,
	Stun = 5,
	Invisibility = 6,
	Silence = 7,
	Taunt = 8,
	Polymorph = 9,
	Slow = 10,
	Snare = 11,
	Damage = 12,
	Heal = 13,
	Haste = 14,
	SpellImmunity = 15,
	PhysicalImmunity = 16,
	Invulnerability = 17,
	Sleep = 18,
	NearSight = 19,
	Frenzy = 20,
	Fear = 21,
	Charm = 22,
	Poison = 23,
	Suppression = 24,
	Blind = 25,
	Counter = 26,
	Shred = 27,
	Flee = 28,
	Knockup = 29,
	Knockback = 30,
	Disarm = 31,
}
Potions = {
	Health = "Health",
	Mana = "Mana",
	Flask = "Flask",
}

---//==================================================\\---
--|| > Library Variables                                ||--
---\===================================================//---

local DEFAULT_SCRIPT_NAME = "GodScript"
local DEFAULT_SCRIPT_VERSION = "0.01"

local ColorValues = {
	["White"] = { 255, 255, 255, 255 },
	["Light Blue"] = { 255, 255, 255, 255 },
	["Blue"] = { 255, 0, 0, 255 },
	["Dark Blue"] = { 255, 0, 0, 128 },
	["Yellow"] = { 255, 255, 255, 0 },
	["Lime"] = { 255, 128, 255, 0 },
	["Light Green"] = { 255, 128, 255, 128 },
	["Green"] = { 255, 0, 255, 0 },
	["Dark Green"] = { 255, 0, 128, 0 },
	["Magenta"] = { 255, 255, 0, 255 },
	["Red"] = { 255, 255, 0, 0 },
	["Dark Red"] = { 255, 128, 0, 0 },
	["Cyan"] = { 255, 0, 255, 255 },
	["Gray"] = { 255, 128, 128, 128 },
	["Brown"] = { 255, 96, 48, 0 },
	["Orange"] = { 255, 255, 128, 0 },
	["Purple"] = { 255, 160, 32, 240 },
	["Black"] = { 255, 0, 0, 0 },
	["Light Gray"] = { 255, 211, 211, 211 },
}
local ScalingFunctions = {
    [ScalingStat.AbilityPower] = function(x) return x * myHero.ap end,
    [ScalingStat.AttackDamage] = function(x) return x * myHero.totalDamage end,
    [ScalingStat.BonusAttackDamage] = function(x) return x * myHero.addDamage end,
	[ScalingStat.Health] = function(x) return x * myHero.health end,
    [ScalingStat.Armor] = function(x) return x * myHero.armor end,
    [ScalingStat.MagicResist] = function(x) return x * myHero.magicArmor end,
    [ScalingStat.MaxHealth] = function(x) return x * myHero.maxHeath end,
    [ScalingStat.MaxMana] = function(x) return x * myHero.maxMana end,
}
local InterruptableSpells = {
	["KatarinaR"] = { charName = "Katarina", DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
	["Meditate"] = { charName = "MasterYi", DangerLevel = 1, MaxDuration = 2.5, CanMove = false },
	["Drain"] = { charName = "FiddleSticks", DangerLevel = 3, MaxDuration = 2.5, CanMove = false },
	["Crowstorm"] = { charName = "FiddleSticks", DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
	["GalioIdolOfDurand"] = { charName = "Galio", DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
	["MissFortuneBulletTime"] = { charName = "MissFortune", DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
	["VelkozR"] = { charName = "Velkoz", DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
	["InfiniteDuress"] = { charName = "Warwick", DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
	["AbsoluteZero"] = { charName = "Nunu", DangerLevel = 4, MaxDuration = 2.5, CanMove = false },
	["ShenStandUnited"] = { charName = "Shen", DangerLevel = 3, MaxDuration = 2.5, CanMove = false },
	["FallenOne"] = { charName = "Karthus", DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
	["AlZaharNetherGrasp"] = { charName = "Malzahar", DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
	["Pantheon_GrandSkyfall_Jump"] = { charName = "Pantheon", DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
}
local VSkillshot = {
	[SkillshotType.Linear] = "line",
	[SkillshotType.Circular] = "circle",
	[SkillshotType.Cone] = "cone",
}

---//==================================================\\---
--|| > Misc. Functions                                  ||--
---\===================================================//---

function DAssert(condition, message)
	if (type(condition) == "function") then
		if (condition() == true) then
			return
		end
	elseif (condition == true) then
		return
	end
	local info = debug.getinfo(2)
	local info2 = debug.getinfo(3)
	local caller = ""
	local params = ""
	if (info2 and info2.name and (#info2.name > 0)) then
		caller = info2.name.." => "
	end
	for i = 1, info.nparams do
		local name, value = debug.getlocal(2, i)
		if (value == nil) then
			value = "nil"
		elseif (type(value) == "string") then
			value = Format("\"{1}\"", value)
		elseif (type(value) == "number") then
			value = tostring(value)
		elseif (value.charName) then
			value = value.charName
		else
			value = ToString(value)
		end
		params = params..name..":"..value
		if (i < info.nparams) then
			params = params..", "
		end
	end
	assert(false, Format("[{4}]:{5} => {1} {6}({2}) {3}", caller, params, message, FILE_NAME, info2.currentline, info.name))
end
function Class(name, base)
	local o = { }
	o.__index = o
	if (base) then
		Assert(type(base) == "table", "Class: table expected for <base>")
		setmetatable(o, base)
		o.__base = base
	end
	setmetatable(o, {
		__call = function(_, ...)
			local i = { }
			local r = nil
			setmetatable(i, o)
			if (i.__init) then
				r = i.__init(i, table.unpack({ ... }))
			end
			if (r ~= nil) then
				return r
			end
			return i
		end
	})
	_ENV[name] = o
end
function Format(input, ...)
	Assert(input and (type(input) == "string"), "Format: string expected for <input>")
	local args = { ... }
	for i = 1, #args do
		input = input:gsub("{"..tostring(i).."}", ToString(args[i]))
	end
	return input
end
function ToString(...) -- Taken from AllClass 'print' function.
	local t, length = { }, select("#",...)
    for i = 1, length do
        local v = select(i,...)
        local otype = type(v)
        if (otype == "string") then
			t[i] = v
        elseif (otype == "number") then
			t[i] = tostring(v)
        elseif (otype == "table") then
			local buffer, count = "{ ", 1
			for key, value in pairs(v) do
				buffer = buffer..tostring(key).." = \""..tostring(value).."\""..(count == Count(v) and " }" or ", ")
				count = count + 1
			end
			t[i] = buffer
        elseif (otype == "boolean") then
			t[i] = v and "true" or "false"
        elseif (otype == "userdata") then
			t[i] = ctostring(v)
		else
			t[i] = otype
        end
    end
	return table.concat(t)
end
function Count(object)
	local count = 0
	for _, _ in pairs(object) do
		count = count + 1
	end
	return count
end
function SplitString(input, seperator)
	local t = { }
	local seperator = seperator or "%s"
	for str in input:gmatch("([^"..seperator.."]+)") do
		table.insert(t, str)
	end
	return t
end
function UrlEncode(str)
	if (str) then
		str = string.gsub(str, "\n", "\r\n")
		str = string.gsub(str, "([^%w ])", function(c)
			return string.format("%%%02X", string.byte(c))
		end)
		str = string.gsub(str, " ", "+")
	end
	return str
end
function Divide(number, division)
	return (number * (1 / division))
end
function ParseColor(color, argb, alpha)
	local argb = argb or false
	local alpha = alpha or 255
	local color = color or { alpha, 255, 255, 255 }
	if (type(color) == "number") then
		print("color: "..tostring(color))
	end
	if ((type(color) == "string") and ColorValues[color]) then
		local value = ColorValues[color]
		if (not argb) then
			value[1] = math.min(alpha, value[1])
			return value
		end
		return ARGB(math.min(alpha, value[1]), value[2], value[3], value[4])
	end
	if (not argb) then
		color[1] = math.min(alpha, color[1])
		return color
	end
	return ARGB(math.min(alpha, color[1]), color[2], color[3], color[4])
end
function Round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function PrintLocal(text, messageType, showName)
	if (showName == nil) then
		showName = true
	end
	local message = Format("<font color=\"#{1}\">{2}</font>", messageType, text)
	local messageType = messageType or MessageType.Info
	if (showName and ScriptInfo.Name) then
		message = Format("<font color=\"#8183F7\">{1}:</font> {2}", ScriptInfo.Name, message)
	end
	PrintChat(message)
end
function NotificationAlert(text, delay)
	return Alerter(15, 10, ScriptInfo.Name..": "..text, 35, delay or 120, "White", "Black", 1)
end
function GetRealLatency()
	return GetLatency() / 1000
end

function SafeWebResult(host, path)
	local result = GetWebResult(host, UrlEncode(path))
	if (not result or (type(result) ~= "string") or (result == "0") or (#result == 0) or result:lower():find("400: invalid request") or result:lower():find("not found")) then
		return nil
	end
	return result
end
function GetSafeLink(url)
	return Format("{1}?rand={2}", url, math.random(1, 10000))
end

---//==================================================\\---
--|| > Script Functions                                 ||--
---\===================================================//---

function CCastSpell(spell, posX, posZ)
	if (posX and posZ) then
		return CastSpell(spell, posX, posZ)
	elseif (posX) then
		return CastSpell(spell, posX)
	else
		return CastSpell(spell)
	end
end
function CastSpellAt(spell, pos)
	return CCastSpell(spell, pos.x, pos.z)
end
function SpellIsReady(spell)
	return (myHero:CanUseSpell(spell) == READY)
end
function GetSpellCooldown(cooldown)
	return (cooldown - (cooldown * (myHero.cdr * -1)))
end
function SpellsWillKill(unit, ...)
	local damage = 0
	for _, spell in pairs({ ... }) do
		damage = damage + spell:CalculateDamage(unit)
	end
	return (damage >= unit.health)
end
function GetSpellLevel(spell)
	return myHero:GetSpellData(spell).level
end
function HaveManaForSpells(qMana, qCasts, wMana, wCasts, eMana, eCasts, rMana, rCasts)
	local cost = 0
	if (qCasts > 0) then
		cost = cost + (qMana * qCasts)
	end
	if (wCasts > 0) then
		cost = cost + (wMana * wCasts)
	end
	if (eCasts > 0) then
		cost = cost + (eMana * eCasts)
	end
	if (rCasts > 0) then
		cost = cost + (rMana * rCasts)
	end
	return (myHero.mana >= cost)
end
function GetSummonerSlot(name)
	if (myHero:GetSpellData(SUMMONER_1).name:lower() == name:lower()) then
		return SUMMONER_1
	elseif (myHero:GetSpellData(SUMMONER_2).name:lower() == name:lower()) then
		return SUMMONER_2
	end
	return nil
end

function InRange(object, range, from)
	local from = from or myHero
	return (GetDistanceSqr(object, from) <= math.pow(range, 2))
end
function SetTarget(target)
	Selector.SelectedTarget = target
	Orbwalker:ForceTarget(target)
end
function GetTarget(range)
	return Selector:GetTarget(range)
end
function HaveEnoughMana(percent, unit)
	local unit = unit or myHero
	return ((unit.mana / unit.maxMana) >= (percent / 100))
end
function HealthUnderPercent(percent, unit, health)
	local unit = unit or myHero
	local health = health or unit.health
	return ((health / unit.maxHealth) <= (percent / 100))
end
function GetEnemiesInRange(range, from)
	local range = range or VisionRange
	local from = from or myHero
	local enemies = { }
	for i = 1, #GetEnemyHeroes() do
		local enemy = GetEnemyHeroes()[i]
		if (enemy.visible and not enemy.dead and InRange(enemy, range, from)) then
			table.insert(enemies, enemy)
		end
	end
	return enemies
end
function GetAlliesInRange(range, from)
	local range = range or VISION_RANGE
	local from = from or myHero
	local allies = { }
	for i = 1, #GetAllyHeroes() do
		local ally = GetAllyHeroes()[i]
		if (ally.visible and not ally.dead and InRange(ally, range, from)) then
			table.insert(allies, ally)
		end
	end
	return allies
end
function GetPriority(unit)
	local convert = {
		[1] = 5,
		[2] = 4,
		[3] = 3,
		[4] = 2,
		[5] = 1,
	}
	return convert[Selector:GetPriority(unit)]
end
function IsUnderEnemyTurret(pos)
	local turrets = GetTurrets()
	for i = 1, #turrets do
		local turret = turrets[i]
		if (turret and (turret.team ~= myHero.team)) then
			if (InRange(pos, turret.range + 15, turret)) then
				return true
			end
		end
	end
	return false
end
function IsValid(target, range, from)
	local from = from or myHero
	local buffs = { BuffType.Invisibility, BuffType.Invulnerability }
	if (ValidTarget(target)) then
		for i = 1, #buffs do
			if (UnitHasBuffOfType(buffs[i], target)) then
				return false
			end
		end
		if (not range or InRange(target, range, from)) then
			if (not (UnitHasBuff("UndyingRage", target) and (target.health == 1)) and not UnitHasBuff("JudicatorIntervention", target) and not UnitHasBuff("KogMawIcathianSurprise", target)) then
				return true
			end
		end
	end
	return false
end
function GetBarInfo(unit)
    local barPos = GetUnitHPBarPos(unit)
    local barOffset = GetUnitHPBarOffset(unit)
    local offsetX = {
        ["Darius"] = -0.05,
        ["Renekton"] = -0.05,
        ["Sion"] = -0.05,
        ["Thresh"] = -0.03,
    }
    local offsetY = {
        ["XinZhao"] = 1,
        ["Velkoz"] = -2.65,
    }
	if (offsetX[unit.charName]) then
		barOffset.x = offsetX[unit.charName]
	end
	if (offsetY[unit.charName]) then
		barOffset.y = offsetY[unit.charName]
	end
    return D3DXVECTOR2(barPos.x + barOffset.x * 150 - 70, barPos.y + barOffset.y * 50 + 13)
end
function IsEvading()
	return (_G.Evadeee_evading or (_G.EzEvade and _G.EzEvade.Evading) or _G.Evading or _G.evade)
end
function IsFleeing(unit, distance, from)
	local position = GetPredictedPosition(unit, 0.26)
	if (position and not InRange(position, distance, from)) then
		return true
	end
	return false
end
function EnemyIsInRange(range, from)
	local from = from or myHero
	return (#GetEnemiesInRange(range, from) > 0)
end
function GetPredictedHealth(unit, waittime)
	local waittime = waittime or 0.2
	if (waittime > 0) then
		return Prediction:GetPredictedHealth(unit, waittime)
	end
	return unit.health
end
function GetHitBox(unit)
	return unit.boundingRadius or 65
end

--[[ Old HP bar functions.
function GetBarInfo(unit)
	local pos, ccd
	if (unit.type == myHero.type) then
		pos, ccd = GetHPBarPos2(unit)
	else
		pos = GetUnitHPBarPos(unit)
	end
	local dcd = 62
	local _dd = 4
	if ((unit.charName == "SRU_Red") or (unit.charName == "SRU_Blue") or (unit.charName == "SRU_Dragon")) then
		pos.x = pos.x - 72
		pos.y = pos.y + 2
		dcd = 144
		_dd = 12
	elseif (unit.charName == "SRU_Baron") then
		pos.x = pos.x - 97.5
		pos.y = pos.y + 1
		dcd = 191
		_dd = 14
	elseif ((unit.charName == "SRU_Gromp") or (unit.charName:lower():find("minionsuper"))) then
		pos.x = pos.x - 44
		dcd = 90
	elseif (unit.charName == "Sru_Crab") then
		pos.y = pos.y - 6
		pos.x = pos.x - 32
		dcd = 59
	elseif (unit.charName == "SRU_Krug") then
		pos.x = pos.x - 42
		dcd = 80
	elseif ((unit.charName == "SRU_Razorbeak") or (unit.charName == "SRU_Murkwolf")) then
		pos.x = pos.x - 38
		dcd = 76
	elseif (unit.charName == "TT_Spiderboss") then
		pos.x = pos.x - 62
		dcd = 124
	elseif ((unit.charName == "Renekton") or (unit.charName == "Darius")) then
		pos.x = pos.x - 10.5
		pos.y = pos.y - 14
		_dd = 11
		dcd = ccd.x - pos.x - 8
	elseif (ccd) then
		pos.x = pos.x - 3.5
		pos.y = pos.y - 14
		_dd = 11
		dcd = ccd.x - pos.x - 8
	elseif (unit.charName:lower():find("mini")) then
		pos.y = pos.y - 0
		pos.x = pos.x - 26
		dcd = 92
	end
	if (unit.isMe) then
		pos.x = pos.x + 25
	end
	return pos, dcd, _dd
end
function GetHPBarPos2(unit)
	unit.barData = {
		PercentageOffset = {
			x = -0.05,
			y = 0
		},
	}
	local pos = GetUnitHPBarPos(unit)
	local offset = GetUnitHPBarOffset(unit)
	local percentOffset = {
		x = unit.barData.PercentageOffset.x,
		y = unit.barData.PercentageOffset.y
	}
	pos.x = math.floor(pos.x + (offset.x - 0.5 + percentOffset.x) * 171 + 31)
	pos.y = pos.y + (offset.y - 0.5 + percentOffset.y) * 52 + 42
	local vec1 = Vector(pos.x, pos.y, 0)
	local vec2 = Vector(pos.x + 108, pos.y, 0)
	return Vector(vec1.x, vec1.y, 0), Vector(vec2.x, vec2.y, 0)
end
--]]

function HasBlueBuff(unit)
	return UnitHasBuff("crestoftheacientgolem", unit)
end
function UnitHasBuff(name, unit)
	local unit = unit or myHero
	for i = 1, unit.buffCount or 0 do
		local buff = unit:getBuff(i)
		if (buff.valid and BuffIsValid(buff) and (buff.name:lower() == name:lower())) then
			return true
		end
	end
	return false
end
function UnitHasBuffOfType(buffType, unit)
	local unit = unit or myHero
	for i = 1, unit.buffCount or 0 do
		local buff = unit:getBuff(i)
		if (buff.valid and BuffIsValid(buff) and (buff.type == buffType)) then
			return true
		end
	end
	return false
end

function GetItemSlot(item)
	for slot = 6, 12 do
		local name = myHero:GetSpellData(slot).name
		if (name and (#name > 0) and (name:lower() == item:lower())) then
			return slot
		end
	end
	return nil
end
function GetWardSlot()
	for i = 1, #WardNames do
		local slot = GetItemSlot(WardNames[i])
		if (slot and SpellIsReady(slot)) then
			return slot
		end
	end
	return nil
end

function IsOnScreen(position)
	local pos = GetScreenPos(position)
	return OnScreen({ x = pos.x, y = pos.y }, { x = pos.x, y = pos.y })
end
function VectorOut(position, distance, from)
	local from = Vector(from or myHero)
	return from + (Vector(position) - from):normalized() * distance
end
function FindBush(x, y, z, distance, range)
	local pos = { x = x, z = z }
	local distance = distance and math.floor(distance / range) or VisionRange
	local range = range or 50
	local x = math.round(x / range) * range
	local z = math.round(z / range) * range
	local dist = 2
	local function CheckPos(posX, posZ)
		pos.x = x + posX * range
		pos.z = z + posZ * range
		return IsWallOfGrass(D3DXVECTOR3(pos.x, y, pos.z))
	end
	while (distance >= dist) do
		if (CheckPos(0, dist) or CheckPos(dist, 0) or ChechPos(0, -dist) or CheckPos(-dist, 0)) then
			return Vector(pos.x, y, pos.z)
		end
		local a = 1 - dist
		local b = 0
		local c = dist
		while (b < c - 1) do
			b = b + 1
			if (a < 0) then
				a = a + 1 + 2 * b
			else
				c = c - 1
				a = a + 1 + 2 * (b - c)
			end
			if (CheckPos(b, c) or CheckPos(-b, c) or CheckPos(b, -c) or CheckPos(-b, -c) or CheckPos(c, b) or CheckPos(-c, b) or CheckPos(c, -b) or CheckPos(-c, -b)) then
				return Vector(pos.x, y, pos.z)
			end
		end
		dist = dist + 1
	end
end
function GetScreenPos(position)
	return WorldToScreen(D3DXVECTOR3(position.x, position.y, position.z))
end
function PositionIsWall(pos1, pos2, pos3)
	return IsWall((pos2 and pos3) and D3DXVECTOR3(pos1, pos2, pos3) or D3DXVECTOR3(pos1.x, pos1.y, pos1.z))
end
function PositionIsGrass(pos1, pos2, pos3)
	return IsWallOfGrass((pos2 and pos3) and D3DXVECTOR3(pos1, pos2, pos3) or D3DXVECTOR3(pos1.x, pos1.y, pos1.z))
end

function CalcSpellDamage(target, spell)
	local damage = 0
	if (type(spell.Damage.Type) == "number") then
		damage = CalcTrueDamage(target, spell.Key, spell.Damage.Type, spell.Damage.Base, spell.Damage.PerLevel, spell.Damage.ScalingType, spell.Damage.ScalingStat, spell.Damage.ScalingPercent)
	elseif (type(spell.Damage.Type) == "table") then
		for i = 1, #spell.Damage.Type, 1 do
			damage = damage + CalcTrueDamage(target, spell.Key, spell.Damage.Type[i], spell.Damage.Base[i], spell.Damage.PerLevel[i], 0, 0, 0)
		end
		damage = damage + CalcTrueDamage(target, spell.Key, 0, 0, 0, spell.Damage.ScalingType, spell.Damage.ScalingStat, spell.Damage.ScalingPercent)
	end
	return damage
end
function CalcTrueDamage(target, key, damageType, baseDamage, perLevel, scalingType, scalingStat, percentScaling)
	local key = key or nil
	local damageType = damageType or DamageType.True
	local baseDamage = baseDamage or 0
	local perLevel = perLevel or 0
	local scalingType = scalingType or DamageType.True
	local scalingStat = scalingStat or ScalingStat.AP
	local percentScaling = percentScaling or 0
	local scalingDamage = 0
	if (type(scalingType) == "number") then
		scalingDamage = scalingDamage + CalcScalingDamage(target, scalingType, scalingStat, percentScaling)
	elseif (type(scalingType) == "table") then
		for i = 1, #scalingStat do
			scalingDamage = scalingDamage + CalcScalingDamage(target, scalingType[i], scalingStat[i], percentScaling[i])
		end
	end
	if (damageType == DamageType.Magic) then
		return myHero:CalcMagicDamage(target, baseDamage + perLevel * (key and myHero:GetSpellData(key).level or 0)) + scalingDamage
	elseif (damageType == DamageType.Physical) then
		return myHero:CalcDamage(target, baseDamage + perLevel * (key and myHero:GetSpellData(key).level or 0)) + scalingDamage
	elseif (damageType == DamageType.True) then
		return baseDamage + perLevel * (key < 4 and myHero:GetSpellData(key).level or 0) + scalingDamage
	end
	return 0
end
function CalcScalingDamage(target, scalingType, scalingStat, percentScaling)
	local amount = (ScalingFunctions[scalingStat] or function() return 0 end)(percentScaling)
	if (scalingType == DamageType.Magic) then
		return myHero:CalcMagicDamage(target, amount)
	elseif (scalingType == DamageType.Physical) then
		return myHero:CalcDamage(target, amount)
	elseif (scalingType == DamageType.True) then
		return amount
	end
	return 0
end

---//==================================================\\---
--|| > Drawing Functions                                ||--
---\===================================================//---

function DrawSmartText(text, size, x, y, color, halign, valign)
	local color = ParseColor(color, true)
	if (halign or valign) then
		DrawTextA(text, size, x, y, color, halign, valign)
	else
		DrawText(text, size, x, y, color)
	end
end
function DrawSmartRectangle(x, y, width, height, color)
	DrawRectangle(x, y, width, height, ParseColor(color, true))
end
function DrawSmartRectangleOutline(x, y, width, height, color, borderWidth)
	DrawRectangleOutline(x, y, width, height, ParseColor(color, true), borderWidth or 1)
end
function DrawSmartCircle(x, y, z, width, color)
	if (not DrawingIsOnScreen(x, y, z, width)) then return end
	local color = ParseColor(color, true)
	local lowFps
	if (DrawManager.Config) then
		if (DrawManager.Config.LowFps) then
			lowFps = DrawManager.Config.LowFps
		else
			lowFps = DrawManager.Config
		end
	end
	if (lowFps and lowFps.LFEnabled) then
		local quality = math.max(8, math.round(180 / math.deg(math.asin(lowFps.LFQuality / (2 * width)))))
		quality = 2 * math.pi / quality
		width = width * 0.92
		local points = { }
		for theta = 0, (2 * math.pi + quality), quality do
			local point = WorldToScreen(D3DXVECTOR3(x + width * math.cos(theta), y, z - width * math.sin(theta)))
			table.insert(points, D3DXVECTOR2(point.x, point.y))
		end
		DrawLines2(points, lowFps.LFWidth, color)
	else
		DrawCircle(x, y, z, width, color)
	end
end
function DrawCircleAt(position, width, color)
	DrawSmartCircle(position.x, position.y, position.z, width, color)
end
function DrawTextWithBorder(text, size, x, y, color, borderColor, borderWidth)
	local borderColor = borderColor or "Black"
	local borderWidth = borderWidth or 1
	DrawSmartText(text, size, x + borderWidth, y, borderColor)
	DrawSmartText(text, size, x - borderWidth, y, borderColor)
	DrawSmartText(text, size, x, y - borderWidth, borderColor)
	DrawSmartText(text, size, x, y + borderWidth, borderColor)
	DrawSmartText(text, size, x, y, color)
end
function DrawDamageOnHealthBar(unit, damage, mode, color)
	local amount = nil
	local pos, width, height = GetBarInfo(unit)
	if (mode == 1) then
		amount = damage / unit.maxHealth * width
	else
		local percent = 1 - damage / unit.health
		if (percent < 0) then
			percent = 0
		end
		amount = percent * (width * (unit.health / unit.maxHealth))
		if ((width == 76) or (width == 80) or (width == 59) or (width == 9)) then
			DrawSmartRectangle(pos.x, pos.y - 7, 2, height / 2, color)
		else
			DrawSmartRectangle(pos.x, pos.y - 3, 2, height / 2, color)
		end
	end
	if (amount) then
		DrawSmartRectangle(pos.x + amount, pos.y, 2, height, color)
	end
end
function DrawHealOnHealthBar(unit, heal, mode, color)
	if (mode == 2) then
		if (not HealthUnderPercent(99, unit)) then return end
		if (unit.health + heal > unit.maxHealth) then
			heal = unit.maxHealth - unit.health
		end
	end
	local amount
	local pos, width, height = GetBarInfo(unit)
	if (mode == 1) then
		amount = heal / unit.maxHealth * width
	else
		local percent = 1 + heal / unit.health
		if (percent > 2) then
			percent = 2
		end
		amount = percent * (width * (unit.health / unit.maxHealth))
		local amount2 = 1 * (width * (unit.health / unit.maxHealth))
		if ((width == 76) or (width == 80) or (width == 59) or (width == 9)) then
			DrawSmartRectangle(pos.x + amount2, pos.y - 7, 2, height / 2, color)
		else
			DrawSmartRectangle(pos.x + amount2, pos.y - 3, 2, height / 2, color)
		end
	end
	if (amount) then
		DrawSmartRectangle(pos.x + amount, pos.y, 2, height, color)
	end
end
function DrawSmartLineBorder3D(startX, startY, startZ, endX, endY, endZ, size, color, width)
	DrawLineBorder3D(startX, startY, startZ, endX, endY, endZ, size, ParseColor(color, true), width or 1)
end
function DrawLineBorder3DAt(pos1, pos2, size, color, width)
	DrawSmartLineBorder3D(pos1.x, pos1.y, pos1.z, pos2.x, pos1.y, pos2.z, size, color, width)
end
function DrawSmartLine(pos1, pos2, color, width)
	local wpoints = {
		[1] = WorldToScreen(D3DXVECTOR3(pos1.x, pos1.y, pos1.z)),
		[2] = WorldToScreen(D3DXVECTOR3(pos2.x, pos1.y, pos2.z)),
	}
	local spoints = {
		[1] = D3DXVECTOR2(wpoints[1].x, wpoints[1].y),
		[2] = D3DXVECTOR2(wpoints[2].x, wpoints[2].y),
	}
	DrawLines2(spoints, width or 1, ParseColor(color, true))
end
function DrawSmartCircle3D(x, y, z, width, color, quality)
	DrawCircle3D(x, y, z, width, ParseColor(color, true), quality or 1)
end
function DrawSmartCircle3DAt(pos, width, color, quality)
	DrawSmartCircle3D(pos.x, pos.y, pos.z, width, color, quality)
end
function DrawSphere(x, y, z, color, size, steps, quality)
	local size = size or 500
	local step = size / (steps or 10)
	local currentWidth = step
	for i = 1, size, step do
		DrawSmartCircle3D(x, y, z + i, currentWidth, color, quality)
		if (currentWidth > size / 2) then
			currentWidth = currentWidth - step
		else
			currentWidth = currentWidth + step
		end
	end
end
function DrawSphereAt(pos, color, size, steps, quality)
	DrawSphere(pos.x, pos.y, pos.z, color, size, steps, quality)
end
function DrawingIsOnScreen(x, y, z, width)
	return IsOnScreen(VectorOut(Vector(x, y, z), width, cameraPos))
end

---//==================================================\\---
--|| > ScriptInfo Class                                 ||--
---\===================================================//---

Class("ScriptInfo")
function ScriptInfo:__init()
	self.Name = DEFAULT_SCRIPT_NAME
	self.Version = DEFAULT_SCRIPT_VERSION
	self.Author = nil
	self.Variables = nil
	self.Date = nil
	self.LeagueVersion = nil
	self.IsPotionsScript = false
end
function ScriptInfo:GetSetting(setting)
	if (not self.Variables) then return false end
	local setting = _G[Format("{1}_{2}", self.Variables, setting)]
	if (setting == nil) then return false end
	return setting
end
function ScriptInfo:LoadToConfig(config)
	config:Info("Version", self.Version)
	config:Info("Build Date", self.Date)
	config:Info("Tested With LoL", self.LeagueVersion)
	config:Info("Author", self.Author)
end
ScriptInfo = ScriptInfo()

---//==================================================\\---
--|| > Script Class                                     ||--
---\===================================================//---

Class("Script")
function Script:__init()
	self.LoadMessages = { }
	self.EnableDebugMode = false
	self.DisableAutoUpdate = false
	self.DisableScriptStatus = false
	self.DisableBuyItem = false
	self.DisableLevelSpell = false
	self.DisableSkins = false
	self.JustUpdated = false
	self.LeagueVersion = string.match(GetGameVersion(), "<Releases/%d.%d%d>"):gsub("<Releases/", ""):gsub(">", "")
end
function Script:LoadSave(name)
	return GetSave(name and ScriptInfo.Variables.."_"..name or ScriptInfo.Variables)
end
function Script:LoadUserSettings()
	self.EnableDebugMode = ScriptInfo:GetSetting("EnableDebugMode")
	self.DisableScriptStatus = ScriptInfo:GetSetting("DisableScriptStatus")
	self.DisableAutoUpdate = ScriptInfo:GetSetting("DisableAutoUpdate")
	if (VIP_USER) then
		self.DisableBuyItem = ScriptInfo:GetSetting("DisableBuyItem")
		self.DisableLevelSpell = ScriptInfo:GetSetting("DisableLevelSpell")
		self.DisableSkins = ScriptInfo:GetSetting("DisableSkins")
	end
	if (self.EnableDebugMode) then
		PrintDebug = function(message) PrintLocal(message, MessageType.Debug) end
		Assert = DAssert
	end
end
function Script:LoadScriptStatusKey(key)
	if (self.DisableScriptStatus) then return end
	assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), "ScriptStatus", "b", _ENV))()
	ScriptStatus(key)
end
function Script:AddLoadMessage(message)
	table.insert(self.LoadMessages, message)
end
function Script:ShowLoadMessage()
	local loadMessage = Format("Version {1} loaded successfully!", ScriptInfo.Version)
	for i = 1, #self.LoadMessages do
		loadMessage = Format("{1} {2}", loadMessage, self.LoadMessages[i])
	end
	PrintLocal(loadMessage)
end
Script = Script()

---//==================================================\\---
--|| > Updater Class                                    ||--
---\===================================================//---

Class("Updater")
function Updater:__init()
	self.Host = nil
	self.ScriptPath = nil
	self.VersionPath = nil
end
function Updater:UpdateLibrary()
	return self:CheckForUpdate(LIB_VERSION, UpdateHost.GitHub, "DevnBoL/Scripts/master/Common/GodLib.lua", "DevnBoL/Scripts/master/Versions/GodLib.version", LIB_PATH.."GodLib.lua", "GodLib")
end
function Updater:UpdateScript()
	return self:CheckForUpdate(ScriptInfo.Version, self.Host, self.ScriptPath, self.VersionPath)
end
function Updater:CheckForUpdate(version, host, scriptPath, versionPath, localPath, name)
	if (GetInGameTimer() >= UPDATE_SAFE_TIMER) then return end
	local localPath = localPath or SCRIPT_PATH..FILE_NAME
	local latestVersion = SafeWebResult(host, versionPath)
	if (not latestVersion) then
		if (not Script.DisableAutoUpdate) then
			PrintLocal(Format("Error reading latest{1} version, cannot update library!", name and " "..name or ""), MessageType.Warning)
		end
		return
	end
	if (tonumber(latestVersion:sub(1, #latestVersion - 1)) > tonumber(version)) then
		PrintLocal(Format("Downloading{1} version {2}, please don't reload the script (F9)...", name and " "..name or "", latestVersion))
		local alerter = NotificationAlert(Format("{1}: Downloading version {2}...", name or Script.Name, latestVersion))
		DownloadFile(Format("{1}/{2}", host, scriptPath), localPath, function()
			PrintLocal(Format("Finished downloading latest{1} version, please reload the script to load it (double F9)!", name and " "..name or ""))
			alerter:Remove()
			NotificationAlert(Format("{1}: Finished downloading latest update!", name or Script.Name))
		end)
	end
end
Updater = Updater()

---//==================================================\\---
--|| > RequiredLibraries Class                          ||--
---\===================================================//---

Class("RequiredLibraries")
function RequiredLibraries:__init()
	self.Alerter = nil
	self.List = { }
end
function RequiredLibraries:Add(library, url, sacWillDownload)
	if (type(library) == "string") then
		table.insert(self.List, { Name = library, Url = url, IsSac = sacWillDownload })
	else
		table.insert(self.List, { Name = library[1], Url = library[2], IsSac = library[3] })
	end
end
function RequiredLibraries:Load()
	local downloads = 0
	local toDownload = { }
	for i = 1, #self.List do
		local library = self.List[i]
		local path = Format("{1}{2}.lua", LIB_PATH, library.Name)
		if (not FileExist(path)) then
			downloads = downloads + 1
			if (downloads == 1) then
				self.Alerter = NotificationAlert("Downloading required libraries...")
				PrintLocal("Downloading required libraries, please don't reload the script...")
			end
			DownloadFile(library.Url, path, function()
				downloads = downloads - 1
				if (downloads == 0) then
					self.Alerter:Remove()
					self.Alerter = NotificationAlert("Finished downloading required libraries!")
					PrintLocal("Finished downloading required libraries! Please reload the script (double F9)...")
				end
			end)
		end
	end
	if (downloads == 0) then
		for i = 1, #self.List do
			local library = self.List[i]
			if ((library.Name ~= "SxOrbWalk") or not Orbwalker.SacLoaded) then
				require(library.Name)
			end
		end
		return true
	end
	return false
end
RequiredLibraries = RequiredLibraries()

---//==================================================\\---
--|| > Orbwalker Class                                  ||--
---\===================================================//---

Class("Orbwalker")
function Orbwalker:__init()
	self.__AddedProcessAttackCallback = false
	self.Config = nil
	self.SacFound = _G.Reborn_Loaded
	self.SacLoaded = false
	self.AddedSacLoadMessage = false
	self.Attacking = false
	self.Ready = false
	self.AttackWindUp = 0
	self.Keys = {
		Combo = false,
		Harass = false,
		LastHit = false,
		LaneClear = false,
		Jungle = false,
	}
	self.Callbacks = {
		BeforeAttack = { },
		OnAttack = { },
		AfterAttack = { },
		ProcessAttack = { },
	}
end
function Orbwalker:__BeforeAttack(target)
	for i = 1, #self.Callbacks.BeforeAttack do
		self.Callbacks.BeforeAttack[i](target)
	end
end
function Orbwalker:__OnAttack(target)
	self.Attacking = true
	DelayAction(function()
		self.Attacking = false
	end, ORBWALKER_ATTACK_RESET) -- Safety reset incase 'OnAfterAttack' doesn't get called.
	for _, callback in ipairs(self.Callbacks.OnAttack) do
		callback(target)
	end
end
function Orbwalker:__AfterAttack(target)
	self.Attacking = false
	for _, callback in ipairs(self.Callbacks.AfterAttack) do
		callback(target)
	end
end
function Orbwalker:__InitSac(disableSacSpells)
	if (not self.AddedSacLoadMessage) then Script:AddLoadMessage("SAC:R support loaded!") end
	if (_G.Reborn_Initialised) then
		if (disableSacSpells) then _G.AutoCarry.Skills:DisableAll() end
		_G.AutoCarry.Plugins:RegisterPreAttack(function(target) self:__BeforeAttack(target) end)
		_G.AutoCarry.Plugins:RegisterOnAttacked(function(target)
			self:__OnAttack(target)
			DelayAction(function()
				self:__AfterAttack(target)
			end, self.AttackWindUp + GetLatency() / 2000)
		end)
		_G.GodLib_SacAlerter:Remove()
		self.Ready = true
		self.SacLoaded = true
	else
		if (not _G.GodLib_SacAlerter) then
			_G.GodLib_SacAlerter = NotificationAlert("Waiting for SAC:R...")
		end
		DelayAction(function()
			self:__InitSac(disableSacSpells)
		end, 1)
	end
end
function Orbwalker:Initialize(disableSacSpells)
	self.SacFound = _G.Reborn_Loaded
	if (not self.SacFound) then
		self.Ready = true
		SxOrb:RegisterBeforeAttackCallback(function(target) self:__BeforeAttack(target) end)
		SxOrb:RegisterOnAttackCallback(function(target) self:__OnAttack(target) end)
		SxOrb:RegisterAfterAttackCallback(function(target) self:__AfterAttack(target) end)
	else
		self:__InitSac(disableSacSpells)
	end
	return self
end
function Orbwalker:GetAASpell()
	local spell = SpellData("AA", nil, "Auto-Attack", self:GetRange())
	spell:SetDamage(DamageType.Physical, 0, 0, DamageType.Physical, ScalingStat.AttackDamage, 1)
	spell:SetIsReadyCallback(function() return self:CanAttack() end)
	return spell
end
function Orbwalker:AddBeforeAttackCallback(callback)
	table.insert(self.Callbacks.BeforeAttack, callback)
	return self
end
function Orbwalker:AddAttackCallback(callback)
	table.insert(self.Callbacks.OnAttack, callback)
	return self
end
function Orbwalker:AddAfterAttackCallback(callback)
	table.insert(self.Callbacks.AfterAttack, callback)
	return self
end
function Orbwalker:AddProcessAttackCallback(callback)
	if (not self.__AddedProcessAttackCallback) then
		AddProcessAttackCallback(function(unit, attack)
			if (unit and unit.isMe) then
				self.AttackWindUp = attack.windUpTime
			end
			for i = 1, #self.Callbacks.ProcessAttack do
				self.Callbacks.ProcessAttack[i](unit, attack, attack.target)
			end
		end)
		--[[ Old code.
		AddProcessSpellCallback(function(unit, spell)
			if (unit and spell.name:lower():find("attack")) then
				if (unit.isMe) then
					self.AttackWindUp = spell.windUpTime
				end
				for _, callback in ipairs(self.Callbacks.ProcessAttack) do
					callback(unit, spell, spell.target)
				end
			end
		end)
		--]]
		self.__AddedProcessAttackCallback = true
	end
	table.insert(self.Callbacks.ProcessAttack, callback)
	return self
end
function Orbwalker:LoadToConfig(config, onlySac)
	local oconfig
	if (self.SacFound) then
		oconfig = config:Menu("Orbwalker", "SAC:R Settings")
		oconfig:Toggle("Bind", "Bind Keys to SAC (Requires Reload)", false)
	elseif (not onlySac and SxOrb) then
		oconfig = config:Menu("Orbwalker", "Orb-Walker Settings")
		SxOrb:LoadToMenu(oconfig)
	end
	self.Config = oconfig
end
function Orbwalker:ForceTarget(target)
	if (self.SacLoaded) then
		_G.AutoCarry.Crosshair.Attack_Crosshair.target = target
	elseif (SxOrb) then
		SxOrb:ForceTarget(target)
	end
end
function Orbwalker:ResetAutoAttack()
	if (self.SacLoaded) then
		_G.AutoCarry.Orbwalker:ResetAttackTimer()
	elseif (SxOrb) then
		SxOrb:ResetAA()
	end
end
function Orbwalker:Attack(unit, reset)
	if (reset) then self:ResetAutoAttack() end
	if (self.SacLoaded) then
		_G.AutoCarry.MyHero:Attack(unit)
	elseif (SxOrb) then
		SxOrb:Attack(unit)
	end
end
function Orbwalker:GetRange()
	if (self.SacLoaded) then
		return _G.AutoCarry.MyHero.TrueRange
	elseif (SxOrb) then
		return SxOrb:Range(myHero)
	end
	return myHero.range
end
function Orbwalker:CanAttack()
	if (self.SacLoaded) then
		return not _G.AutoCarry.Orbwalker:IsShooting()
	elseif (SxOrb) then
		return SxOrb:CanAttack()
	end
	return false
end
function Orbwalker:IsAttacking()
	if (self.SacLoaded) then return _G.AutoCarry.Orbwalker:IsShooting() end
	return self.Attacking
end
function Orbwalker:ShouldHold()
	if (self.SacLoaded) then return _G.AutoCarry.MyHero:ShouldHold() end
	return false
end
Orbwalker = Orbwalker()

---//==================================================\\---
--|| > ModeHandler Class                                ||--
---\===================================================//---

Class("ModeHandler")
function ModeHandler:__init()
	self.CanPerformCombo = false
	self.CanPerformHarass = false
	self.CanPerformLastHit = false
	self.CanPerformLaneClear = false
	self.CanPerformJungle = false
	self.Keys = {
		Combo = false,
		Harass = false,
		LastHit = false,
		LaneClear = false,
		Jungle = false,
	}
end
function ModeHandler:LoadToConfig(config, combo, harass, lastHit, laneClear, jungleClear, singleMode)
	self.CanPerformCombo, self.CanPerformHarass, self.CanPerformLastHit, self.CanPerformLaneClear, self.CanPerformJungle = combo, harass, lastHit, laneClear, jungleClear
	if (Orbwalker.SacFound and Orbwalker.Config and Orbwalker.Config.Bind) then
		config = config:Menu("Keys", "Script Key-Bindings")
		config:Note("Keys are binded to SAC:R!")
		AddTickCallback(function()
			if (not Orbwalker.SacLoaded) then
				self.Keys.Combo = false
				self.Keys.Harass = false
				self.Keys.LastHit = false
				self.Keys.LaneClear = false
				self.Keys.Jungle = false
			else
				self.Keys.Combo = self.CanPerformCombo and _G.AutoCarry.Keys.AutoCarry or false
				self.Keys.Harass = self.CanPerformHarass and _G.AutoCarry.Keys.MixedMode or false
				self.Keys.LastHit = self.CanPerformLastHit and _G.AutoCarry.Keys.LastHit or false
				self.Keys.LaneClear = self.CanPerformLaneClear and _G.AutoCarry.Keys.LaneClear or false
				self.Keys.Jungle = self.CanPerformJungle and _G.AutoCarry.Keys.LaneClear or false
				if (singleMode) then
					if (self.Keys.Combo) then
						self.Keys.Harass = false
						self.Keys.LastHit = false
						self.Keys.LaneClear = false
						self.Keys.Jungle = false
					elseif (self.Keys.Harass) then
						self.Keys.LastHit = false
						self.Keys.LaneClear = false
						self.Keys.Jungle = false
					elseif (self.Keys.Jungle) then
						self.Keys.LaneClear = false
						self.Keys.LastHit = false
					elseif (self.Keys.LaneClear) then
						self.Keys.LastHit = false
					end
				end
			end
		end)
	else
		config = config:Menu("Keys", "Script Key-Bindings")
		local first = false
		if (combo) then
			first = true
			config:Dynamic("Combo", "Combo Mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		end
		if (harass) then
			if (first) then
				config:Separator()
			else
				first = true
			end
			config:Dynamic("Harass", "Harass Mode", SCRIPT_PARAM_ONKEYDOWN, false, "T")
		end
		if (lastHit) then
			if (first) then
				config:Separator()
			else
				first = true
			end
			config:Dynamic("LastHit", "Last-Hit Mode", SCRIPT_PARAM_ONKEYDOWN, false, "Z")
		end
		if (laneClear) then
			if (first) then
				config:Separator()
			else
				first = true
			end
			config:Dynamic("LaneClear", "Lane-Clear Mode", SCRIPT_PARAM_ONKEYDOWN, false, "C")
		end
		if (jungleClear) then
			if (first) then
				config:Separator()
			else
				first = true
			end
			config:Dynamic("Jungle", "Jungle Mode", SCRIPT_PARAM_ONKEYDOWN, false, "V")
		end
		self.Keys = config
		if (singleMode) then
			AddTickCallback(function()
				if (self.Keys.Combo) then
					self.Keys.Harass = false
					self.Keys.LastHit = false
					self.Keys.LaneClear = false
					self.Keys.Jungle = false
				elseif (self.Keys.Harass) then
					self.Keys.LastHit = false
					self.Keys.LaneClear = false
					self.Keys.Jungle = false
				elseif (self.Keys.Jungle) then
					self.Keys.LaneClear = false
					self.Keys.LastHit = false
				elseif (self.Keys.LaneClear) then
					self.Keys.LastHit = false
				end
				self.Keys:Save()
			end)
		end
	end
end
ModeHandler = ModeHandler()

---//==================================================\\---
--|| > Prediction Class                                 ||--
---\===================================================//---

Class("Prediction")
function Prediction:__init()
	self.Config = nil
	self.CurrentPrediction = 1
	self.AvailablePredictions = { }
	self.DPredTargets = { }
	self.Base = {
		["VPrediction"] = nil,
		["DPrediction"] = nil,
		["HPrediction"] = nil,
		["SPrediction"] = nil,
	}
end
function Prediction:__GetDPredTarget(target)
	if (not self.DPredTargets[target.networkID]) then
		self.DPredTargets[target.networkID] = DPTarget(target)
	end
	return self.DPredTargets[target.networkID]
end
function Prediction:Initialize()
	if (FileExist(LIB_PATH.."VPrediction.lua")) then
		table.insert(self.AvailablePredictions, "VPrediction")
	end
	if (FileExist(LIB_PATH.."HPrediction.lua")) then
		table.insert(self.AvailablePredictions, "HPrediction")
	end
	if (FileExist(LIB_PATH.."SPrediction.lua")) then
		table.insert(self.AvailablePredictions, "SPrediction")
	end
	if (VIP_USER and FileExist(LIB_PATH.."DivinePred.lua") and FileExist(LIB_PATH.."DivinePred.luac")) then
		table.insert(self.AvailablePredictions, "DivinePred")
	end
end
function Prediction:GetActivePrediction()
	return self.AvailablePredictions[self.CurrentPrediction]
end
function Prediction:GetPredictedHealth(unit, waittime)
	local waittime = waittime or 1
	local activePrediction = self:GetActivePrediction()
	if (activePrediction == "HPrediction") then
		return self.Base.HPrediction:PredictHealth(unit, waittime)
	elseif (self.Base.VPrediction) then
		return self.Base.VPrediction:GetPredictedHealth(unit, waittime)
	end
	return unit.health
end
function Prediction:GetPrediction(unit, data, from)
	local function CheckHitchance(hitchance)
		if (hitchance >= 1.2) then
			return Hitchance.High
		elseif (hitchance >= 0.6) then
			return Hitchance.Medium
		elseif (hitchance > 0) then
			return Hitchance.Low
		end
		return Hitchance.None
	end
	if (not unit) then return Vector(unit), Hitchance.None, Vector(unit) end
	local from = from or myHero
	local castPos, hitchance, pos = Vector(unit), Hitchance.None, Vector(unit)
	local activePrediction = self:GetActivePrediction()
	if (activePrediction == "VPrediction") then
		if (data.Type == SkillshotType.Linear) then
			castPos, hitchance, pos = self.Base.VPrediction:GetLineCastPosition(unit, data.Delay, data.Width, data.Range, data.Speed, from, data.Collision)
		elseif (data.Type == SkillshotType.Circular) then
			castPos, hitchance, pos = self.Base.VPrediction:GetCircularCastPosition(unit, data.Delay, data.Width, data.Range, data.Speed, from, data.Collision)
		elseif (data.Type == SkillshotType.Cone) then
			castPos, hitchance, pos = self.Base.VPrediction:GetConeAOECastPosition(unit, data.Delay, data.Width, data.Range, data.Speed, from, data.Collision)
		end
	elseif (activePrediction == "DivinePred") then
		_, castPos, hitchance = self.Base.DPrediction:predict(self:__GetDPredTarget(unit), data:GetDSkillshot(), self.Config.DPredPrecision, Vector(from))
		hitchance = CheckHitchance(hitchance)
	elseif (activePrediction == "HPrediction") then
		local hdata = data:GetHSkillshot()
		castPos, hitchance = self.Base.HPrediction:GetPredict(HPSkillshot(hdata), unit, from, hdata.CollisionN)
		hitchance = CheckHitchance(hitchance)
	elseif (activePrediction == "SPrediction") then
		castPos, hitchance, pos = self.Base.SPrediction:Predict(unit, data.Range, data.Speed, data.Delay, data.Width, data.Collision, from)
	end
	return castPos, hitchance, pos
end
function Prediction:GetAoePrediction(unit, data, from)
	local from = from or myHero
	local points = { }
	local castPos, hitchance, pos = self:GetPrediction(unit, data, from)
	local mainCastPos, mainHitchance, mainPos = castPos, hitchance, pos
	table.insert(points, pos)
	local enemies = GetEnemiesInRange(data.Range + data.Radius)
	for i = 1, #enemies do
		local enemy = enemies[i]
		if (enemy.networkID ~= unit.networkID) then
			castPos, hitchance, pos = self:GetPrediction(enemies[i], data, from)
			if (InRange(pos, data.Range + data.Radius) and (hitchance >= Hitchance.Low)) then
				table.insert(points, pos)
			end
		end
	end
	while (#points > 1) do
		local mec = MEC(points)
		local circle = mec:Compute()
		if (circle.radius <= data.Radius + GetHitBox(unit) - 8) then
			return circle.center, mainHitchance, #points
		end
		local maxDistance = -1
		local maxDistanceIndex = 0
		for i = 2, #points do
			local distance = GetDistanceSqr(points[i], points[1])
			if ((distance > maxDistance) or (maxDistance == -1)) then
				maxDistanceIndex = i
				maxDistance = distance
			end
		end
		table.remove(points, maxDistanceIndex)
	end
	return mainCastPos, mainHitchance, #points
end
function Prediction:GetHit(position, data, from)
	local from = from or myHero
	local hit = { }
	local enemies = GetEnemiesInRange(data.Range)
	for i = 1, #enemies do
		castPos, hitchance, pos = self:GetPrediction(enemies[i], data, from)
		if (InRange(pos, data.Radius, position) and (hitchance >= Hitchance.Low)) then
			table.insert(hit, enemies[i])
		end
	end
	return hit
end
function Prediction:CheckCollision(unit, data, from)
	local from = from or myHero
	local activePrediction = self:GetActivePrediction()
	if (activePrediction == "HPrediction") then
		return self.Base.HPrediction:CollisionStatus(data:GetHSkillshot(), unit, from, unit)
	else
		local castPos, hitchance, pos = self:GetPrediction(unit, data, from)
		if (castPos and (hitchance >= Hitchance.Low)) then
			return true
		end
	end
	return false
end
function Prediction:GetPosition(unit, data, from)
	local from = from or myHero
	local activePrediction = self:GetActivePrediction()
	local pos = unit.pos
	if (activePrediction == "VPrediction") then
		_, _, pos = self.Base.VPrediction:GetPredictedPos(unit, data.Delay, data.Speed, from, false)
	elseif (activePrediction == "SPrediction") then
		pos, _ = self.Base.SPrediction:PredictPos(unit, data.Speed, data.Delay)
	else
		_, _, pos = self:GetPrediction(unit, data, from)
	end
	return pos
end
function Prediction:LoadToConfig(config)
	if (#self.AvailablePredictions == 0) then return end
	config:DropDown("CurrentPrediction", "Prediction to Use (Requires Reload)", self.CurrentPrediction, self.AvailablePredictions)
	self.CurrentPrediction = config.CurrentPrediction
	local activePrediction = self:GetActivePrediction()
	if (activePrediction == "VPrediction") then
		require("VPrediction")
		self.Base.VPrediction = VPrediction()
	elseif (activePrediction == "HPrediction") then
		require("HPrediction")
		self.Base.HPrediction = HPrediction()
	elseif (activePrediction == "SPrediction") then
		require("SPrediction")
		self.Base.SPrediction = SPrediction()
	elseif (activePrediction == "DivinePred") then
		require("DivinePred")
		self.Base.DPrediction = DivinePred()
		config:Slider("DPredPrecision", "DivinePred Precision", 1.2, 1, 1.5, 1)
	end
	self.Config = config
end
Prediction = Prediction()

---//==================================================\\---
--|| > RecallTracker Class                              ||--
---\===================================================//---

Class("RecallTracker")
function RecallTracker:__init()
	self.IsTracking = false
	self.IsRecalling = false
	self.Callbacks = {
		StartRecall = { },
		CancelRecall = { },
		FinishRecall = { },
	}
end
function RecallTracker:__OnStartRecall()
	for i = 1, #self.Callbacks.StartRecall do
		self.Callbacks.StartRecall[i]()
	end
end
function RecallTracker:__OnCancelRecall()
	for i = 1, #self.Callbacks.CancelRecall do
		self.Callbacks.CancelRecall[i]()
	end
end
function RecallTracker:__OnFinishRecall()
	for i = 1, #self.Callbacks.FinishRecall do
		self.Callbacks.FinishRecall[i]()
	end
end
function RecallTracker:Initialize()
	self.IsTracking = true
	AddCreateObjCallback(function(object)
		if (InRange(object, MAX_OBJ_DISTANCE) and object.name:find("TeleportHome")) then
			PrintDebug("Champion started recalling...")
			self.IsRecalling = true
			self:__OnStartRecall()
		end
	end)
	AddDeleteObjCallback(function(object)
		if (InRange(object, MAX_OBJ_DISTANCE) and object.name:find("TeleportHome")) then
			self.IsRecalling = true
			DelayAction(function()
				if (InFountain()) then
					PrintDebug("Champion finished recalling!")
					self:__OnFinishRecall()
				else
					PrintDebug("Champion cancelled recall!")
					self:__OnCancelRecall()
				end
			end)
		end
	end)
	return self
end
function RecallTracker:AddStartRecallCallback(callback)
	table.insert(self.Callbacks.StartRecall, callback)
	return self
end
function RecallTracker:AddCancelRecallCallback(callback)
	table.insert(self.Callbacks.CancelRecall, callback)
	return self
end
function RecallTracker:AddFinishRecallCallback(callback)
	table.insert(self.Callbacks.FinishRecall, callback)
	return self
end
RecallTracker = RecallTracker()

---//==================================================\\---
--|| > AutoBuy Class                                    ||--
---\===================================================//---

Class("AutoBuy")
function AutoBuy:__init()
	self.Config = nil
	self.StartTrinket = 1
	self.StartOrder = 1
	self.TrinketList = { }
	self.ItemOrders = { }
	self.BuyItem = {
		["5.19"] = _G.BuyItem,
		["5.20"] = nil,
	}
end
function AutoBuy:Initialize(defaultOrder)
	self.StartOrder = defaultOrder or 1
	self:AddTrinket("Warding Totem", 3596)
	self:AddTrinket("Sweeping Lens", 3597)
	self:AddTrinket("Scrying Orb", 3598)
	self:AddItemOrder("Doran's Ring + 2 HP Pots", { 1312, 2003, 2003 })
	self:AddItemOrder("Doran's Blade + HP Pot", { 1311, 2003 })
	self:AddItemOrder("Flask + 3 HP Pots", { 2041, 2003, 2003, 2003 })
	self:AddItemOrder("Machete + 2 HP Pots", { 1295, 2003, 2003 })
end
function AutoBuy:AddTrinket(name, id, default)
	table.insert(self.TrinketList, {
		Name = name,
		ID = id,
	})
	if (default) then
		self.StartTrinket = #self.TrinketList
	end
end
function AutoBuy:AddItemOrder(name, order, default)
	table.insert(self.ItemOrders, {
		Name = name,
		Order = order,
	})
	if (default) then
		self.StartOrder = #self.ItemOrders
	end
end
function AutoBuy:LoadToConfig(config)
	local autobuy = config:Menu("AutoBuy", "Auto-Buy Starting Items")
	if (Script.DisableBuyItem) then
		autobuy:Note("Currently disabled!")
		return
	elseif (not self.BuyItem[Script.LeagueVersion]) then
		autobuy:Note("BuyItem is not working!")
		return
	end
	autobuy:Toggle("Enabled", "Buy Items at Start of the Game", true)
	autobuy:Slider("Delay", "Delay Between Purchases (Sec)", 1, 1, 3)
	autobuy:Separator()
	local trinkets = { }
	for i = 1, #self.TrinketList do
		table.insert(trinkets, self.TrinketList[i].Name)
	end
	autobuy:DropDown("Trinket", "Trinket to Buy", self.StartTrinket, trinkets)
	if (#self.ItemOrders > 1) then
		local orders = { }
		local index = self.StartOrder + 1
		table.insert(orders, "Automatic")
		for i = 1, #self.ItemOrders do
			table.insert(orders, self.ItemOrders[i].Name)
		end
		autobuy:DropDown("Order", "Items to Buy", index, orders)
	end
	autobuy:Separator()
	autobuy:Note2("Automatic:")
	autobuy:Note2("  - AP Runes - Doran's Ring + 2 HP Pots")
	autobuy:Note2("  - AD Runes - Doran's Blade + HP Pot")
	autobuy:Note2("  - Smite       - Machete + 3 HP Pots")
	self.Config = autobuy
end
function AutoBuy:BuyStartingItems(delay)
	if (not self.Config.Enabled) then return end
	if (GetGame().map.shortName ~= "summonerRift") then
		PrintLocal("Auto-buy starting items does not support this map!", MessageType.Warning)
		return
	end
	DelayAction(function()
		if (InFountain() and (myHero:getInventorySlot(ITEM_7) == 0)) then
			BuyItem(self.TrinketList[self.Config.Trinket].ID)
			local order = { }
			if (self.Config.Order == 1) then
				if (GetSummonerSlot("SummonerSmite")) then
					PrintDebug("Auto-buying jungle starting items...")
					order = self.ItemOrders[5].Order
				elseif (myHero.ap >= 5) then
					PrintDebug("Auto-buying AP starting items...")
					order = self.ItemOrders[2].Order
				else
					PrintDebug("Auto-buying AD starting items...")
					order = self.ItemOrders[3].Order
				end
			else
				order = self.ItemOrders[self.Config.Order - 1].Order
			end
			for i = 1, #order do
				DelayAction(function()
					WorkingBuyItem(order[i])
				end, self.Config.Delay * i)
			end
		end
	end, delay or 2)
end
AutoBuy = AutoBuy()

---//==================================================\\---
--|| > DrawManager Class                                ||--
---\===================================================//---

Class("DrawManager")
function DrawManager:__init()
	self.Config = nil
end
function DrawManager:LoadToConfig(config, canDisable, noLowFps, sameConfig)
	if (not sameConfig) then config:Separator() end
	if (canDisable == nil) then canDisable = true end
	if (canDisable) then
		config:Toggle("Disabled", "Disable All Drawing", false)
	else
		config.Disabled = false
	end
	if (not noLowFps) then
		local config = sameConfig and config or config:Menu("LowFps", "Low FPS Drawing Options")
		if (sameConfig and canDisable) then config:Separator() end
		config:Toggle("LFEnabled", "Use Low FPS Drawing", false)
		config:Slider("LFWidth", "Circle Width", 1, 1, 10)
		config:Slider("LFQuality", "Circle Quality", 75, 75, 500)
	end
	self.Config = config
end
function DrawManager:CanDraw()
	if (not self.Config) then return true end
	return not self.Config.Disabled
end
DrawManager = DrawManager()

---//==================================================\\---
--|| > Selector Class                                   ||--
---\===================================================//---

Class("Selector")
function Selector:__init()
	self.Config = nil
	self.EnemyConfig = nil
	self.Target = nil
	self.SelectedTarget = nil
	self.Mode = 1
	self.Range = 1
	self.Targets = { }
	self.SelectorModes = { }
	self.AllyCount = #GetAllyHeroes()
	self.EnemyCount = #GetEnemyHeroes()
	self.Callbacks = {
		TargetSelected = { },
		TargetDeselected = { },
		TargetLost = { },
	}
	self.EnemyPriorityOrder = {
		[1] = { 1, 1, 1, 1, 1 },
		[2] = { 1, 1, 2, 2, 2 },
		[3] = { 1, 1, 2, 2, 3 },
		[4] = { 1, 1, 2, 3, 4 },
		[5] = { 1, 2, 3, 4, 5 },
	}
	self.AllyPriorityOrder = {
		[1] = { 2, 2, 2, 2, 2 },
		[2] = { 2, 2, 3, 3, 3 },
		[3] = { 2, 2, 3, 3, 4 },
		[4] = { 2, 2, 4, 3, 5 },
	}
	self.PriorityTable = {
		["ADC"] = { "Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir", "Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo","Zed" },
		["APC"] = { "Azir", "Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus", "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna", "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "VelKoz", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra" },
		["Support"] = { "Bard", "Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum", "TahmKench" },
		["Bruiser"] = { "Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Gnar", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy", "Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao" },
		["Tank"] = { "Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear", "Warwick", "Yorick", "Zac" }
	}
	self.PriorityIndex = {
		["ADC"] = 1,
		["APC"] = 2,
		["Support"] = 3,
		["Bruiser"] = 4,
		["Tank"] = 5,
	}
	self:RegisterMode("LessCastMagic", "Less Cast (Magic)", function(a, b) return (CalcTrueDamage(a, nil, DamageType.Magic, 100, nil, nil, nil, nil) / a.health) > (CalcTrueDamage(b, nil, DamageType.Magic, 100, nil, nil, nil, nil) / b.health) end)
	self:RegisterMode("LessCastPhysical", "Less Cast (Physical)", function(a, b) return (CalcTrueDamage(a, nil, DamageType.Physical, 100, nil, nil, nil, nil) / a.health) > (CalcTrueDamage(b, nil, DamageType.Physical, 100, nil, nil, nil, nil) / b.health) end)
	self:RegisterMode("LessCastMixed", "Less Cast (Mixed)", function(a, b) return ((CalcTrueDamage(a, nil, DamageType.Magic, 50, nil, nil, nil, nil) + CalcTrueDamage(a, nil, DamageType.Physical, 50, nil, nil, nil, nil)) / a.health) > ((CalcTrueDamage(b, nil, DamageType.Magic, 50, nil, nil, nil, nil) + CalcTrueDamage(b, nil, DamageType.Physical, 50, nil, nil, nil, nil)) / b.health) end)
	self:RegisterMode("PriorityLessCastMagic", "Priority Less Cast (Magic)", function(a, b) return (GetPriority(a) * (CalcTrueDamage(a, nil, DamageType.Magic, 100, nil, nil, nil, nil) / a.health)) > (GetPriority(b) * (CalcTrueDamage(b, nil, DamageType.Magic, 100, nil, nil, nil, nil) / b.health)) end)
	self:RegisterMode("PriorityLessCastPhysical", "Priority Less Cast (Physical)", function(a, b) return (GetPriority(a) * (CalcTrueDamage(a, nil, DamageType.Physical, 100, nil, nil, nil, nil) / a.health)) > (GetPriority(b) * (CalcTrueDamage(b, nil, DamageType.Physical, 100, nil, nil, nil, nil) / b.health)) end)
	self:RegisterMode("PriorityLessCastMixed", "Priority Less Cast (Mixed)", function(a, b) return (GetPriority(a) * ((CalcTrueDamage(a, nil, DamageType.Magic, 50, nil, nil, nil, nil) + CalcTrueDamage(a, nil, DamageType.Physical, 50, nil, nil, nil, nil)) / a.health)) > (GetPriority(b) * ((CalcTrueDamage(b, nil, DamageType.Magic, 50, nil, nil, nil, nil) + CalcTrueDamage(b, nil, DamageType.Physical, 50, nil, nil, nil, nil)) / b.health)) end)
	self:RegisterMode("LessHealth", "Less Health", function(a, b) return a.health < b.health end)
	self:RegisterMode("Priority", "Priority", function(a, b) return GetPriority(a) > GetPriority(b) end)
	self:RegisterMode("NearMouse", "Near Mouse", function(a, b) return GetDistanceSqr(mousePos, a) < GetDistanceSqr(mousePos, b) end)
end
function Selector:__OnTargetSelected(target)
	PrintLocal(Format("Selected target: {1}", target.charName))
	for i = 1, #self.Callbacks.TargetSelected do
		self.Callbacks.TargetSelected[i](target)
	end
end
function Selector:__OnTargetDeselected(target)
	for i = 1, #self.Callbacks.TargetDeselected do
		self.Callbacks.TargetDeselected[i](target)
	end
end
function Selector:__OnTargetLost(target)
	for i = 1, #self.Callbacks.TargetLost do
		self.Callbacks.TargetLost[i](target)
	end
end
function Selector:__OnWndMsg(message, key)
	if (not self.Config.Selected or (message ~= WM_LBUTTONDOWN)) then return  end
	local closestDist = 0
	local unit = nil
	local enemies = GetEnemiesInRange(115, mousePos)
	for i = 1, #enemies do
		local enemy = enemies[i]
		local distance = GetDistance(enemy, mousePos)
		if (IsValid(enemy) and (not unit or (closestDist < distance))) then
			unit = enemy
			closestDist = distance
		end
	end
	if (unit) then
		if (self.SelectedTarget and (self.SelectedTarget.charName == unit.charName)) then
			self.SelectedTarget = nil
			self:__OnTargetDeselected(unit)
			PrintLocal(Format("De-selected target: {1}", unit.charName))
		else
			if (self.SelectedTarget) then self:__OnTargetLost(self.SelectedTarget) end
			self.SelectedTarget = unit
			self:__OnTargetSelected(unit)
			PrintLocal(Format("Selected target: {1}", unit.charName))
		end
	end
end
function Selector:__OnTick()
	if (self.SelectedTarget and (self.SelectedTarget.dead or not ValidTarget(self.SelectedTarget))) then
		self:__OnTargetLost(self.SelectedTarget)
		PrintLocal("Lost selected target: "..self.SelectedTarget.charName)
		self.SelectedTarget = nil
	end
	if (myHero.dead) then
		self.Target = nil
		self.Targets = { }
		Orbwalker:ForceTarget(nil)
		return
	end
	self.Targets = self:GetTargets()
	self.Target = self:GetTarget()
	Orbwalker:ForceTarget(self.Target)
end
function Selector:Initialize(mainMode, mainRange)
	self.Mode = mainMode or 1
	self:SetRange(mainRange or Orbwalker:GetRange())
	AddTickCallback(function() self:__OnTick() end)
end
function Selector:RegisterMode(id, name, sort)
	table.insert(self.SelectorModes, {
		ID = id,
		Name = name,
		Sort = sort,
	})
	SelectorMode[id] = #self.SelectorModes
end
function Selector:LoadToConfig(config)
	local config = config:Menu("Selector", "Target Selection")
	local modes = { }
	for i = 1, #self.SelectorModes do
		table.insert(modes, self.SelectorModes[i].Name)
	end
	config:DropDown("Mode", "Selector Mode", self.Mode, modes)
	config:Toggle("Selected", "Focus Selected Target", true)
	config:Separator()
	local enemyFound = false
	for i = 1, #GetEnemyHeroes() do
		local enemy = GetEnemyHeroes()[i]
		enemyFound = true
		config:Slider(enemy.charName, enemy.charName, self:GetRecommendedPriority(enemy), 1, 5)
	end
	if (not enemyFound) then
		config:Note("No enemies found.")
	end
	self.Config = config
	AddMsgCallback(function(message, key) self:__OnWndMsg(message, key) end)
end
function Selector:GetPriority(unit)
	return self.Config and self.Config[unit.charName] or 1
end
function Selector:GetRecommendedPriority(unit, ally)
	local name = unit.charName
	local ally = ally or false
	local count = ally and self.AllyCount or self.EnemyCount
	local order = ally and self.AllyPriorityOrder or self.EnemyPriorityOrder
	if (table.contains(self.PriorityTable.ADC, name)) then
		return order[count][self.PriorityIndex.ADC]
	end
	if (table.contains(self.PriorityTable.APC, name)) then
		return order[count][self.PriorityIndex.APC]
	end
	if (table.contains(self.PriorityTable.Support, name)) then
		return order[count][self.PriorityIndex.Support]
	end
	if (table.contains(self.PriorityTable.Bruiser, name)) then
		return order[count][self.PriorityIndex.Bruiser]
	end
	if (table.contains(self.PriorityTable.Tank, name)) then
		return order[count][self.PriorityIndex.Tank]
	end
	PrintLocal(Format("Could not find enemy \"{1}\" in priority table, please manually set it for this champion!", name), MessageType.Warning)
	return 1
end
function Selector:GetTarget(range, index, mode, enemies)
	if (self.Config and self.Config.Selected and self.SelectedTarget and IsValid(self.SelectedTarget, range)) then return self.SelectedTarget end
	return self:GetTargets(range, mode, enemies)[index or 1]
end
function Selector:GetTargets(range, mode, enemies)
	local targets = { }
	local range = range or self.Range
	local enemies = enemies or GetEnemiesInRange(range)
	for i = 1, #enemies do
		if (IsValid(enemies[i], range)) then
			table.insert(targets, enemies[i])
		end
	end
	table.sort(targets, self.SelectorModes[mode or (self.Config and self.Config.Mode) or self.Mode].Sort)
	return targets
end
function Selector:SetRange(range)
	Assert(range and type(range) == "number", "number expected for <range>")
	self.Range = range
end
Selector = Selector()

---//==================================================\\---
--|| > Jungler Class                                    ||--
---\===================================================//---

Class("Jungler")
function Jungler:__init()
	self.Baron = nil
	self.Dragon = nil
	self.Blues = { }
	self.Reds = { }
end
function Jungler:__OnCreateObj(object)
	if (object.valid and not object.dead and (object.type ~= "obj_AI_Minion")) then return end
	if (object.charName == "SRU_Baron") then
		self.Baron = object
		PrintDebug("Baron spawned!")
	elseif (object.charName == "SRU_Dragon") then
		self.Dragon = object
		PrintDebug("Dragon spawned!")
	elseif (object.charName == "SRU_Blue") then
		table.insert(self.Blues, object)
		PrintDebug("Blue spawned!")
	elseif (object.charName == "SRU_Red") then
		PrintDebug("Red spawned!")
		table.insert(self.Reds, object)
	end
end
function Jungler:__OnDeleteObj(object)
	if (object.type ~= "obj_AI_Minion") then return end
	if (object.charName == "SRU_Baron") then
		self.Baron = nil
		PrintDebug("Baron died!")
	elseif (object.charName == "SRU_Dragon") then
		self.Dragon = nil
		PrintDebug("Dragon died!")
	elseif (object.charName == "SRU_Blue") then
		for i = 1, #self.Blues do
			if (self.Blues[i].networkID == object.networkID) then
				table.remove(self.Blues, i)
				PrintDebug("Blue died!")
				break
			end
		end
	elseif (object.charName == "SRU_Red") then
		PrintDebug("Red spawned!")
		for i = 1, #self.Reds do
			if (self.Reds[i].networkID == object.networkID) then
				table.remove(self.Reds, i)
				PrintDebug("Red died!")
				break
			end
		end
	end
end
function Jungler:Initialize()
	AddCreateObjCallback(function(object) self:__OnCreateObj(object) end)
	AddDeleteObjCallback(function(object) self:__OnDeleteObj(object) end)
end
function Jungler:Get(important, main)
	local mobs = { }
	if (important) then
		if (self.Baron) then
			if (not self.Baron.valid or self.Baron.dead) then
				self.Baron = nil
			else
				table.insert(mobs, self.Baron)
			end
		end
		if (self.Dragon) then
			if (not self.Dragon.valid or self.Dragon.dead) then
				self.Dragon = nil
			else
				table.insert(mobs, self.Dragon)
			end
		end
	end
	if (main) then
		for i = 1, #self.Blues do
			local mob = self.Blues[i]
			if (not blue.valid or blue.dead) then
				table.remove(self.Blues, i)
				i = i - 1
			else
				table.insert(mobs, blue)
			end
		end
		for i = 1, #self.Reds do
			local mob = self.Reds[i]
			if (not red.valid or red.dead) then
				table.remove(self.Reds, i)
				i = i - 1
			else
				table.insert(mobs, red)
			end
		end
	end
	return mobs
end
Jungler = Jungler()

---//==================================================\\---
--|| > AutoPotions Class                                ||--
---\===================================================//---

Class("AutoPotions")
function AutoPotions:__init()
	self.Config = nil
	self.LastPotion = nil
	self.Potions = { }
end
function AutoPotions:__OnTick()
	if (myHero.dead) then
		for _, potion in pairs(self.Potions) do
			if (potion.Active) then
				potion.Active = false
				potion.EndTime = nil
			end
		end
	else
		for _, potion in pairs(self.Potions) do
			if (potion.Active and (GetInGameTimer() >= potion.EndTime)) then
				potion.Active = false
				potion.EndTime = nil
			end
		end
	end
end
function AutoPotions:__OnProcessSpell(unit, spell)
	if (not unit or not unit.isMe) then return end
	for _, potion in pairs(self.Potions) do
		if (potion.RealName == spell.name) then
			PrintDebug(Format("Casted {1}!", potion.Name))
			potion.Active = true
			potion.EndTime = GetInGameTimer() + potion.Duration
			break
		end
	end
end
function AutoPotions:Initialize()
	self:AddPotion("HP", "RegenerationPotion", "Health Potion")
	self:AddPotion("MP", "FlaskOfCrystalWater", "Mana Potion")
	self:AddPotion("Flask", "ItemCrystalFlask", "Flask", 12)
	AddTickCallback(function() self:__OnTick() end)
	AddProcessSpellCallback(function(unit, spell) self:__OnProcessSpell(unit, spell) end)
end
function AutoPotions:AddPotion(id, realName, name, duration)
	self.Potions[id] = {
		ID = id,
		RealName = realName,
		Name = name,
		Duration = duration or POTION_DURATION,
		Active = false,
		EndTime = nil,
	}
end
function AutoPotions:LoadToConfig(config, autoCall)
	if (_G.DevnsAutoPotions_Loaded and not ScriptInfo.IsPotionsScript) then
		config:Note("Devn's Auto-Potions is loaded!")
		return
	end
	config:Toggle("AutoUse", "Auto-Use Potions", true)
	if (ModeHandler.CanPerformCombo or ModeHandler.CanPerformHarass) then
		config:Toggle("ComboOnly", "Only use During Combo/Harass Mode", false)
	else
		config.ComboOnly = false
	end
	config:Separator()
	config:Toggle("HP", "Use Health Potion", true)
	config:Slider("HPHealth", "Health Pecentage", 30, 0, 100)
	config:Separator()
	config:Toggle("MP", "Use Mana Potion", true)
	config:Slider("MPMana", "Mana Pecentage", 30, 0, 100)
	config:Separator()
	config:Toggle("Flask", "Use Flask", true)
	config:Slider("FlaskHealth", "Health Pecentage", 30, 0, 100)
	config:Slider("FlaskMana", "Mana Pecentage", 30, 0, 100)
	self.Config = config
	if (autoCall) then
		AddTickCallback(function()
			if (not myHero.dead) then
				self:Cast()
			end
		end)
	end
end
function AutoPotions:Cast()
	if (myHero.dead) then return nil, 0, nil end
	if (not self.Config or not self.Config.AutoUse) then return nil, 0, nil end
	if (self.Config.ComboOnly and not (ModeHandler.Keys.Combo or ModeHandler.Keys.Harass)) then return nil, 0, nil end
	if (self.LastPotion and (GetInGameTimer() < self.LastPotion + 2)) then return nil, 0, nil end
	if (self.Potions.Flask.Active) then return nil, 0, nil end
	if (self.Config.HP and HealthUnderPercent(self.Config.HPHealth)) then
		if (not self.Potions.HP.Active) then
			local slot = GetItemSlot(self.Potions.HP.RealName)
			if (slot and SpellIsReady(slot)) then
				local percent = myHero.health / myHero.maxHealth
				PrintDebug(Format("Auto-Potion => pot:HP slot:{1} health:{2}", tostring(slot - 5), percent))
				CCastSpell(slot)
				self.LastPotion = GetInGameTimer()
				return Potions.Health, percent, Potions.Health
			end
		end
	end
	if (self.Config.MP and not HaveEnoughMana(self.Config.MPMana)) then
		if (not self.Potions.MP.Active) then
			local slot = GetItemSlot(self.Potions.MP.RealName)
			if (slot and SpellIsReady(slot)) then
				local percent = myHero.mana / myHero.maxMana
				PrintDebug(Format("Auto-Potion => pot:MP slot:{1} mana:{2}", tostring(slot - 5), percent))
				CCastSpell(slot)
				self.LastPotion = GetInGameTimer()
				return Potions.Mana, percent, Potions.Mana
			end
		end
	end
	if (self.Config.Flask) then
		local slot = GetItemSlot(self.Potions.Flask.RealName)
		if (slot and SpellIsReady(slot)) then
			if (HealthUnderPercent(self.Config.FlaskHealth) and not self.Potions.HP.Active) then
				local percent = myHero.health / myHero.maxHealth
				PrintDebug(Format("Auto-Potion => pot:Flask slot:{1} health:{2}", tostring(slot - 5), percent))
				CCastSpell(slot)
				self.LastPotion = GetInGameTimer()
				return Potions.Flask, percent, Potions.Health
			elseif (not HaveEnoughMana(self.Config.FlaskMana) and not self.Potions.MP.Active) then
				local percent = myHero.mana / myHero.maxMana
				PrintDebug(Format("Auto-Potion => pot:Flask slot:{1} mana:{2}", tostring(slot - 5), percent))
				CCastSpell(slot)
				self.LastPotion = GetInGameTimer()
				return Potions.Flask, percent, Potions.Mana
			end
		end
	end
	return nil, 0, nil
end
AutoPotions = AutoPotions()

---//==================================================\\---
--|| > OffensiveItems Class                             ||--
---\===================================================//---

Class("OffensiveItems")
function OffensiveItems:__init()
	self.Items = { }
end
function OffensiveItems:__OnTick()
	if (myHero.dead) then
		for i = 1, #self.Items do
			local item = self.Items[i]
			item.Slot = GetItemSlot(item.RealName)
			if (item.Slot) then
				self.Items[i].Ready = SpellIsReady(item.Slot)
			end
		end
	else
		for i = 1, #self.Items do
			local item = self.Items[i]
			item.Slot = GetItemSlot(item.RealName)
			if (item.Slot) then
				self.Items[i].Ready = SpellIsReady(item.Slot)
			end
		end
	end

end
function OffensiveItems:Initialize()
	self:AddItem("Cutlass", "BilgewaterCutlass", "Bilgewater Cutlass", 450)
	self:AddItem("Botrk", "ItemSwordOfFeastAndFamine", "Blade of the Ruined King", 450)
	self:AddItem("Gunblade", "HextechGunblade", "Hextech Gunblade", 700)
	self:AddItem("Ghostblade", "YoumusBlade", "Youmuu's Ghostblade", nil)
	AddTickCallback(function() self:__OnTick() end)
end
function OffensiveItems:AddItem(id, realName, name, range)
	table.insert(self.Items, {
		ID = id,
		Name = name,
		RealName = realName,
		Range = range or 0,
		Ready = false,
		Slot = nil,
	})
end
function OffensiveItems:LoadToConfig(config, onlyCutlass)
	local onlyCutlass = onlyCutlass or false
	local items = config:Menu("Items", "Item Casting Options")
	items:Toggle("Enabled", "Use Offensive Items", true)
	items:Slider("Health", "Maximum Health Percent", 75, 0, 100)
	items:Slider("TargetHealth", "Maximum Target Health Percent", 75, 0, 100)
	items:Separator()
	for i = 1, #self.Items do
		local item = self.Items[i]
		if (not onlyCutlass or (item.ID == "Botrk")) then
			items:Toggle(item.ID, item.Name, true)
		else
			items:Toggle(item.ID, item.Name, false)
		end
	end
end
function OffensiveItems:Cast(target, config)
	for i = 1, #self.Items do
		local item = self.Items[i]
		local range = item.Range or Orbwalker:GetRange()
		if (item.Ready and config.Items[item.ShortName] and InRange(target, range)) then
			PrintDebug(Format("Casting item {1} on enemy: ", item.Name, target.charName))
			CCastSpell(item.Slot, target)
			item.Ready = false
		end
	end
end
OffensiveItems = OffensiveItems()

---//==================================================\\---
--|| > DefensiveItems Class                             ||--
---\===================================================//---

Class("DefensiveItems")
function DefensiveItems:__init()
	self.Config = nil
	self.LastAutoHeal = nil
	self.ItemType = {
		Defensive = 1,
		Cleanse = 2,
	}
	self.Items = {
		[self.ItemType.Defensive] = { },
		[self.ItemType.Cleanse] = { },
	}
	self.Callbacks = {
		OnUseItem = { },
		OnCastItem = { },
	}
end
function DefensiveItems:__OnTick()
	if (myHero.dead) then
		for itemType = 1, 2 do
			for i = 1, #self.Items[itemType] do
				local item = self.Items[itemType][i]
				item.Slot = GetItemSlot(item.RealName)
				if (item.Slot) then
					self.Items[itemType][i].Ready = false
				end
			end
		end
	else
		for itemType = 1, 2 do
			for i = 1, #self.Items[itemType] do
				local item = self.Items[itemType][i]
				item.Slot = GetItemSlot(item.RealName)
				if (item.Slot) then
					self.Items[itemType][i].Ready = SpellIsReady(item.Slot)
				end
			end
		end
	end
end
function DefensiveItems:__OnUseItem(item)
	local cast = true
	for i = 1, #self.Callbacks.OnUseItem do
		if (not self.Callbacks.OnUseItem[i](item.RealName, item)) then
			cast = false
			break
		end
	end
	return cast
end
function DefensiveItems:__OnCastItem(item)
	for i = 1, #self.Callbacks.OnCastItem do
		self.Callbacks.OnCastItem[i](item.RealName, item)
	end
end
function DefensiveItems:Initialize()
	self:AddItem("Seraphs", "ItemSeraphsEmbrace", "Seraph's Embrace", self.ItemType.Defensive)
	self:AddItem("Hourglass", "ZhonyasHourglass", "Zhonya's Hourglass", self.ItemType.Defensive)
	self:AddItem("Qss", "QuicksilverSash", "Quicksilver Sash", self.ItemType.Cleanse)
	self:AddItem("Mercurial", "ItemMercurial", "Mercurial Scimitar", self.ItemType.Cleanse)
	AddTickCallback(function() self:__OnTick() end)
end
function DefensiveItems:AddItem(id, realName, name, itemType)
	table.insert(self.Items[itemType], {
		ID = id,
		Name = name,
		RealName = realName,
		Ready = false,
		Slot = nil,
	})
end
function DefensiveItems:LoadToConfig(config, loadPotions, autoCall)
	local config = config:Menu("Items", "Item Casting Options")
	if (loadPotions) then AutoPotions:LoadToConfig(config:Menu("Potions", "Auto-Potion Settings")) end
	config:Separator()
	local items = self.Items[self.ItemType.Defensive]
	for i = 1, #items do
		local item = items[i]
		config:Toggle(item.ID, Format("Use {1}", item.Name), true)
		config:Slider(Format("{1}Health", item.ID), "Health Percent", 35, 0, 100)
		config:Slider(Format("{1}Enemies", item.ID), "Minimum Enemies Near", 1, 1, 5)
		if (i < #self.Items[self.ItemType.Defensive]) then
			config:Separator()
		end
	end
	self.Config = config
	if (autoCall) then
		AddTickCallback(function()
			if (not myHero.dead) then
				self:Cast()
			end
		end)
	end
end
function DefensiveItems:Cast()
	if (not self.Config) then return end
	if (self.LastAutoHeal and (GetInGameTimer() < self.LastAutoHeal + 2)) then return end
	local items = self.Items[self.ItemType.Defensive]
	for i = 1, #items do
		local item = items[i]
		if (item.Ready and self.Config[item.ID]) then
			if (HealthUnderPercent(self.Config[Format("{1}Health", item.ID)])) then
				if (#GetEnemiesInRange(VisionRange) >= self.Config[Format("{1}Enemies", item.ID)]) then
					if (self:__OnUseItem(item)) then
						PrintDebug(Format("Auto-Items => item:{1} health:{2} enemies:{3}", item.Name, myHero.health / myHero.maxHealth, #GetEnemiesInRange(VISION_RANGE)))
						CCastSpell(item.Slot)
						item.Ready = false
						self.LastAutoHeal = GetInGameTimer()
						self:__OnCastItem(item)
						break
					end
				end
			end
		end
	end
end
function DefensiveItems:AddOnUseItemCallback(callback)
	table.insert(self.Callbacks.OnUseItem, callback)
end
function DefensiveItems:AddOnCastItemCallback(callback)
	table.insert(self.Callbacks.OnCastItem, callback)
end
DefensiveItems = DefensiveItems()

---//==================================================\\---
--|| > AutoInterrupter Class                            ||--
---\===================================================//---

Class("AutoInterrupter")
function AutoInterrupter:__init()
	self.Config = nil
	self.ActiveSpells = { }
	self.Callbacks = { }
end
function AutoInterrupter:__OnTick()
	for i = #self.ActiveSpells, 1, -1 do
		local data = self.ActiveSpells[i]
		if (data.EndTime - GetInGameTimer() > 0) then
			self:__OnInterruptableSpell(data)
		else
			table.remove(self.ActiveSpells, i)
		end
	end
end
function AutoInterrupter:__OnProcessSpell(unit, spell)
	if (not self.Config.Enabled) then return end
	if ((unit.team ~= myHero.team) and InterruptableSpells[spell.name]) then
		local spellData = InterruptableSpells[spell.name]
		if (self.Config[spell.name:gsub("_", "")]) then
			local data = {
				Enemy = unit,
				DangerLevel = spellData.DangerLevel,
				EndTime = GetInGameTimer() + spellData.MaxDuration,
				CanMove = spellData.CanMove,
			}
			table.insert(self.ActiveSpells, data)
			self:__OnInterruptableSpell(data)
		end
	end
end
function AutoInterrupter:__OnInterruptableSpell(data)
	for i = 1, #self.Callbacks do
		self.Callbacks[i](data.Enemy, data)
	end
end
function AutoInterrupter:Initialize()
	return self
end
function AutoInterrupter:LoadToConfig(config)
	local spellAdded = false
	local charNames = { }
	for i = 1, #Enemies do
		table.insert(charNames, Enemies[i].charName)
	end
	local config = config:Menu("Interrupter", "Auto-Interrupter")
	config:Toggle("Enabled", "Enable Auto-Interrupter", true)
	config:Separator()
	for spellName, data in pairs(InterruptableSpells) do
		if (table.contains(charNames, data.charName)) then
			config:Toggle(spellName:gsub("_", ""), Format("{1} - {2}", data.charName, spellName), true)
			spellAdded = true
		end
	end
	if (not spellAdded) then
		config:Note("No spells available to interrupt.")
	else
		AddProcessSpellCallback(function(unit, spell) self:__OnProcessSpell(unit, spell) end)
		AddTickCallback(function() self:__OnTick() end)
	end
	self.Config = config
end
function AutoInterrupter:AddInterruptableSpellCallback(callback)
	table.insert(self.Callbacks, callback)
end
AutoInterrupter = AutoInterrupter()

---//==================================================\\---
--|| > AutoLeveler Class                                ||--
---\===================================================//---

Class("AutoLeveler")
function AutoLeveler:__init()
	self.Config = nil
	self.LastLevel = nil
	self.ExtraUlt = false
	self.StartSelection = 1
	self.EndSelection = 1
	self.StartSequences = { }
	self.EndSequences = { }
	self.LevelSpell = {
		["5.19"] = _G.LevelSpell,
		["5.20"] = nil,
	}
end
function AutoLeveler:__OnTick()
	if (self.LastLevel and (GetInGameTimer() < self.LastLevel + LEVEL_SPELL_DELAY)) then return end
	local total = GetSpellLevel(_Q) + GetSpellLevel(_W) + GetSpellLevel(_E) + GetSpellLevel(_R)
	if (self.ExtraUlt) then total = total - 1 end
	if (total < myHero.level) then
		if (total < 3) then
			if (self.Config.BeforeThree) then
				local sequence = self.StartSequences[self.Config.BeforeThreeOrder].Order
				local levelTo = (myHero.level <= 3) and myHero.level or 3
				local levels = {
					[_Q] = 0,
					[_W] = 0,
					[_E] = 0,
				}
				for i = 1, levelTo do
					local seq = sequence[i]
					levels[seq] = levels[seq] + 1
				end
				for i = _Q, _E do
					if (GetSpellLevel(i) < levels[i]) then
						self.LevelSpell[Script.LeagueVersion](i)
						self.LastLevel = GetInGameTimer()
						break
					end
				end
			end
		else
			if (self.Config.AfterThree) then
				local sequence = self.EndSequences[self.Config.AfterThreeOrder].Order
				local levelTo = myHero.level - 3
				local levels = {
					[_Q] = 1,
					[_W] = 1,
					[_E] = 1,
					[_R] = 0,
				}
				for i = 1, levelTo do
					local seq = sequence[i]
					levels[seq] = levels[seq] + 1
				end
				for i = _Q, _R do
					if (GetSpellLevel(i) < levels[i]) then
						self.LevelSpell[Script.LeagueVersion](i)
						self.LastLevel = GetInGameTimer()
						break
					end
				end
			end
		end
	end
end
function AutoLeveler:Initialize(startSelection, endSelection, extraUlt)
	self.ExtraUlt = extraUlt or false
	self.StartSelection = startSelection or 1
	self.EndSelection = endSelection or 1
	self:AddStartSequence("Q > W > E", { _Q, _W, _E })
	self:AddStartSequence("Q > E > W", { _Q, _E, _W })
	self:AddStartSequence("W > Q > E", { _W, _Q, _E })
	self:AddStartSequence("W > E > Q", { _W, _E, _Q })
	self:AddStartSequence("E > Q > W", { _E, _Q, _W })
	self:AddStartSequence("E > W > Q", { _E, _W, _Q })
	self:AddEndSequence("Q > W > E", { _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E })
	self:AddEndSequence("Q > E > W", { _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W })
	self:AddEndSequence("W > Q > E", { _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E })
	self:AddEndSequence("W > E > Q", { _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q })
	self:AddEndSequence("E > Q > W", { _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W })
	self:AddEndSequence("E > W > Q", { _E, _E, _R, _E, _W, _E, _W, _R, _W, _W, _Q, _Q, _R, _Q, _Q })
end
function AutoLeveler:AddStartSequence(name, sequence, default)
	table.insert(self.StartSequences, {
		Name = name,
		Order = sequence,
	})
	if (default) then
		self.StartSelection = #self.StartSequences
	end
end
function AutoLeveler:AddEndSequence(name, sequence, default)
	table.insert(self.EndSequences, {
		Name = name,
		Order = sequence,
	})
	if (default) then
		self.EndSelection = #self.EndSequences
	end
end
function AutoLeveler:LoadToConfig(config)
	local autolevel = config:Menu("AutoLevel", "Auto-Level Spells")
	if (Script.DisableLevelSpell) then
		autolevel:Note("Currently disabled!")
		return
	elseif (not self.LevelSpell[Script.LeagueVersion]) then
		autolevel:Note("LevelSpell is not working!")
		return
	end
	local startSequences = { }
	local endSequences = { }
	for i = 1, #self.StartSequences do
		table.insert(startSequences, self.StartSequences[i].Name)
	end
	for i = 1, #self.EndSequences do
		table.insert(endSequences, self.EndSequences[i].Name)
	end
	autolevel:Toggle("BeforeThree", "Enable Before Level Three", false)
	autolevel:DropDown("BeforeThreeOrder", "Spell Order to Level", self.StartSelection, startSequences)
	autolevel:Toggle("BeforeThreeDisable", "Disable at Start of Game", false)
	autolevel:Separator()
	autolevel:Toggle("AfterThree", "Enable After Level Three", false)
	autolevel:DropDown("AfterThreeOrder", "Spell Order to Level", self.EndSelection, endSequences)
	autolevel:Toggle("AfterThreeDisable", "Disable at Start of Game", false)
	self.Config = autolevel
	AddTickCallback(function() self:__OnTick() end)
end
AutoLeveler = AutoLeveler()

---//==================================================\\---
--|| > Summoners Class                                  ||--
---\===================================================//---

Class("Summoners")
function Summoners:__init()
	self.List = { }
	self.Initialized = false
	self.LastAutoHeal = 0
end
function Summoners:__OnTick()
	if (myHero.dead) then
		for _, summoner in pairs(self.List) do
			summoner.Ready = false
		end
	else
		for _, summoner in pairs(self.List) do
			summoner.Ready = SpellIsReady(summoner.Slot)
		end
	end
end
function Summoners:Initialize()
	if (self.Initialized) then return end
	AddTickCallback(function() self:__OnTick() end)
	self.Initialized = true
end
function Summoners:Register(id, name, range)
	if (self.List[id]) then return end
	local slot = GetSummonerSlot(name)
	if (slot) then
		PrintDebug(Format("User has summoner: {1}", id))
		self.List[id] = {
			Name = id,
			RealName = name,
			Slot = slot,
			Range = range or VISION_RANGE,
			Ready = false,
		}
		self:Initialize()
	end
end
function Summoners:LoadToConfig(config, autoCall)
	local config = config:Menu("Summoners", "Summoner Spell Options")
	local summoner1 = false
	if (self:Has(SummonerSpell.Ignite)) then
		summoner1 = true
		AutoIgnite:LoadToConfig(config:Menu(SummonerSpell.Ignite, SummonerSpell.Ignite.." Settings"), autoCall)
	end
	if (self:Has(SummonerSpell.Smite)) then
		summoner1 = true
		AutoSmite:LoadToConfig(config:Menu(SummonerSpell.Smite, SummonerSpell.Smite.." Settings"), autoCall)
	end
	if (self:Has(SummonerSpell.Barrier)) then
		summoner1 = true
		AutoBarrier:LoadToConfig(config:Menu(SummonerSpell.Barrier, SummonerSpell.Barrier.." Settings"), autoCall)
	end
	if (self:Has(SummonerSpell.Heal)) then
		summoner1 = true
		AutoHeal:LoadToConfig(config:Menu(SummonerSpell.Heal, SummonerSpell.Heal.." Settings"), autoCall)
	end
	if (not summoner1) then config:Note("No usable summoners were found!") end
end
function Summoners:Cast(name, unit)
	CCastSpell(self.List[name].Slot, unit)
	self.List[name].Ready = false
end
function Summoners:IsReady(name)
	return (self.List[name] and self.List[name].Ready)
end
function Summoners:Get(name)
	return self.List[name]
end
function Summoners:Has(name)
	return (self.List[name] ~= nil)
end
function Summoners:GetDamage(name, unit)
	if (name == SummonerSpell.Ignite) then return (50 + (20 * myHero.level)) - ((unit.hpRegen / 5) * 3) end
	if (name == SummonerSpell.Smite) then
		if (unit and (unit.type == "obj_AI_Hero")) then
			if (GetSummonerSlot("s5_summonersmiteplayerganker")) then
				return (20 + (8 * myHero.level))
			elseif (GetSummonerSlot("s5_summonersmiteduel")) then
				return (54 + (6 * myHero.level))
			end
		else
			local damage = { 390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000 }
			return damage[myHero.level]
		end
	end
	return 0
end
function Summoners:CanSmiteEnemies()
	local summonerNames = { "s5_summonersmiteplayerganker", "s5_summonersmiteduel" }
	for i = 1, #summonerNames do
		if (GetSummonerSlot(summonerNames[i])) then
			return true
		end
	end
	return false
end
Summoners = Summoners()

---//==================================================\\---
--|| > AutoHeal Class                                   ||--
---\===================================================//---

Class("AutoHeal")
function AutoHeal:__init()
	self.Config = nil
end
function AutoHeal:Initialize()
	Summoners:Register("Heal", "SummonerHeal")
end
function AutoHeal:LoadToConfig(config, autoCall)
	config:Toggle("Use", "Use "..SummonerSpell.Heal, false)
	config:Slider("Health", "Health Percent", 35, 0, 100)
	config:Separator()
	config:Slider("Enemies", "Minimum Enemies Near", 1, 1, 5)
	config:Slider("Range", "Range to Check for Enemies", DEF_VISION_RANGE, MIN_VISION_RANGE, MAX_VISION_RANGE)
	self.Config = config
	if (autoCall) then AddTickCallback(function() self:CheckForHeal() end) end
end
function AutoHeal:CheckForHeal()
	if (not Summoners:IsReady(SummonerSpell.Heal) or not HealthUnderPercent(99) or (GetInGameTimer() < Summoners.LastAutoHeal + 2)) then return end
	if (config.Use and HealthUnderPercent(config.Health) and (#GetEnemiesInRange(config.Range) >= config.Enemies)) then
		PrintDebug(Format("AutoHeal => summoner:{1} health:{2} enemies:{3}", SummonerSpell.Heal, (myHero.health / myHero.maxHealth), #GetEnemiesInRange(config.Range)))
		Summoners:Cast(SummonerSpell.Heal)
		Summoners.LastAutoHeal = GetInGameTimer()
	end
end
AutoHeal = AutoHeal()

---//==================================================\\---
--|| > AutoBarrier Class                                ||--
---\===================================================//---

Class("AutoBarrier")
function AutoBarrier:__init()
	self.Config = nil
end
function AutoBarrier:Initialize()
	Summoners:Register("Barrier", "SummonerBarrier")
end
function AutoBarrier:LoadToConfig(config, autoCall)
	config:Toggle("Use", "Use "..SummonerSpell.Barrier, false)
	config:Slider("Health", "Health Percent", 35, 0, 100)
	config:Separator()
	config:Slider("Enemies", "Minimum Enemies Near", 1, 1, 5)
	config:Slider("Range", "Range to Check for Enemies", DEF_VISION_RANGE, MIN_VISION_RANGE, MAX_VISION_RANGE)
	self.Config = config
	if (autoCall) then AddTickCallback(function() self:CheckForBarrier() end) end
end
function AutoBarrier:CheckForBarrier()
	if (myHero.dead or not Summoners:IsReady(SummonerSpell.Barrier) or not HealthUnderPercent(99) or (GetInGameTimer() < Summoners.LastAutoHeal + 2)) then return end
	if (self.Config.Use and HealthUnderPercent(self.Config.Health) and (#GetEnemiesInRange(self.Config.Range) >= self.Config.Enemies)) then
		PrintDebug(Format("AutoBarrier => summoner:{1} health:{2} enemies:{3}", SummonerSpell.Barrier, (myHero.health / myHero.maxHealth), #GetEnemiesInRange(self.Config.Range)))
		Summoners:Cast(SummonerSpell.Barrier)
		Summoners.LastAutoHeal = GetInGameTimer()
	end
end
AutoBarrier = AutoBarrier()

---//==================================================\\---
--|| > AutoIgnite Class                                 ||--
---\===================================================//---

Class("AutoIgnite")
function AutoIgnite:__init()
	self.Config = nil
end
function AutoIgnite:Initialize()
	Summoners:Register(SummonerSpell.Ignite, "SummonerDot", 600)
end
function AutoIgnite:LoadToConfig(config)
	if (not Summoners:Has(SummonerSpell.Ignite)) then return end
	config:Toggle("Use", "Use "..SummonerSpell.Ignite, true)
	if (ModeHandler.CanPerformCombo) then
		config:Separator()
		config:Toggle("Combo", "Use During Combo", true)
		config:Slider("MaxHealth", "Use at Health Percent", 50, 0, 100)
		config:Slider("MaxTargetHealth", "Use at Target Health Percent", 50, 0, 100)
		config:Note("Both conditions must be met!")
	else
		config.Combo = false
	end
	config:Separator()
	config:Toggle("Killsteal", "Use to Killsteal", true)
	if (RecallTracker.IsTracking) then config:Toggle("RecallDisable", "Disable While Recalling", true) end
	config:Toggle("Fleeing", "Only if Target is Fleeing", false)
	config:Toggle("Slower", "Only if Target is Slower", false)
	self.Config = config
	if (autoCall) then AddTickCallback(function() self:CheckForIgnite() end) end
end
function AutoIgnite:CheckForIgnite()
	if (myHero.dead or not Summoners:IsReady(SummonerSpell.Ignite)) then return end
	local range = Summoners:Get(SummonerSpell.Ignite).Range
	if (self.Config.Combo and KeysConfig.Combo and Selector.Target) then
		if (IsValid(Selector.Target, range) and HealthUnderPercent(self.Config.MaxHealth) and HealthUnderPercent(self.Config.MaxTargetHealth, Selector.Target)) then
			PrintDebug(Format("Casting ignite on enemy \"{1}\" for mode: combo", Selector.Target.charName))
			Summoners:Cast(SummonerSpell.Ignite, Selector.Target)
			return
		end
	end
	if (not self.Config.Killsteal or (self.Config.RecallDisable and RecallTracker.IsRecalling)) then return end
	local enemies = GetEnemiesInRange(range)
	for i = 1, #enemies do
		local enemy = enemies[i]
		local check = true
		if (not IsValid(enemy)) then
			check = false
		elseif (self.Config.Fleeing and not IsFleeing(enemy, range)) then
			check = false
		elseif (self.Config.Slower and (myHero.ms > enemy.ms)) then
			check = false
		end
		if (check) then
			if (Summoners:GetDamage(SummonerSpell.Ignite, enemy) >= GetPredictedHealth(enemy, 6)) then
				PrintDebug(Format("Casting ignite on enemy \"{1}\" for mode: killsteal", enemy.charName))
				Summoners:Cast(SummonerSpell.Ignite, enemy)
				break
			end
		end
	end
end
AutoIgnite = AutoIgnite()

---//==================================================\\---
--|| > AutoSmite Class                                  ||--
---\===================================================//---

Class("AutoSmite")
function AutoSmite:__init()
	self.Config = nil
end
function AutoSmite:Initialize()
	Summoners:Register("Smite", "SummonerSmite", 600)
end
function AutoSmite:LoadToConfig(config)
	if (not Summoners:Has(SummonerSpell.Smite)) then return end
	config:Toggle("Use", "Use "..SummonerSpell.Smite, true)
	config:Separator()
	config:Toggle("Mobs", "Auto-"..SummonerSpell.Smite.." Mobs", true)
	config:Toggle("Important", SummonerSpell.Smite.." Baron and Dragon", true)
	config:Toggle("Main", SummonerSpell.Smite.." Red and Blue Buff", true)
	if (ModeHandler.CanPerformCombo) then
		config:Separator()
		config:Toggle("Combo", "Use During Combo", true)
		config:Slider("MaxHealth", "Use at Health Percent", 50, 0, 100)
		config:Slider("MaxTargetHealth", "Use at Target Health Percent", 50, 0, 100)
		config:Note("Both conditions must be met!")
	else
		config.Combo = false
	end
	config:Separator()
	config:Toggle("Killsteal", "Use to Killsteal", true)
	if (RecallTracker.IsTracking) then config:Toggle("RecallDisable", "Disable While Recalling", true) end
	config:Toggle("Fleeing", "Only if Target is Fleeing", false)
	config:Toggle("Slower", "Only if Target is Slower", false)
end
AutoSmite = AutoSmite()

---//==================================================\\---
--|| > AutoCleanse Class                                ||--
---\===================================================//---

Class("AutoCleanse")
function AutoCleanse:__init()
	self.Config = nil
end
function AutoCleanse:Initialize()
	Summoners:Register("Cleanse", "SummonerCleanse")
end
AutoCleanse = AutoCleanse()

---//==================================================\\---
--|| > Notifications Class                              ||--
---\===================================================//---

Class("Notifications") -- Credits to 'BlueCore'.
function Notifications:__init()
	self.Position = {
		X = (WINDOW_W * 0.995),
		Y = (WINDOW_H * 0.1),
	}
	self:__Initialize()
end
function Notifications:__OnDraw()
	local timer = 0.5
	local gametime = GetInGameTimer()
	if (Count(_G.GodLib_Notifications) > self:GetMaxTileCount()) then
		table.remove(_G.GodLib_Notifications, 1)
	end
	for i = 1, #_G.GodLib_Notifications do
		local tile = _G.GodLib_Notifications[i]
		if (tile) then
			tile.X = self.Position.X
			tile.Y = self.Position.Y + (NOTIFICATION_THICKNESS + 6) * (i - 1)
			if (tile.Start + timer >= gametime) then
				local percent = ((tile.Start + timer) - gametime) / timer
				tile.X = self.Position.X + NOTIFICATION_LENGTH * percent
			end
			if ((tile.Duration + tile.Start <= gametime) and (tile.Duration + tile.Start + timer > gametime)) then
				local percent = (gametime - (tile.Start + tile.Duration)) / timer
				tile.X = self.Position.X + NOTIFICATION_LENGTH * percent
			end
			self:__DrawTile(tile.X, tile.Y, tile.Header, tile.Text)
			if (tile.Start + tile.Duration + timer <= gametime) then
				table.remove(_G.GodLib_Notifications, i)
				i = i - 1
			end
		else
			table.remove(_G.GodLib_Notifications, i)
			i = i -1
		end
	end
end
function Notifications:__DrawTile(x, y, header, text)
	local headerLength = GetTextArea(header, 25).x - 240
	local contextLength = GetTextArea(text, 20).x - 250
	local extraLength = (headerLength > contextLength) and headerLength or contextLength
	local tileLength = self:CursorIsOverTile(x, y) and NOTIFICATION_LENGTH + (extraLength > 0 and extraLength or 0) or NOTIFICATION_LENGTH
	local borderColor = self:CursorIsOverTile(x, y) and ARGB(255, 93, 86, 58) or ARGB(255 * 0.5, 93, 86, 58)
	local borderThickness = 4
	local borderOffsetY = (NOTIFICATION_THICKNESS * 0.5)
	DrawLine(x - tileLength, y - borderOffsetY, x, y - borderOffsetY, borderThickness, borderColor)
	DrawLine(x - tileLength, y + borderOffsetY, x, y + borderOffsetY, borderThickness, borderColor)
	DrawLine(x - tileLength + (borderThickness * 0.5), y - borderOffsetY + (borderThickness * 0.5), x - tileLength + (borderThickness * 0.5), y + borderOffsetY - (borderThickness * 0.5), borderThickness, borderColor)
	DrawLine(x - (borderThickness * 0.5), y - borderOffsetY + (borderThickness * 0.5), x - (borderThickness * 0.5), y + borderOffsetY - (borderThickness * 0.5), borderThickness, borderColor)
	local mainColor = self:CursorIsOverTile(x, y) and ARGB(255, 12, 19, 18) or ARGB(255 * 0.5, 12, 19, 18)
	local mainBorderOffset = (borderThickness * 0.5)
	DrawLine(x - tileLength + borderThickness, y, x - borderThickness, y, NOTIFICATION_THICKNESS - borderThickness, mainColor)
	local boxYOffset = NOTIFICATION_THICKNESS * 0.5 - 24 * 0.5
	if (self:CursorIsOverBox(x, y)) then
		DrawLine(x - 24 - borderThickness, y - boxYOffset + mainBorderOffset, x - borderThickness, y - boxYOffset + mainBorderOffset, 24, ARGB(255, 35, 65, 63))
	end
	local fixedHeader = (not self:CursorIsOverTile(x, y) and GetTextArea(header, 25).x > 240) and header:sub(1, 20).." ..." or header
	DrawText(fixedHeader, 25, x - tileLength + borderThickness * 2, y - 30, ARGB(255, 127, 255, 212))
	local fixedContext = (not self:CursorIsOverTile(x, y) and GetTextArea(text, 20).x > 250) and text:sub(1, 25).." ..." or text
	DrawText(fixedContext, 20, x - tileLength + borderThickness * 2, y + 5, ARGB(255, 250, 235, 215))
	DrawText("x", 33, x - 24, y - boxYOffset * 2 + 5, ARGB(255, 143, 188, 143))
end
function Notifications:__OnWndMsg(message, param)
	if (message ~= 513) then return end
	for i = 1, #_G.GodLib_Notifications do
		local tile = _G.GodLib_Notifications[i]
		if (tile) then
			if (self:CursorIsOverBox(tile.X, tile.Y)) then
				tile.Duration = GetInGameTimer() - tile.Start
			end
		else
			table.remove(_G.GodLib_Notifications, i)
			i = i -1
		end
	end
end
function Notifications:__Initialize()
	if (_G.GodLib_Notifications_Initialized) then return end
	_G.GodLib_Notifications = { }
	AddDrawCallback(function() self:__OnDraw() end)
	AddMsgCallback(function(message, param) self:__OnWndMsg(message, param) end)
	_G.GodLib_Notifications_Initialized = true
end
function Notifications:Show(header, text, duration)
	local index = #_G.GodLib_Notifications + 1
	table.insert(_G.GodLib_Notifications, {
		Header = header,
		Text = text,
		Duration = duration or 5,
		Start = GetInGameTimer(),
		X = self.Position.X,
		Y = self.Position.Y,
	})
	return {
		Remove = function()
			table.remove(_G.GodLib_Notifications, index)
			-- _G.GodLib_Notifications[index].Start = GetInGameTimer() - _G.GodLib_Notifications[index].Duration
		end,
	}
end
function Notifications:GetMaxTileCount()
	return Round((WINDOW_H / 108), 0)
end
function Notifications:CursorIsOverTile(posX, posY)
	local cursor = GetCursorPos()
	local x = posX - cursor.x
	local y = posY - cursor.y
	return (x < NOTIFICATION_LENGTH and x > 0) and (y < 30 and y > -45)
end
function Notifications:CursorIsOverBox(posX, posY)
	local cursor = GetCursorPos()
	local x = posX - cursor.x
	local y = posY - cursor.y
	return (x < 28 and x > 0) and (y < 24 and y > -10)
end
Notifications = Notifications()

---//==================================================\\---
--|| > Alerter Class                                    ||--
---\===================================================//---

Class("Alerter")
function Alerter:__init(x, y, text, size, duration, color, borderColor, borderWidth)
	self.x = x
	self.y = y
	self.Text = text
	self.Size = size
	self.Duration = duration or 1
	self.Color = color or "White"
	self.BorderColor = borderColor
	self.BorderWidth = borderWidth or 1
	self.Visible = true
	self.StartTime = GetInGameTimer()
	self.EndTime = self.StartTime + self.Duration
	AddTickCallback(function() self:__OnTick() end)
	AddDrawCallback(function() self:__OnDraw() end)
end
function Alerter:__OnTick()
	if (not self.Visible) then return end
	if (GetInGameTimer() < self.EndTime) then return end
	self:Remove()
end
function Alerter:__OnDraw()
	if (not self.Visible) then return end
	if (self.BorderColor) then
		DrawTextWithBorder(self.Text, self.Size, self.x, self.y, self.Color, self.BorderColor, self.BorderWidth)
	else
		DrawSmartText(self.Text, self.Size, self.x, self.y, self.Color)
	end
end
function Alerter:Remove()
	self.Visible = false
end

---//==================================================\\---
--|| > DialogBox Class                                  ||--
---\===================================================//---

Class("DialogBox")
function DialogBox:__init(title, width, callback)
	self.Title = Format("{1}: {2}", ScriptInfo.Name, title)
	self.Info = Format("Version {1} - Tested With LoL {2}", ScriptInfo.Version, ScriptInfo.LeagueVersion)
	self.Lines = { }
	self.Buttons = { }
	self.Width = width or 500
	self.HWidth = self.Width / 2
	self.Height = 92
	self.x = (WINDOW_W / 2) - self.HWidth
	self.y = (WINDOW_H / 5)
	self.Visible = false
	self.CloseHovered = false
	self.CloseCallback = callback or nil
	AddTickCallback(function() self:__OnTick() end)
	AddMsgCallback(function(message, key) self:__OnWndMsg(message, key) end)
	AddDrawCallback(function() self:__OnDraw() end)
end
function DialogBox:__OnTick()
	if (not self.Visible) then return end
	if (CursorIsUnder(self.x + self.Width - 50, self.y + 1, 50, 23)) then
		self.CloseHovered = true
	else
		self.CloseHovered = false
	end
	for i = 1, #self.Buttons do
		local button = self.Buttons[i]
		if (button.x and button.y) then
			if (CursorIsUnder(button.x, button.y, button.Width, 26)) then
				button.Hovered = true
			else
				button.Hovered = false
			end
		end
	end
end
function DialogBox:__OnWndMsg(message, key)
	if (not self.Visible) then return end
	if ((key ~= 1) or (message ~= WM_LBUTTONDOWN)) then return end
	if (self.CloseHovered) then
		self:Close()
	else
		for i = 1, #self.Buttons do
			local button = self.Buttons[i]
			if (button.Hovered) then
				button.Hovered = false
				if (button.Callback) then
					button.Callback()
				end
				break
			end
		end
	end
end
function DialogBox:__OnDraw()
	if (not self.Visible) then return end
	local y = self.y + 28
	DrawRectangle(self.x - 3, self.y - 3, self.Width + 7, self.Height + 8, 0xFF172021)
	DrawRectangle(self.x, self.y, 500, self.Height + 2, 0xFF998E64)
	DrawRectangle(self.x + 1, self.y + 1, 498, self.Height, 0xFF0E1314)
	DrawRectangle(self.x + 1, self.y + 1, 498, 24, 0xFF998E64)
    DrawRectangle(self.x + 1, self.y + 1, 498, 23, 0xFF0f1b1b)
    DrawRectangle(self.x + self.Width - 52, self.y + 1, 1, 23, 0xFF998E64)
    DrawRectangle(self.x + self.Width - 51, self.y + 1, 50, 23, self.CloseHovered and 0xFF998E64 or 0xFF264C48)
    DrawText("X", 15, self.x + self.Width - 30, self.y + 7, self.CloseHovered and 0xFF172021 or 0xFFA38D63)
	DrawText(self.Title, 20, self.x + self.HWidth - (GetTextArea(self.Title, 20).x / 2), self.y + 4, 0xFFFEF698)
	for i = 1, #self.Lines do
		y = y + 14
		DrawText(self.Lines[i], 15, self.x + 6, y, 0xFFFEF698)
	end
	y = y + 28
	DrawText(self.Info, 11, self.x + 6, y + 22, 0xFFFEF698)
	local btnWidth = 0
	for i = 1, #self.Buttons do
		local button = self.Buttons[i]
		btnWidth = btnWidth + button.Width + 6
		button.x = self.x + self.Width - btnWidth
		button.y = y + 6
		DrawRectangle(button.x, button.y, button.Width, 26, button.Hovered and 0xFF998E64 or 0xFF264C48)
		DrawRectangle(button.x, button.y, 1, 26, 0xFF998E64)
		DrawRectangle(button.x + button.Width, button.y, 1, 26, 0xFF998E64)
		DrawRectangle(button.x, button.y, button.Width, 1, 0xFF998E64)
		DrawRectangle(button.x, button.y + 26, button.Width, 1, 0xFF998E64)
		DrawText(button.Text, 15, button.x + (button.Width / 2) - (GetTextArea(button.Text, 15).x / 2), button.y + 6, button.Hovered and 0xFF172021 or 0xFFA38D63)
	end
end
function DialogBox:Close()
	self.Visible = false
	self.CloseHovered = false
	for i = 1, #self.Buttons do
		self.Buttons[i].Hovered = false
	end
	if (not self.CloseCallback) then return end
	self.CloseCallback()
end
function DialogBox:Show()
	self.Visible = true
end
function DialogBox:Add(line)
	local line = line and line:gsub("-t", "        ") or ""
	table.insert(self.Lines, line)
	self.Height = self.Height + 14
end
function DialogBox:AddButton(text, callback, width)
	table.insert(self.Buttons, {
		Text = text,
		Callback = callback,
		Hovered = false,
		Width = width or 100,
		x = nil,
		y = nil,
	})
end

---//==================================================\\---
--|| > SpellData Class									||--
---\===================================================//---

Class("SpellData")
function SpellData:__init(id, key, name, range)
	self.Key = key
	self.ID = id
	self.Name = Format("{1} ({2})", name, self.ID)
	self.Mana = 0
	self.BaseRange = range or 0
	self.Range = self.BaseRange
	self.BaseWidth = 0
	self.Width = 0
	self.Hitchance = Hitchance.Medium
	self.IsReadyCallback = function(self)
		if (self.Key) then
			return (SpellIsReady(self.Key) or ((self:GetCurrentCooldown() <= GetRealLatency() * 2) and (self:GetLevel() > 0) and self:HaveEnoughMana()))
		end
		return true
	end
	self.AutoAttackResetCallback = function(target)
		local target = target or GetTarget(Orbwalker:GetRange())
		if (target) then Orbwalker:Attack(target, true) end
	end
	self.Callbacks = { }
	self:GetName()
	self:IsReady()
	self:SetRange(self.BaseRange)
	self:SetTargeted(0, math.huge)
	self:SetAccuracy(SpellAccuracy.Normal)
	self:SetDamage(DamageType.True, 0, 0, DamageType.True, ScalingStat.AttackDamage, 0)
end
function SpellData:SetHitchance(hitchance)
	self.Hitchance = hitchance
end
function SpellData:GetPrediction(unit)
	return Prediction:GetPrediction(unit, self:GetPredData(), myHero)
end
function SpellData:GetAoePrediction(unit)
	return Prediction:GetAoePrediction(unit, self:GetPredData(), myHero)
end
function SpellData:GetHit(position)
	return Prediction:GetHit(position, self:GetPredData(), myHero)
end
function SpellData:SetRange(range)
	self.BaseRange = range or 0
	self.Range = self.BaseRange
	return self
end
function SpellData:UpdateRange(modifier)
	self.Range = self.BaseRange + modifier
	return self
end
function SpellData:SetWidth(width)
	self.BaseWidth = width or 0
	self.Width = self.BaseWidth
	self.Radius = self.Width / 2
	return self
end
function SpellData:UpdateWidth(modifier)
	self.Width = self.BaseWidth + modifier
	self.Radius = self.Width / 2
	return self
end
function SpellData:SetAccuracy(accuracy)
	self.Accuracy = accuracy or SpellAccuracy.Normal
	if (self.Accuracy == SpellAccuracy.Low) then
		self.IsLowAccuracy = true
		self.IsVeryLowAccuracy = false
	elseif (self.Accuracy == SpellAccuracy.VeryLow) then
		self.IsLowAccuracy = true
		self.IsVeryLowAccuracy = false
	else
		self.IsLowAccuracy = false
		self.IsVeryLowAccuracy = false
	end
	return self
end
function SpellData:SetTargeted(delay, speed)
	return self:SetSkillshot(0, delay, speed, false, SkillshotType.Targeted)
end
function SpellData:SetSkillshot(width, delay, speed, collision, skillshotType)
	self:SetWidth(width)
	self.Delay = delay or 0
	self.Speed = speed or math.huge
	self.Type = skillshotType or SkillshotType.Targeted
	if (type(collision) == "boolean") then
		if (collision) then
			self.Collision = true
			self.CollisionN = 0
		else
			self.Collision = false
			self.Collision = math.huge
		end
	else
		if (colllision == 0) then
			self.Collision = true
			self.CollisionN = 0
		else
			self.Collision = false
			self.CollisionN = collision
		end
	end
	return self
end
function SpellData:SetDamage(damageType, baseDamage, perLevelDamage, scalingType, scalingStat, scalingPercent)
	self.Damage = {
		Type = damageType or DamageType.True,
		Base = baseDamage or 0,
		PerLevel = perLevelDamage or 0,
		ScalingType = scalingType,
		ScalingStat = scalingStat,
		ScalingPercent = scalingPercent or 0,
	}
	return self
end
function SpellData:Copy(id, key)
	local spell = SpellData(id, key or self.Key, self.Name, self.Range)
	spell.Mana = self.Mana
	spell:SetRange(self.BaseRange)
	spell:SetSkillshot(self.BaseWidth, self.Delay, self.Speed, self.Collision, self.Type)
	spell:SetAccuracy(self.Accuracy)
	spell.Damage = self.Damage
	return spell
end
function SpellData:IsReady()
	self.Ready = self:IsReadyCallback()
	return self.Ready
end
function SpellData:WillKill(unit)
	return not self:UnitWillDie(unit) and (self:CalculateDamage(unit) > unit.health)
end
function SpellData:CalculateDamage(unit)
	if (not self.Damage) then return 0 end
	return CalcSpellDamage(unit, self)
end
function SpellData:Cast(posX, posZ)
	if (not self.Key) then return false end
	if (posX and not posZ and self:UnitWillDie(posX)) then return false end
	self.Ready = false
	CCastSpell(self.Key, posX, posZ)
	return true
end
function SpellData:CastAt(pos)
	Assert(pos and VectorType(pos), "vector expected for <pos>")
	return self:Cast(pos.x, pos.z)
end
function SpellData:VectorCast(pos)
	return self:CastAt(self:VectorTo(pos))
end
function SpellData:PredictedVectorCast(unit, minHitchance)
	local castPos, hitchance = self:GetPosition(unit)
	if (castPos and (hitchance >= minHitchance or self.Hitchance)) then
		return self:VectorCast(castPos)
	end
	return false
end
function SpellData:CheckCollision(unit, extraRange)
	return Prediction:CheckCollision(unit, self, myHero, extraRange)
end
function SpellData:GetPosition(unit)
	return Prediction:GetPosition(unit, self, myHero)
end
function SpellData:GetHealth(unit)
	return GetPredictedHealth(unit, self:GetCastTime())
end
function SpellData:UnitWillDie(unit)
	if (unit.dead or (unit.health <= 0)) then return true end
	return (self:GetHealth(unit) <= 0)
end
function SpellData:HaveEnoughMana(casts)
	if (not self.Key) then return true end
	local casts = casts or 1
	if (self.Key == _Q) then
		return HaveManaForSpells(self.Mana, casts, 0, 0, 0, 0, 0, 0)
	elseif (self.Key == _W) then
		return HaveManaForSpells(0, 0, self.Mana, casts, 0, 0, 0, 0)
	elseif (self.Key == _E) then
		return HaveManaForSpells(0, 0, 0, 0, self.Mana, casts, 0, 0)
	elseif (self.Key == _R) then
		return HaveManaForSpells(0, 0, 0, 0, 0, 0, self.Mana, casts)
	end
	return false
end
function SpellData:GetCastTime(unit)
	return self.Delay + (GetDistance(myHero, unit) / self.Speed) - GetRealLatency()
end
function SpellData:GetCurrentCooldown()
	if (self.Key) then return myHero:GetSpellData(self.Key).currentCd end
	return 0
end
function SpellData:GetManaCost()
	self.Mana = self.Key and myHero:GetSpellData(self.Key).mana or 0
	return self.Mana
end
function SpellData:InRange(pos, extra)
	if (not pos) then return false end
	local extra = extra or 0
	if (self.Type == SkillshotType.Circular) then
		extra = extra + self.Radius
	end
	return InRange(pos, self.Range + extra)
end
function SpellData:PredictedCast(unit, minHitchance)
	Assert(unit and type(unit.charName) == "string", "hero expected for <unit>")
	Assert(not minHitchance or type(minHitchance) == "number", "number expected fpr <minHitchance>")
	local minHitchance = minHitchance or self.Hitchance
	local castPos, hitchance = self:GetPrediction(unit)
	if (castPos and (hitchance >= minHitchance)) then
		return self:CastAt(castPos)
	end
	return false
end
function SpellData:PredictedAoeCast(unit, minHitchance, minHit)
	local castPos, hitchance, hit = self:GetAoePrediction(unit)
	if (castPos and (hitchance >= minHitchance or self.Hitchance) and (hit >= minHit or 1)) then
		return self:CastAt(castPos)
	end
	return false
end
function SpellData:IsImmobile(unit)
	return Prediction.BasePred1:IsImmobile(target, spell.Delay, spell.Width, spell.Speed, myHero, VSkillshot[spell.Type])
end
function SpellData:GetLevel()
	return GetSpellLevel(self.Key)
end
function SpellData:VectorOut(pos)
	return VectorOut(pos, self.Range)
end
function SpellData:VectorTo(pos)
	local distance = GetDistance(pos)
	local range = (distance > self.Range) and self.Range or distance
	return VectorOut(pos, range)
end
function SpellData:GetName()
	if (self.Key) then
		self.SpellName = (myHero:GetSpellData(self.Key).name)
	end
	return self.SpellName
end
function SpellData:AddCastCallback(callback)
	if (#self.Callbacks == 0) then
		Callbacks:Bind("ProcessSpell", function(unit, spell)
			if (unit and unit.isMe and spell and (spell.name == self.SpellName)) then
				for i = 1, #self.Callbacks do
					self.Callbacks[i](unit, spell, spell.target)
				end
			end
		end)
	end
	table.insert(self.Callbacks, callback)
end
function SpellData:SetAutoAttackResetCallback(callback)
	self.AutoAttackResetCallback = callback
end
function SpellData:SetIsReadyCallback(callback)
	self.IsReadyCallback = callback
end
function SpellData:IsAttackReset()
	self:AddCastCallback(function(_, _, target)
		self.AutoAttackResetCallback(target)
	end)
end
function SpellData:GetEnemiesInRange()
	local enemies = { }
	for i = 1, #Enemies do
		local enemy = Enemies[i]
		if (IsValid(enemy) and self:InRange(self:GetPosition(enemy))) then
			table.insert(enemies, enemy)
		end
	end
	return enemies
end
function SpellData:EnemyIsInRange()
	return (#GetEnemiesInRange(range) > 0)
end
function SpellData:AutoTrack()
	AddTickCallback(function()
		if (myHero.dead) then
			self.Ready = false
		else
			self:IsReady()
		end
	end)
	return self
end
function SpellData:GetPredData()
	return PredData(self.Speed, self.Delay, self.Range, self.Width, self.CollisionN, self.IsAoe, self.Type)
end
function SpellData:GetPredictedHealth(unit)
	return Prediction:GetPredictedHealth(unit, self.Delay + GetDistance(myHero, unit) / self.Speed - GetRealLatency())
end

---//==================================================\\---
--|| > PredData Class									||--
---\===================================================//---

Class("PredData")
function PredData:__init(speed, delay, range, width, collision, aoe, type)
	self.Speed = speed or 0
	self.Delay = delay or 0
	self.Width = width or 0
	self.Radius = Divide(self.Width, 2)
	self.IsAoe = aoe or false
	self.Type = type or SkillshotType.Linear
	self:SetRange(range)
	self:SetCollision(collision)
end
function PredData:SetRange(range)
	self.Range = (range or 0) * 1.5
end
function PredData:SetCollision(collision)
	local collision = collision or math.huge
	if (type(collision) == "number") then
		self.CollisionN = collision
		if (collision < math.huge) then
			self.Collision = true
		else
			self.Collision = false
		end
	else
		self.Collision = collision
		if (collision) then
			self.CollisionN = 0
		else
			self.CollisionN = math.huge
		end
	end
end
function PredData:GetDSkillshot()
	local delay = self.Delay * 1000
	if (self.Type == SkillshotType.Circular) then
		return CircleSS(self.Speed, self.Range, self.Radius, delay, self.CollisionN)
	elseif (self.Type == SkillshotType.Cone) then
		return ConeSS(self.Speed, self.Range, self.Radius, delay, self.CollisionN)
	else
		return LineSS(self.Speed, self.Range, self.Radius, delay, self.CollisionN)
	end
end
function PredData:GetHSkillshot()
	local stype = "DelayLine"
	if (self.Type == SkillshotType.Linear) then
		if (self.Speed == math.huge) then
			stype = "PromptLine"
		end
	elseif (self.Type == SkillshotType.Circular) then
		if (self.Speed == math.huge) then
			stype = "PromptCircle"
		else
			stype = "DelayCircle"
		end
	end
	local data = {
		type = stype,
		delay = self.Delay,
		range = self.Range,
		speed = (self.Speed == math.huge) and nil or self.Speed,
		IsLowAccuracy = self.IsLowAccuracy and true or nil,
		IsVeryLowAccuracy = self.IsVeryLowAccuracy and true or nil,
	}
	if (self.Type == SkillshotType.Linear) then
		data.width = self.Width
		if (self.Collision) then
			data.collisionM = true
			data.collisionH = true
		end
	elseif (self.Type == SkillshotType.Circular) then
		data.radius = self.Width / 2
		data.addunitboundingRadius = true
	else
		data.width = self.Width
	end
	return data
end

---//==================================================\\---
--|| > MenuConfig Class                                 ||--
---\\==================================================//---

function MenuConfig(name, header)
	return scriptConfig(header, name)
end
function scriptConfig:Menu(name, header)
	self:addSubMenu(header, name)
	return self[name]
end
function scriptConfig:Separator()
	self:addParam("nilsep", "-------------------------------------------------------------------", SCRIPT_PARAM_INFO, "")
end
function scriptConfig:Info(info, value)
	local name = Format("Info{1}", info:gsub(" ", ""))
	if (type(value) ~= "string") then value = tostring(value) end
	self:addParam(name, Format("{1}:", info), SCRIPT_PARAM_INFO, value)
end
function scriptConfig:Note(note)
	self:Note2(Format("Note: {1}", note))
end
function scriptConfig:Note2(note)
	self:addParam("nil", note, SCRIPT_PARAM_INFO, "")
end
function scriptConfig:Toggle(name, title, default)
	Assert(name and type(name) == "string", "string expected for <name>")
	Assert(title and type(title) == "string", "string expected for <title>")
	Assert(default == nil or type(default) == "boolean", "nil or boolean expected for <default>")
	self:addParam(name, title, SCRIPT_PARAM_ONOFF, default)
	return { SetCallback = function(_, callback) self:SetCallback(name, callback) end }
end
function scriptConfig:DropDown(name, title, default, list)
	self:addParam(name, Format("{1}:", title), SCRIPT_PARAM_LIST, default, list)
	return { SetCallback = function(_, callback) self:SetCallback(name, callback) end }
end
function scriptConfig:Slider(name, title, default, mininum, maximum, step)
	self:addParam(name, Format("{1}:", title), SCRIPT_PARAM_SLICE, default, mininum, maximum, step)
	return { SetCallback = function(_, callback) self:SetCallback(name, callback) end }
end
function scriptConfig:KeyBinding(name, title, default, key)
	if (type(key) == "string") then
		key = string.byte(key)
	end
	self:addParam(name, title, SCRIPT_PARAM_ONKEYDOWN, default, key)
	return { SetCallback = function(_, callback) self:SetCallback(name, callback) end }
end
function scriptConfig:KeyToggle(name, title, default, key)
	if (type(key == "string")) then
		key = string.byte(key)
	end
	self:addParam(name, title, SCRIPT_PARAM_ONKEYTOGGLE, default, key)
	return { SetCallback = function(_, callback) self:SetCallback(name, callback) end }
end
function scriptConfig:ColorBox(name, title, default)
	self:addParam(name, title, SCRIPT_PARAM_COLOR, ParseColor(default))
	return { SetCallback = function(_, callback) self:SetCallback(name, callback) end }
end
function scriptConfig:Dynamic(name, title, dtype, default, key)
	if (type(key) == "string") then
		key = string.byte(key)
	end
	self:addDynamicParam(name, title, dtype, default, key)
	return { SetCallback = function(_, callback) self:SetCallback(name, callback) end }
end
function scriptConfig:SetCallback(name, callback)
	self:setCallback(name, callback)
end
function scriptConfig:RemoveCallback(name)
	self:removeCallback(name)
end
function scriptConfig:RemoveSubMenu(name)
	self:removeSubMenu(name)
end
function scriptConfig:ModifySubMenu(name, title)
	self:modifySubMenuText(name, title)
end
function scriptConfig:Clear(clearParams, clearSubMenus)
	if (clearParams == nil) then clearParams = true end
	if (clearSubMenus == nil) then clearSubMenus = true end
	self:clear(clearParams, clearSubMenus)
end
function scriptConfig:ClearParams()
	self:Clear(true, false)
end
function scriptConfig:ClearSubMenus()
	self:Clear(false, true)
end
function scriptConfig:Save()
	self:save()
end

---//==================================================\\---
--|| > AdvancedSettings Class							||--
---\\==================================================//---

Class("AdvancedSettings")
function AdvancedSettings:__init(advancedMode)
	self.MenuOrder = { }
	self.AdvancedMode = advancedMode or false
end
function AdvancedSettings:Menu(name, header)
	table.insert(self.MenuOrder, name)
	self[name] = AdvancedSettingsMenu(name, header)
end
function AdvancedSettings:LoadToConfig(config)
	if (self.AdvancedMode) then
		for i = 1, #self.MenuOrder do
			local name = self.MenuOrder[i]
			local menu = self[name]
			config:Menu(name, menu.Header)
			self:LoadMenuToConfig(menu, config[name])
		end
		return config
	else
		local settings = { }
		for i = 1, #self.MenuOrder do
			local name = self.MenuOrder[i]
			settings[name] = self:LoadMenuToConfig(self[name])
		end
		return settings
	end
end
function AdvancedSettings:LoadMenuToConfig(menu, config)
	local name = menu.Name
	local menuOrder = menu.MenuOrder
	local params = menu.Params
	local paramOrder = menu.ParamOrder
	if (self.AdvancedMode) then
		for i = 1, #menuOrder do
			local menuName = menuOrder[i]
			local menu = menu[menuName]
			config:Menu(menuName, menu.Header)
			self:LoadMenuToConfig(menu, config[menuName])
		end
		for i = 1, #paramOrder do
			local paramName = paramOrder[i]
			local param = params[paramName]
			config:addParam(paramName, param.Header, param.Type, param.Param1, param.Param2, param.Param3)
		end
	else
		local settings = { }
		for i = 1, #menuOrder do
			local menuName = menuOrder[i]
			settings[menuName] = self:LoadMenuToConfig(menu[menuName])
		end
		for i = 1, #paramOrder do
			local paramName = paramOrder[i]
			settings[paramName] = params[paramName].Param1
		end
		return settings
	end
end

Class("AdvancedSettingsMenu")
function AdvancedSettingsMenu:__init(name, header)
	self.Name = name
	self.Header = header
	self.Params = { }
	self.ParamOrder = { }
	self.MenuOrder = { }
end
function AdvancedSettingsMenu:Menu(name, header)
	table.insert(self.MenuOrder, name)
	self[name] = AdvancedSettingsMenu(name, header)
end
function AdvancedSettingsMenu:Param(name, header, paramType, param1, param2, param3)
	table.insert(self.ParamOrder, name)
	if (not self.Params[name]) then
		self.Params[name] = {
			Header = header,
			Type = paramType,
			Param1 = param1,
			Param2 = param2,
			Param3 = param3,
		}
	end
end
function AdvancedSettingsMenu:Separator()
	local name = "Sep"
	if (not self.Params.Separator) then
		self:Param(name, "-------------------------------------------------------------------", SCRIPT_PARAM_INFO, "")
	end
end
function AdvancedSettingsMenu:Info(info, value)
	local name = Format("Info{1}", info:gsub(" ", ""))
	if (type(value) ~= "string") then value = tostring(value) end
	self:Param(name, Format("{1}:", info), SCRIPT_PARAM_INFO, value)
end
function AdvancedSettingsMenu:Note(note)
	self:Param("nil", Format("Note: {1}", note), SCRIPT_PARAM_INFO, "")
end
function AdvancedSettingsMenu:Toggle(name, title, default)
	self:Param(name, title, SCRIPT_PARAM_ONOFF, default)
end
function AdvancedSettingsMenu:DropDown(name, title, default, list)
	self:Param(name, title, SCRIPT_PARAM_LIST, default, list)
end
function AdvancedSettingsMenu:Slider(name, title, default, mininum, maximum)
	self:Param(name, Format("{1}:", title), SCRIPT_PARAM_SLICE, default, mininum, maximum)
end
function AdvancedSettingsMenu:KeyBinding(name, title, default, key)
	if (type(key) == "string") then
		key = string.byte(key)
	end
	self:Param(name, title, SCRIPT_PARAM_ONKEYDOWN, default, key)
end
function AdvancedSettingsMenu:KeyToggle(name, title, default, key)
	if (type(key == "string")) then
		key = string.byte(key)
	end
	self:Param(name, title, SCRIPT_PARAM_ONKEYTOGGLE, default, key)
end
function AdvancedSettingsMenu:ColorBox(name, title, default)
	self:Param(name, title, SCRIPT_PARAM_COLOR, ParseColor(default))
end

-- End of GodLib.
