--[[
WoW Addon
Name: Mobspell
Description: Record spells cast by npcs
Version: 7.0.00
Author: makazeu@gmail.com
]]
local eventtype, sourceGUID, sourceName, spellid, spellschool, sourcetype, sourceid
local mapName, channel, spellchar, tempchar, spellinfo, spellcolor
local MaxCharacterLength = 250
local colorcodes = {[1] = "FFFF00", [2] = "FFE680", [4] = "FF8000", 
[8] = "4DFF4D", [16] = "80FFFF",[32] = "8080FF",[64] = "FF80FF", }

--local EventTypes = {["SPELL_CAST_START"] = true, 
--["SPELL_CAST_SUCCESS"] = true, ["SPELL_AURA_APPLIED"] = true, }
------ Event types that we care about
local EventTypes = {
	SPELL_DAMAGE = true,
	SPELL_MISSED = true,
	SPELL_HEAL = true,
	SPELL_ENERGIZE = true,
	SPELL_DRAIN = true,
	SPELL_LEECH = true,
	SPELL_AURA_APPLIED = true,
	SPELL_CAST_START = true,
	SPELL_CAST_SUCCESS = true,
	SPELL_CAST_FAILED = true,
	SPELL_CREATE = true,
	SPELL_SUMMON = true,
	SPELL_INSTAKILL = true,
	SPELL_PERIODIC_DAMAGE = true,
	SPELL_PERIODIC_HEAL = true,
} 
local UnknownObjectLocale = {
	["未知目标"] = true,
	["Unknown"] = true,
}

local StarterFrame = CreateFrame("Frame")
StarterFrame:RegisterEvent("ADDON_LOADED")
StarterFrame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "Mobspell" then
		if spelldb == nil then 
			spelldb = {}
		end
		print("|cFFFF8000Mobspell is loaded!|r")
	end
end)

local function GetSpellColored(spellname, spellschool) 
	if not colorcodes[spellschool] then 
		return spellname
	else 
		return "|cFF"..colorcodes[spellschool]..spellname.."|r"
	end
end

local function  MySpellLinker( MySpellID, MySpellSchool )
	spellinfo = GetSpellInfo(MySpellID)
	if not spellinfo then return end
	spellcolor = colorcodes[MySpellSchool] or "FFD000"
	return "\124cFF"..spellcolor.."\124Hspell:"..MySpellID.."\124h["..spellinfo.."]\124h\124r"
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		--_, eventtype, _, sourceGUID, sourceName = ...
		_, eventtype, _, sourceGUID, sourceName = ...
		--print(sourceGUID.." "..sourceName)
		if  EventTypes[eventtype] then
			sourcetype, _, _, _, _, sourceid, _ = strsplit("-", sourceGUID)
			sourceid = tonumber(sourceid)
			mapName = GetRealZoneText()
			spellid, _, spellschool = select(12, ...)
			--print(sourcetype.." "..sourceid.." "..spellid.." "..spellnamet)
			if sourcetype~="Player" and sourcetype ~="Pet" and sourceid and mapName then
				if spelldb[mapName] and spelldb[mapName][sourceid] and spelldb[mapName][sourceid].spell[spellid] then
					--if sourceName]~= "未知目标" then
					if UnknownObjectLocale[sourceName] then
						spelldb[mapName][sourceid].name = sourceName
					end
				elseif not SPELL_BLACKLIST[spellid] and not MOB_BLACKLIST[sourceid] and not SPELL_BANNED[spellid] then
					if not spelldb[mapName] then spelldb[mapName] = {} end			
					if not spelldb[mapName][sourceid] then 
						spelldb[mapName][sourceid] = { name = sourceName }
						spelldb[mapName][sourceid].spell = { [spellid] = spellschool }
					else
						spelldb[mapName][sourceid].spell[spellid] = spellschool						
					end
				end
			end
		end
	end
end)

