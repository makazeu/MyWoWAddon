--[[
Script: WoW Spell Yeller
Author : Makazeu
Version: 2.8.4
makazeu@gmail.com
Thanks: Blizzard, Gamepedia, Wowprogramming, Wowwiki
#FuckGFW
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
	[115310] = true, -- 五氣歸元 Monk
	[64843] = true, [64844] = true, -- 神聖讚美詩 Priest
	[76577] = true, -- 煙霧彈 Rogue 
	[51052] = true, [145629] = true, -- 反魔法力場 DeathKnight
	[31821] = true, [31821] = true, -- 虔誠光環 Paladin
	[98008] = true, -- 靈魂鏈接圖騰 Shaman
	[62618] = true, [81782] = true, -- 真言術·障 Priest
	[159916] = true, -- 魔法增效 Mage
	[97462] = true, [97463] = true, -- 振奮咆哮 Warrior
	--[172106] = true, -- 靈狐守護 Hunter
	--[106898] = true, -- 奔竄咆哮 Druid
	--[77764] = true, -- 狂奔怒吼 Druid
}
local PersonalAbility = {
	[102342] = true, -- 鐵樹皮術 
	[116849] = true, -- 氣繭護體
	[633] = true, -- 聖療術
	[6940] = true, -- 犧牲
	[33206] = true, -- 痛苦鎮壓
	[47788] = true, -- 守護聖靈
	[114030] = true, -- 戒備守護
	[20484] = true, -- 復生
	[20707] = true, -- 靈魂石復活
	[61999] = true, -- 盟友復生
	[126393] = true, -- 永恒守护者
	[1038] = true, -- 拯救聖禦
}
local DeadlyspellStart = {
}
local DeadlyspellSucc = {
}
local AuraList = {
}
local SpellSchoolCode = {[1] = "物理", [2] = "神聖", [4] = "火焰", [8] = "自然", [16] = "冰霜", [32] = "暗影", [64] = "奧術",}
local EnvironmentalType = { ["Falling"] = "墜落", ["Drowning"] = "溺水", ["Fatigue"] = "疲勞", ["Fire"] = "火焰", ["Lava"] = "岩漿", ["Slime"] = "軟泥", }
local localizedenvirtype

local playerGUID = UnitGUID("player");
local InEncounter;
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
--開關變量
local switches = { ["yell"]=1, ["death"]=1, ["alert"]=-1, ["raidcd"]=1, ["falsedmg"]=-1, }
local addonstatus;
--
local starttimestamp;
local chatitem = 10;
local tt;
---
local FalseDamage =  { } -- ["Test1"] = 12345678, ["Test2"] = 1234567, 
local FalseDamageNumber = 9
local PriestSpell = { }
-------------------------------------------------------
SLASH_SPELLYELLER1 = '/sy';
local function handler(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$");
	local i,v;
	if (command == "init") then
		playerGUID = UnitGUID("player");
		switches = { ["yell"]=1, ["death"]=1, ["alert"]=-1, ["raidcd"]=1, ["falsedmg"]=-1, }
		InEncounter = 0;  
		print("|cFFFF7D0AWoW Spell Yeller|r is initialized.");
	elseif command == "setraidnum" and rest ~= "" then
		rest = tonumber(rest)
		Maxdeathnumber = rest
	elseif (command == "rch") then
		rest = rest and tonumber(rest) or 1;
		for i = (rest-1)*chatitem+1,rest*chatitem do
			if(i>RaidCDNumber) then break end
			tt = RaidCDList[i];
			SendChatMessage("("..i.."/"..RaidCDNumber..") "..floor(tt.times/ 60 ).."m "..tt.times% 60 .."s - "..tt.source.." : "..GetSpellLink(tt.id),"raid")
		end
	elseif (command == "prch") then
		if not RaidCDNumber or not RaidCDList then print("查無此數據！") return end
		print("上次戰鬥中團隊技能施放 "..RaidCDNumber.." 次：");
		for i,v in pairs(RaidCDList) do
			print(floor(v.times/ 60 ).."m "..v.times% 60 .."s - "..v.source.." : "..GetSpellLink(v.id));
		end 
	elseif command == "fd" then
		if not FalseDamage then return end
		local tablecount = 0
		for k,v in pairs(FalseDamage) do tablecount = tablecount + 1 end
		if tablecount == 0 then
			if rest == "r" then SendChatMessage("上次戰鬥未記錄到隊友誤傷！", "raid") end
			print("上次戰鬥未記錄到隊友誤傷！") return
		else
			print("隊友誤傷通報：")
			if rest == "r" then SendChatMessage("隊友誤傷通報：", "raid") end
		end

		local fdmaxnum
		local fdmaxname
		local fdprinted = {}
		for i = 1, min(tablecount, FalseDamageNumber) do
			fdmaxnum = 0
			for k,v in pairs(FalseDamage) do
				if v > fdmaxnum and not fdprinted[k] then
					fdmaxnum = v
					fdmaxname = k
				end
			end
			fdprinted[fdmaxname] = true
			print(i..". "..fdmaxname.." - ".. floor(fdmaxnum / 1000) .."K")
			if rest == "r" then SendChatMessage(i..". "..fdmaxname.." - "..floor(fdmaxnum / 1000) .."K", "raid") end
		end
	else 
		if not switches[command] then return end
		switches[command] = - switches[command]
		addonstatus = switches[command] == 1 and "|cFFBF00FFON|r" or "|cFFBF00FFOFF|r"
		print("|cFFFF7D0AWoW Spell Yeller|r : "..command.." "..addonstatus..".")
	end
end
SlashCmdList["SPELLYELLER"] = handler;
-------------------------------------------------------
local function CheckDeath( tdestName, tsourceGUID, tdestGUID )
	if strsub(tdestGUID,1,2)  ~= "Pl" or not UnitInParty(tdestName) then return false end
	if strsub(tsourceGUID,1,2) == "Pl" and tsourceGUID ~= tdestGUID then return false end
	return true
end
local function IsPartyMember( thisname, thisguid )
	return UnitInParty(thisname) and strsub(thisguid,1,2) == "Pl"
end
-------------------------------------------------------
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

	if (event == "COMBAT_LOG_EVENT_UNFILTERED" and switches["yell"]==1 ) then
		timestamp, type, hideCaster,sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
		channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "Raid" or IsInGroup() and "Party"
		alertchannel = ( UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and "RAID_WARNING" or "Raid"

		if (type == "SPELL_STOLEN") then --法術竊取
			spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool = select(12, ...)
			spellLink = GetSpellLink(spellId)
			extraSpellLink = GetSpellLink(extraSpellId)
			if(sourceGUID == playerGUID) then
				SendChatMessage(spellLink.." => "..destName.."'s "..extraSpellLink, personalchannel)
			elseif (destGUID == playerGUID) then
				SendChatMessage(extraSpellLink.." <= ".. sourceName.."'s "..spellLink, personalchannel)
			end
		end
 
		if (type == "SPELL_DISPEL") then  --驅散
			 spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool = select(12, ...)
			spellLink = GetSpellLink(spellId)
			extraSpellLink = GetSpellLink(extraSpellId)
			if(sourceGUID == playerGUID) then 
				SendChatMessage(spellLink.." => "..destName.."'s "..extraSpellLink, personalchannel)
			elseif (destGUID == playerGUID) then
				SendChatMessage(extraSpellLink.." <= ".. sourceName.."'s "..spellLink, personalchannel)
			end
		end

		if (type == "SPELL_INTERRUPT") then  --打斷
			spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool = select(12, ...)
			spellLink = GetSpellLink(spellId)
			extraSpellLink = GetSpellLink(extraSpellId)
			if(sourceGUID == playerGUID) then
				SendChatMessage(spellLink.." => "..destName.."'s "..extraSpellLink, personalchannel)
			 elseif (destGUID == playerGUID) then
				SendChatMessage(extraSpellLink.." <= ".. sourceName.."'s "..spellLink, personalchannel)
			end
		end

		--死亡通報    
		if(switches["death"] == 1 and ( (InEncounter == 1 and deathcount < Maxdeathnumber) or InEncounter ~= 1)) then
			if ( type == "SPELL_DAMAGE"  or type == "SPELL_PERIODIC_DAMAGE" or type == "RANGE_DAMAGE")  then
				spellId, spellName, spellSchool, amount,overkill = select(12, ...)
				if CheckDeath(destName, sourceGUID, destGUID) then
					if overkill >= 0 then
						--print(time().." "..destName.." "..GetSpellLink(spellId))
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
				if overkill >= 0 and CheckDeath(destName, sourceGUID, destGUID) then
					--print(time().." "..type.." "..destName)
					deathvector[destName]={["type"] = "SWING"}
					deathvector[destName]["amount"] = amount
					deathvector[destName]["source"] = sourceName
					deathvector[destName]["tstamp"] = time()
				end
			elseif(type == "SPELL_INSTAKILL" ) then
				if CheckDeath(destName, sourceGUID, destGUID) then
					print(destName.." killed by "..sourceName..GetSpellLink(spellId))
					deathvector[destName]={["type"] = "INSTAKILL"}
					deathvector[destName]["id"] = spellId
					deathvector[destName]["tstamp"] = time()
					if  IsPartyMember(destName,destGUID) and select(3,UnitClass(destName)) == 6 then 
						deathvector[destName]["id"] = 114556  -- DK 煉獄
					end
				end
			elseif( type == "ENVIRONMENTAL_DAMAGE" ) then
				envirtype, amount = select(12, ...)
				--[[if UnitInParty(destName) and strsub(destGUID,1,2)=="Pl" then
					print(type.." "..envirtype.." "..amount.." "..UnitHealth(destName))
				end]]
				if UnitHealth(destName) <= 1 and IsPartyMember(destName, destGUID) then
					localizedenvirtype = EnvironmentalType[envirtype] or envirtype
					SendChatMessage(destName.." died of "..localizedenvirtype.."("..amount.."環境傷害)!",channel)
					deathcount = InEncounter == 1 and deathcount + 1
				end
			elseif type == "UNIT_DIED" or type == "SPELL_AURA_APPLIED" then
				local deadname = select(9, ...)
				local deadguid = select(8, ...)
				local dead
				if type == "UNIT_DIED"and IsPartyMember(deadname, deadguid) then 
					dead = deathvector[deadname] 
					--print(time().." "..type.." "..deadname)
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
 								SendChatMessage(deadname.." died of "..spellLink.."("..tt.damage..spellschoolname..")!",channel)
							else 
								SendChatMessage(deadname.." died, turned into "..GetSpellLink(spellId).."!",channel)
							end 
							deathcount = InEncounter == 1 and deathcount + 1
						end
					end
				end
				if  dead and time()-dead.tstamp <= dinterval and dead.type == "SPELL" then
					spellLink = GetSpellLink(dead.id)
 					spellschoolname = SpellSchoolCode[dead.school] or "其他"
					SendChatMessage(deadname.." died of "..spellLink.."("..dead.amount..spellschoolname..")!",channel)
					deathcount = InEncounter == 1 and deathcount + 1
				elseif dead and time()-dead.tstamp <= dinterval and dead.type == "SWING" then
					SendChatMessage(deadname.." died of "..dead.source.."的近戰攻擊:"..dead.amount..")!",channel)
					deathcount = InEncounter == 1 and deathcount + 1
				elseif dead and time()-dead.tstamp <= dinterval and dead.type == "INSTAKILL" then
					spellLink = GetSpellLink(dead.id)
					SendChatMessage(deadname.." died of "..spellLink.."(立即死亡)!", channel)
					deathcount = InEncounter == 1 and deathcount + 1
				end
			end
		end

		--技能警報
		if( switches["alert"] == 1) then
			--Buff or Debuff
			if (type == "SPELL_AURA_APPLIED" or type == "SPELL_AURA_REFRESH" ) then 
				spellId, spellName, spellSchool = select(12, ...)
				if ( UnitInParty(destName) and AuraList[spellId] ) then
					spellLink = GetSpellLink(spellId)
					SendChatMessage( "[技能警報]: "..spellLink.." => "..destName, alertchannel )
					SendChatMessage( spellLink.." -> "..destName, "yell" )
				end
			end
			--開始施法
			if ( type == "SPELL_CAST_START"  and alertswitch == 1) then
				spellId, spellName, spellSchool = select(12, ...)
				if ( DeadlyspellStart[spellId]  ) then
					spellLink = GetSpellLink(spellId)
					--SendChatMessage(">"..sourceName.."<使用了"..spellLink.."，快躲開！",alertchannel)
					print( type.." : "..spellLink.." -> "..destName)
				end
			end
			--施法成功、開始引導
			if ( type == "SPELL_CAST_SUCCESS"  ) then
				spellId, spellName, spellSchool = select(12, ...)
				if ( DeadlyspellSucc[spellId]  ) then
					spellLink = GetSpellLink(spellId)
					--SendChatMessage(">"..sourceName.."<使用了"..spellLink.."，快躲開！",alertchannel)
					print( type.." : "..spellLink.." -> "..destName)
				end
			end
		end 
		
		-- 隊友誤傷
		if switches["falsedmg"]==1 and (type == "SPELL_DAMAGE" or type == "SPELL_PERIODIC_DAMAGE" or type == "RANGE_DAMAGE")  then
			if IsPartyMember(sourceName, sourceGUID) and IsPartyMember(destName, destGUID) and sourceName ~= destName  then
				if not FalseDamage[ sourceName ] then
					FalseDamage [ sourceName ] = amount
				else
					FalseDamage [ sourceName ] = FalseDamage [ sourceName ] + amount
				end
			end
		end

		--各種雜項
		if( UnitInParty(sourceName) and type == "SPELL_CAST_SUCCESS") then
			spellId, spellName, spellSchool = select(12, ...)
			spellLink = GetSpellLink(spellId)
			if ( RaidFunctions[spellId] ) then
				SendChatMessage(sourceName.." used "..spellLink..".", channel)
			elseif ( FeastSpell[spellId] ) then
				SendChatMessage(sourceName.." placed "..spellLink..".", channel)	
			elseif (switches["raidcd"] == 1 ) then -- Raid Cooldown
				if (ImportantAbility[spellId]) then -- 團隊大技能、減傷
					local holyp = true
					if spellName == "神圣赞美诗" then
						holyp = (not PriestSpell[sourceName]) or (time()-PriestSpell[sourceName] >20)
						PriestSpell[sourceName] = time()
					end
					if( holyp ) then
						if( starttimestamp and InEncounter == 1 ) then
							RaidCDNumber = RaidCDNumber + 1
							RaidCDList[RaidCDNumber] = {id = spellId, times = time() - starttimestamp, source = sourceName }
						end
						SendChatMessage(spellLink.." cast by "..sourceName.." !", alertchannel)
					end
				--[[單目標減傷
				if (PersonalAbility[spellId]) then 
				SendChatMessage(sourceName..spellLink.." => "..destName.." !", channel)]]
				end
			end 
		end
	end 
end)


--PlaySoundFile("Sound\\Spells\\PVPFlagTaken.ogg")