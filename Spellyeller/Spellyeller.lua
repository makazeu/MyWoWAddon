--[[
Script: WoW Spell Yeller
Author : Makazeu
Version: 3.1.1
makazeu@gmail.com
Thanks: Blizzard, Gamepedia, Wowprogramming, Wowwiki
]]
local FeastSpell = { 
--熊貓人大餐
	[104958] = true, [105193] = true, [126492] = true, [126494] = true, 
	[126495] = true, [126496] = true, [126497] = true, [126498] = true, 
--熊貓人餐車
	[145166] = true, [145169] = true, [145196] = true, 
--德拉諾大餐
	[160914] = true,  [175215] = true, [160740] = true, 
}
local RaidFunctions = { 
	[176246] = true, [176244] = true, --阿什蘭 
	[132620] = true, [132626] = true, --錦繡谷
	[88345] = true,   [88346] = true, --托爾巴拉德
	[120146] = true, [53142] = true, --(遠古)達拉然
	[33691] = true,   [35717] = true, --沙塔斯
	[49361] = true,  [49360] = true, --斯通納德，塞拉摩
	[11419] = true,   [11418] = true,  --達納蘇斯，幽暗城
	[32266] = true,  [32267] = true, --埃索達，銀月城  
	[11416] = true,  [11420] = true, --鐵爐堡，雷霆崖
	[11417] = true, [10059] = true, --奧格瑞瑪，暴風城
	[67826] = true, [157066] = true,  -- 基維斯/修理機器人
	[126459] = true, [161414] = true, -- 布林頓4000/5000
	[54710] = true, [156756] = true,  -- 移動郵箱 
	--[43987] = true, -- 召喚餐桌
	--[698] = true, [29893] = true, -- 術士拉人/靈魂之井
}
local ImportantAbility = {
	[108280] = true,  -- 療癒之潮圖騰 Shaman
	[740] = true, -- 寧靜 Druid
	[115310] = true, -- 還魂術(五氣歸元) Monk
	[64843] = true, [64844] = true, -- 神聖讚美詩 Priest
	[76577] = true, -- 煙霧彈 Rogue 
	[51052] = true, [145629] = true, -- 反魔法力場 DeathKnight
	[31821] = true, [31821] = true, -- 虔誠光環 Paladin
	[98008] = true, -- 靈魂鏈接圖騰 Shaman
	[62618] = true, [81782] = true, -- 真言術·障 Priest
	--[159916] = true, -- 魔法增效 Mage
	--[97462] = true, [97463] = true, -- 振奮咆哮 Warrior
	--[172106] = true, -- 靈狐守護 Hunter
	--[106898] = true, -- 奔竄咆哮 Druid
	--[77764] = true, -- 狂奔怒吼 Druid
	-- Warlords Legendary Ring Procs
	[187615] = true, -- Maalus	  (Agi L.Ring)
	[187611] = true, -- Nithramus (Int L.Ring)
	[187614] = true, -- Thorasus  (Str L.Ring)
}
local PersonalAbility = {
	[102342] = true, -- 鐵樹皮術 
	[116849] = true, -- 氣繭護體
	[633] = true, -- 聖療術
	[6940] = true, -- 犧牲
	[33206] = true, -- 痛苦鎮壓
	[47788] = true, -- 守護聖靈
	[114030] = true, -- 戒備守護
	[1038] = true, -- 拯救聖禦
	[1022] = true, -- 保護之手
	[20484] = true, -- 復生
	[61999] = true, -- 復活盟友
	[20707] = true, -- 靈魂石復活
	[61999] = true, -- 盟友復生
	[126393] = true, -- 永恒守护者
	[159956] = true, -- 生命之塵
	--[19750] = true,
}
local StatusWord = {
	["total"] = "總開關",
	["yell"] = "打斷喊話(個人)",
	["death"] = "死亡通報(隊伍)",
	["cb"] = "破控提示(隊伍)",
	["pa"] = "單體減傷(隊伍)",
	["raidcd"] = "團隊技能(隊伍)",
	["ir"] = "打斷通報(隊伍)",
	["alert"] = "戰鬥技能警報(隊伍)",
}
local DeadlyspellStart = {
}
local DeadlyspellSucc = {
}
local AuraList = {
	[156743] = "【擋槍俠】",
	[175020] = "【擋槍俠】",
}
local SpellSchoolCode = {[1] = "物理", [2] = "神聖", [4] = "火焰", [8] = "自然", [16] = "冰霜", [32] = "暗影", [64] = "奧術",}
local EnvironmentalType = { ["Falling"] = "墜落", ["Drowning"] = "溺水", ["Fatigue"] = "疲勞", ["Fire"] = "火焰", ["Lava"] = "岩漿", ["Slime"] = "軟泥", }
local localizedenvirtype