local script = GameTooltip:GetScript("OnTooltipSetUnit") 
local function HookedOnTooltipSetUnit( frame, ... )
	if script and type(script) == "function" then
		script(frame, ...)
	end
	local unitid = select(2,GameTooltip:GetUnit())
	if unitid then
		local guid = UnitGUID(unitid)
		local type, _, _, _, _, npcid, _ = strsplit("-",guid)
		npcid = tonumber(npcid)
		mapName = GetRealZoneText()
		if type == "Player" or type == "Pet" or not npcid or not mapName or 
			not spelldb[mapName] or not spelldb[mapName][npcid]  then return end
		spellchar = ""
		for k,v in pairs(spelldb[mapName][npcid].spell) do
			if not GetSpellInfo(k) then
				print("檢測到無效法術: "..spelldb[mapName][npcid].name.." - "..k)
			else
				spellchar = spellchar.." "..GetSpellColored(GetSpellInfo(k),v)
			end
		end
		frame:AddLine("法術:"..spellchar, 1, 1, 1, true)
	end
end
GameTooltip:SetScript("OnTooltipSetUnit", HookedOnTooltipSetUnit)  

SLASH_MOBSPELL1, SLASH_MOBSPELL2 = "/mobspell", "/ms"
local function handler( msg, editbox )
	local guid, name, type, npcid
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if command == "clear" then
		for i,iv in pairs(spelldb) do
			for j,jv in pairs(iv) do
				if MOB_BLACKLIST[j] then
					print(jv.name.." in "..i.." has been removed.")
					spelldb[i][j] = nil 
				end
				if spelldb[i][j] then
					for k, kv in  pairs(jv.spell) do
						if SPELL_BLACKLIST[k] then
							print(jv.name.." in "..i.." has been removed for "..MySpellLinker(k,kv)..".")
							spelldb[i][j] = nil
							break
						end
						if not GetSpellInfo(k) then
							print(jv.name.." - "..k.." in "..i.." has been removed for not existing.")
							spelldb[i][j].spell[k] = nil
						end
					end
					for k, kv in  pairs(jv.spell) do
						if SPELL_BANNED[k] then
							print(jv.name.." - "..MySpellLinker(k,kv).." in "..i.." has been removed for BlackList.")
							spelldb[i][j].spell[k] = nil
						end
					end
				end
			end
		end
	end

	if command == "finds" and rest ~= "" then
		local resultnum = 0
		local maxresultnum = 50
		for i,iv in pairs(spelldb) do
			for j,jv in pairs(iv) do
				for k,kv in pairs(jv.spell) do
					if GetSpellInfo(k) and strfind(GetSpellInfo(k),rest) then
						print("|cFFFF8000"..jv.name.."|r("..j..")@|cFF8080FF"..i.."|r - "..MySpellLinker(k,kv))
						resultnum = resultnum +1
						if resultnum > maxresultnum then 
							print("查詢結果已到達"..maxresultnum.."條之上限！")
							return 
						end
					end
				end
			end
		end
		print("Mobspell已找到|cFFFF80FF"..resultnum.."|r條關於“"..rest.."”的查詢結果。")
	end

	mapName = GetRealZoneText()
	if not mapName or not spelldb[mapName] then return end
	if rest == "" then
		guid , name = UnitGUID("target"), UnitName("target")
		if guid == nil then return end
		type, _, _, _, _, npcid, _ = strsplit("-",guid)
		npcid = tonumber(npcid)
		if type == "Player" or type == "Pet"  or not npcid or 
		not spelldb[mapName][npcid] then return end
	else
		npcid = tonumber(rest)
		if not npcid or not spelldb[mapName][npcid] then return end
		name = spelldb[mapName][npcid].name
	end
	if command == "print" then
		spellchar = ""
		for k,v in pairs(spelldb[mapName][npcid].spell) do
			spellchar = spellchar.." "..MySpellLinker(k,v)
		end	
		print(name.." casts:"..spellchar)
	elseif command == "report"  then
		spellchar = name.." casts:"
		channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "Raid" or IsInGroup() and "Party"
		for k,v in pairs(spelldb[mapName][npcid].spell) do
			tempchar = spellchar.." "..GetSpellLink(k)
			if strlen(tempchar) > MaxCharacterLength then
				SendChatMessage(spellchar, channel)
				spellchar = GetSpellLink(k)
			else
				spellchar = tempchar
			end
		end
		SendChatMessage(spellchar, channel)
	end
end
SlashCmdList["MOBSPELL"] = handler