local playerGUID = UnitGUID("player")
local InEncounter
--頻道
local personalchannel = "yell", channel, alertchannel;
-- Combat log returns
local timestamp, type, hideCaster,sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags;
local spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool; 
local amount, overkill, spellschoolname;
local spellLink, extraSpellLink, envirtype;
--死亡通報
local Maxdeathnumber = 6
local deathcount = 0
local dinterval =6
local deathvector = {}
local PriestDeathSpell = { }
local deadname
local deadguid
local dead
local addonstatus
---
local starttimestamp
local chatitem = 10
local tt
local PriestSpell = { }
local ControlSpell = { [3355] = true, [51514] = true, [6110] = true, }
-------------------------------------------------------
SLASH_SPELLYELLER1 = '/sy'
local function NumberFormat(number)
	if number < 10000 then 
		return number
	else
		return floor(number / 1000) .. "K"
	end
end

local function Initialize(  )
	playerGUID = UnitGUID("player");
	syswitches = { ["total"]=1,["yell"]=1, ["death"]=1, 
		["raidcd"]=1,["cb"] =-1,["ir"]=-1,["pa"]=-1,["alert"]=-1, }
	InEncounter = 0
	print("|cFFFF7D0ASpellyeller|r has been initialized.");
end

local function handler(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$");
	local i,v;
	if (command == "init") then
		Initialize()
	elseif command == "on" then
		syswitches["total"] = 1
		print("|cFFFF7D0ASpellyeller已經開啓！|r");
	elseif command == "off" then
		syswitches["total"] = -1
		print("|cFFFF7D0ASpellyeller已經關閉！|r");
	elseif command == "setraidnum" and rest ~= "" then
		rest = tonumber(rest)
		Maxdeathnumber = rest
	elseif command == "rch" then
		--[[rest = rest and tonumber(rest) or 1;
		for i = (rest-1)*chatitem+1,rest*chatitem do
			if(i>RaidCDNumber) then break end
		end--]]
		SendChatMessage("上次战斗中团队技能施放情况:","raid")
		for i = 1,RaidCDNumber do 
			tt = RaidCDList[i];
			SendChatMessage("("..i.."/"..RaidCDNumber..") "..floor(tt.times/ 60 ).."m "..tt.times% 60 .."s - "..tt.source.." : "..GetSpellLink(tt.id),"raid")
		end
	elseif command == "prch" then
		if not RaidCDNumber or not RaidCDList then print("查無此數據！") return end
		print("上次戰鬥中團隊技能施放 "..RaidCDNumber.." 次：");
		for i,v in pairs(RaidCDList) do
			print(floor(v.times/ 60 ).."m "..v.times% 60 .."s - "..v.source.." : "..GetSpellLink(v.id));
		end 
	elseif command == "status" then
		addonstatus = syswitches["total"] == 1 and "|cFFFF8000ON|r" or "|cFFBF00FFOFF|r"
		print("total - "..StatusWord["total"].." : "..addonstatus)
		local k,v
		for k,v in pairs(StatusWord) do
			if k ~= "total" then 
				addonstatus = syswitches[k] == 1 and "|cFFFF8000ON|r" or "|cFFBF00FFOFF|r"
				print(k.." - "..v.." : "..addonstatus)
			end
		end
	else 
		if not syswitches[command] then return end
		syswitches[command] = - syswitches[command]
		addonstatus = syswitches[command] == 1 and "|cFFBF00FFON|r" or "|cFFBF00FFOFF|r"
		print("|cFFFF7D0AWoW Spell Yeller|r : "..StatusWord[command].." "..addonstatus..".")
	end
end
SlashCmdList["SPELLYELLER"] = handler;
-------------------------------------------------------
local function IsPartyMember( thisname, thisguid )
	return UnitInParty(thisname) and strsub(thisguid,1,2) == "Pl"
end
local function CheckDeath( tsourceGUID, tdestGUID, tdestName )
	if not IsPartyMember( tdestName, tdestGUID ) then return false end
	return true
end
-------------------------------------------------------
local StarterFrame = CreateFrame("Frame")
StarterFrame:RegisterEvent("ADDON_LOADED")
StarterFrame:RegisterEvent("PLAYER_ALIVE")
StarterFrame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "Spellyeller" then
		if syswitches == nil then
			Initialize()
		end
	end
	if event == "PLAYER_ALIVE" then
		playerGUID = UnitGUID("player")
	end
end)

local frame = CreateFrame("Frame");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
frame:RegisterEvent("ENCOUNTER_START");
frame:RegisterEvent("ENCOUNTER_END");
frame:SetScript("OnEvent", function(self, event, ...)
	if(event == "ENCOUNTER_START") then
		InEncounter = 1; deathcount = 0;
		starttimestamp = time();
		RaidCDNumber = 0; RaidCDList = {}; 
		FalseDamage = {}; print("首領戰開始！");
	elseif(event == "ENCOUNTER_END") then
		InEncounter = -1;
		print("首領戰結束！");    
	end

	if event == "COMBAT_LOG_EVENT_UNFILTERED" and syswitches["total"]==1 then
		timestamp, type, hideCaster,sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
		channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "Raid" or IsInGroup() and "Party"
		alertchannel = ( UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and "RAID_WARNING" or "Raid"

		if (syswitches["cb"]==1 and type == "SPELL_AURA_BROKEN_SPELL") then
			spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool = select(12, ...)
			spellLink = GetSpellLink(spellId)
			extraSpellLink = GetSpellLink(extraSpellId)
			if (ControlSpell[spellId] or spellName == GetSpellInfo(118)) and (sourceName and IsPartyMember(sourceName,sourceGUID)) then
				SendChatMessage("【破控】 "..sourceName..extraSpellLink.." => "..spellLink.."@"..destName, channel)
			end
		end

		if syswitches["yell"]==1 and type == "SPELL_STOLEN" then --法術竊取
			spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool = select(12, ...)
			spellLink = GetSpellLink(spellId)
			extraSpellLink = GetSpellLink(extraSpellId)
			if(sourceGUID == playerGUID) then
				SendChatMessage("[偷] "..spellLink.." => "..destName.." "..extraSpellLink, personalchannel)
			elseif (destGUID == playerGUID) then
				SendChatMessage("[偷]"..extraSpellLink.." <= ".. sourceName.." "..spellLink, personalchannel)
			end
		end
 
		if syswitches["yell"]==1 and type == "SPELL_DISPEL" then  --驅散
			 spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool = select(12, ...)
			spellLink = GetSpellLink(spellId)
			extraSpellLink = GetSpellLink(extraSpellId)
			if(sourceGUID == playerGUID) then 
				SendChatMessage("[驅]"..spellLink.." => "..destName.." "..extraSpellLink, personalchannel)
			elseif (destGUID == playerGUID) then
				SendChatMessage("[驅]"..extraSpellLink.." <= ".. sourceName.." "..spellLink, personalchannel)
			end
		end

		if syswitches["yell"]==1 and type == "SPELL_INTERRUPT" then  --打斷
			spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool = select(12, ...)
			spellLink = GetSpellLink(spellId)
			extraSpellLink = GetSpellLink(extraSpellId)
			if(sourceGUID == playerGUID) then
				SendChatMessage("[斷]"..spellLink.." => "..destName.." "..extraSpellLink, personalchannel)
			 elseif (destGUID == playerGUID) then
				SendChatMessage("[斷]"..extraSpellLink.." <= ".. sourceName.." "..spellLink, personalchannel)
			end
		end
		if type == "SPELL_INTERRUPT" and syswitches["ir"] == 1 and IsPartyMember(sourceName,sourceGUID) then
			spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool = select(12, ...)
			spellLink = GetSpellLink(spellId)
			extraSpellLink = GetSpellLink(extraSpellId)
			SendChatMessage("打斷: "..sourceName..spellLink.." => "..destName..extraSpellLink,channel)
		end
		if type == "SPELL_DAMAGE"  or type == "SPELL_PERIODIC_DAMAGE" or type == "RANGE_DAMAGE"  then
			spellId, spellName, spellSchool, amount,overkill = select(12, ...)
			if overkill >=0 and sourceGUID == playerGUID and strsub(destGUID,1,2) == "Pl" then
				print("|cffffd200PvP: 親手擊殺|r |cFFBF00FF>"..destName.."<|r!")
			end
		end

		--死亡通報    
		if(syswitches["death"] == 1 and ( (InEncounter == 1 and deathcount < Maxdeathnumber) or InEncounter ~= 1)) then
			if ( type == "SPELL_DAMAGE"  or type == "SPELL_PERIODIC_DAMAGE" or type == "RANGE_DAMAGE")  then
				spellId, spellName, spellSchool, amount,overkill = select(12, ...)
				if CheckDeath(sourceGUID, destGUID, destName) then
					if overkill >= 0 then
						deathvector[destName] = {["type"] = "SPELL"}
						deathvector[destName]["id"] = spellId
						deathvector[destName]["school"] = spellSchool
						deathvector[destName]["amount"] = amount
						deathvector[destName]["tstamp"] = time()
					elseif select(3,UnitClass(destName)) == 5 then
						PriestDeathSpell[destName] = {["times"] = time()}
						PriestDeathSpell[destName]["spell"] = spellId
						PriestDeathSpell[destName]["school"] = spellSchool
						PriestDeathSpell[destName]["damage"] = amount
					end
				end
			elseif ( type == "SWING_DAMAGE") then
				amount, overkill = select(12, ...)
				if CheckDeath(sourceGUID, destGUID, destName) then
					if overkill >= 0 then
						deathvector[destName]={["type"] = "SWING"}
						deathvector[destName]["amount"] = amount
						deathvector[destName]["source"] = sourceName
						deathvector[destName]["tstamp"] = time()
					elseif select(3,UnitClass(destName)) == 5 then
						PriestDeathSpell[destName] = {["times"] = time()}
						PriestDeathSpell[destName]["spell"] = 6603
						PriestDeathSpell[destName]["school"] = 1
						PriestDeathSpell[destName]["damage"] = amount
					end
				end
			elseif(type == "SPELL_INSTAKILL" ) then
				if IsPartyMember( destName, destGUID ) then
					print(destName.." killed by "..sourceName..GetSpellLink(spellId))
					deathvector[destName]={["type"] = "INSTAKILL"}
					deathvector[destName]["id"] = spellId
					deathvector[destName]["tstamp"] = time()
					if  strsub(sourceGUID,1,2)  == "Pl" and select(3,UnitClass(destName)) == 6 then 
						deathvector[destName]["id"] = 114556  -- DK 煉獄
					end
					if strsub(sourceGUID,1,2)  == "Pl" and select(3,UnitClass(destName)) ~= 6 then
						deathvector[destName]["id"] = 41220 
					end
				end
			elseif( type == "ENVIRONMENTAL_DAMAGE" ) then
				envirtype, amount = select(12, ...)
				if UnitHealth(destName) <= 1 and IsPartyMember(destName, destGUID) then
					localizedenvirtype = EnvironmentalType[envirtype] or envirtype
					SendChatMessage("死亡: "..destName.." > "..localizedenvirtype.."("..NumberFormat(amount).."環境傷害)!",channel)
					deathcount = InEncounter == 1 and deathcount + 1
				end
			elseif type == "UNIT_DIED" or type == "SPELL_AURA_APPLIED" then
				deadname = select(9, ...)
				deadguid = select(8, ...)
				dead = nil
				if type == "UNIT_DIED"and IsPartyMember(deadname, deadguid) then 
					dead = deathvector[deadname] 
					deathvector[deadname] = nil
				end
				if type == "SPELL_AURA_APPLIED" and UnitInParty(deadname) then
					spellId = select(12, ...)
					if spellId == 27827 then -- 神牧 救贖之魂
						print(time().." "..GetSpellLink(spellId).." ".. deadname) 
						dead = deathvector[deadname]
						if not dead or time()-dead.tstamp > dinterval then
							tt = PriestDeathSpell[deadname]
							if tt and time()-tt.times <= dinterval then
								spellLink = GetSpellLink(tt.spell)
 								spellschoolname = SpellSchoolCode[tt.school] or "其他"
 								SendChatMessage("死亡: "..deadname.." > "..spellLink.."("..NumberFormat(tt.damage)..spellschoolname..")!",channel)
							else 
								SendChatMessage("死亡: "..deadname.." > Unknown!",channel)
							end 
							deathcount = InEncounter == 1 and deathcount + 1
						end
					end
				end
				if  dead and time()-dead.tstamp <= dinterval and dead.type == "SPELL" then
					spellLink = GetSpellLink(dead.id)
 					spellschoolname = SpellSchoolCode[dead.school] or "其他"
 					SendChatMessage("死亡: "..deadname.." > "..spellLink.."("..NumberFormat(dead.amount)..spellschoolname..")!",channel)
					deathcount = InEncounter == 1 and deathcount + 1
				elseif dead and time()-dead.tstamp <= dinterval and dead.type == "SWING" then
					SendChatMessage("死亡: "..deadname.." > "..dead.source.."的近戰攻擊("..NumberFormat(dead.amount)..")!",channel)
					deathcount = InEncounter == 1 and deathcount + 1
				elseif dead and time()-dead.tstamp <= dinterval and dead.type == "INSTAKILL" then
					spellLink = GetSpellLink(dead.id)
					SendChatMessage("死亡: "..deadname.." > "..spellLink.."(立即死亡)!", channel)
					deathcount = InEncounter == 1 and deathcount + 1
				end
			end
		end

		--技能警報
		if syswitches["alert"] == 1 then
			--Buff or Debuff
			if (type == "SPELL_AURA_APPLIED" or type == "SPELL_AURA_REFRESH" ) then 
				spellId, spellName, spellSchool = select(12, ...)
				if ( UnitInParty(destName) and AuraList[spellId] ) then
					spellLink = GetSpellLink(spellId)
					SendChatMessage( AuraList[spellId]..destName, alertchannel )
				end
			end
			--[[開始施法
			if ( type == "SPELL_CAST_START"  and alertswitch == 1) then
				spellId, spellName, spellSchool = select(12, ...)
				if ( DeadlyspellStart[spellId]  ) then
					spellLink = GetSpellLink(spellId)
					--print( type.." : "..spellLink.." -> "..destName)
				end
			end
			--施法成功、開始引導
			if ( type == "SPELL_CAST_SUCCESS"  ) then
				spellId, spellName, spellSchool = select(12, ...)
				if ( DeadlyspellSucc[spellId]  ) then
					spellLink = GetSpellLink(spellId)
					--print( type.." : "..spellLink.." -> "..destName)
				end
			end--]]
		end 

		--各種雜項
		if UnitInParty(sourceName) and type == "SPELL_CAST_SUCCESS" then
			spellId, spellName, spellSchool = select(12, ...)
			spellLink = GetSpellLink(spellId)
			if RaidFunctions[spellId]  then
				SendChatMessage(sourceName.." >> "..spellLink..".", channel)
			end
			--elseif ( FeastSpell[spellId] ) then
			--	SendChatMessage(sourceName.."'s placed "..spellLink..".", channel)	
			if  syswitches["raidcd"] == 1 then -- Raid Cooldown
				if (ImportantAbility[spellId]) then -- 團隊大技能、減傷
					local holyp = true
					if spellName == GetSpellInfo(64843) then
						holyp = (not PriestSpell[sourceName]) or (time()-PriestSpell[sourceName] >20)
						PriestSpell[sourceName] = time()
					end
					if holyp then
						if( starttimestamp and InEncounter == 1 ) then
							RaidCDNumber = RaidCDNumber + 1
							RaidCDList[RaidCDNumber] = {id = spellId, times = time() - starttimestamp, source = sourceName }
						end
						SendChatMessage(sourceName.." : "..spellLink, channel)
					end
				end
			end
			if syswitches["pa"] == 1 and PersonalAbility[spellId] then 
				SendChatMessage(sourceName..spellLink.." => "..destName, channel)
			end 
		end
	end 
end)