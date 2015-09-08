--WoW In-game Item Linker
--Makazeu@gmail.com
--Verison: 2.6.0

local RareName = {
	["现世边界"] = true,
	["神秘的骆驼雕像"] = true,
}

local Edge = CreateFrame("frame",nil, UIParent);
Edge:SetScript("OnUpdate", function() 
	if RareName[GameTooltipTextLeft1:GetText()]  then 
		print("|cFFBF00FFRare Found : "..GameTooltipTextLeft1:GetText().."!|r")
		PlaySoundKitID(11466, "master", true); 
	end 
end)

local MaxCharacterLength = 250

local function Myprint( str, flag )
	flag = flag and flag or 0
	if flag == 0 then
		print(str)
	elseif flag == 1 then 
		SendChatMessage( str , "raid")
	elseif flag == 2 then
		SendChatMessage(str, "party")
	end
end

local function LinkItem(ItemID) 
	local iName, iLink = GetItemInfo(ItemID)
	if not iLink then
		print("Item "..ItemID..": 未緩存或不存在！");
	else
		print("Item "..ItemID..": "..iLink);
	end
end

local function LinkSpell(SpellID)
	local sInfo = GetSpellInfo(SpellID)
	if not sInfo then
		print("Spell "..SpellID..": 該法術不存在！");
	else
		print("Spell "..SpellID.." : \124cffffd000\124Hspell:"..SpellID.."\124h["..sInfo.."]\124h\124r");
	end
end

local function PutEditBox( str )
	local editbox = _G.ChatEdit_ChooseBoxForSend() 
	_G.ChatEdit_ActivateChat(editbox)
	
	editbox:SetText(str)
	editbox:HighlightText()
		
	editBox = CreateFrame("EditBox","CopyChatFrameEditBox",UIParent)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:Width(scrollArea:GetWidth())
	editBox:Height(200)
	editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
end

local function MyEditBox( str )
	local editbox = _G.ChatEdit_ChooseBoxForSend() 
	_G.ChatEdit_ActivateChat(editbox)
	editbox:Insert(str)
	--editbox:HighlightText()
end

function GetItemDescription( )
	local name = GameTooltipTextLeft1:GetText()
	local str = GameTooltipTextLeft2:GetText()
	if not str or not strfind(str,"使用：") then str = GameTooltipTextLeft3:GetText() end
	if not str or not strfind(str,"使用：") then str = GameTooltipTextLeft4:GetText() end
	if not str or not strfind(str,"使用：") then print("找不到该物品的使用效果!") return end
	str = strsub(name,strfind(name,"|t")+3).."  -  "..strsub(str,11)
	print(str)
	MyEditBox(str)
end

local function SpellDescription( SpellID )
	local desc = GetSpellDescription(SpellID)
	local sInfo = GetSpellInfo(SpellID)
	if not sInfo then
		print("Spell "..SpellID..": 該法術不存在！");
	else
		print("Spell "..SpellID.." : \124cffffd000\124Hspell:"..SpellID.."\124h["..sInfo.."]\124h\124r  -  "..desc);
		if desc =="" then desc = "没有描述!" end
		PutEditBox(sInfo.." : "..desc)
	end
end

local function GetNPC()
	local guid , name = UnitGUID("target"), UnitName("target");
	if guid == nil then print("請選擇目標！"); return; end	
	local type, _, _, _, _, npcid, _ = strsplit("-",guid);
	if type ~= "Player" then
		print(name.." : "..npcid.." ("..type..")");
	else 
		print(name.." is just a player.");
	end
end

local function GetPosition( ... )
	SetMapToCurrentZone() 
	local x,y=GetPlayerMapPosition("player")
	str = format("%s, %s: %.1f, %.1f",GetZoneText(),GetSubZoneText(),x*100,y*100)
	print(str)
	PutEditBox(str)
end

local function GetRealm(flag)
	if not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and not IsInRaid() then 
		print("你不在一個團隊中!") return 
	end
	Myprint("各服務器人數：", flag)
	flag = flag and flag or 0
	local PlayerRealm = GetRealmName()
	local Curname, Currealm, Curpos
	local Realms = {}
	local GroupNumber = GetNumGroupMembers()
	for i = 1, GroupNumber  do 
		Curname = GetUnitName("raid"..i, true)
		if Curname ~= "未知目标" then
			Curpos = strfind(Curname, "-")
			Currealm = Curpos and strsub(Curname,Curpos+1) or PlayerRealm
			Realms[Currealm] = Realms[Currealm] and Realms[Currealm] +1 or 1
		end
	end
	local nowstring,nextstring
	local  Currealmnumber 
	local RestNumber = GroupNumber
	for i=1,GroupNumber do
		if RestNumber == 0 then break end
		Currealmnumber = 0
		nowstring = "【"..i.."人】"
		for k,v in pairs(Realms) do
			if i == v then
				Currealmnumber = Currealmnumber + 1
				RestNumber = RestNumber - 1
				nextstring = nowstring..k.."."
				if strlen(nextstring) > MaxCharacterLength then
					Myprint(nowstring, flag)
					nowstring = "【"..i.."人】"..k.."."
				else
					nowstring = nextstring
				end
			end
		end
		if Currealmnumber > 0 then
			Myprint(nowstring, flag)
		end
	end
end

local function GetArenaEnemySpec()
	local MAX_ARENA_ENEMIES = 5;
	for i = 1 , MAX_ARENA_ENEMIES do 
		local specID = GetArenaOpponentSpec(i);
		if (specID and specID > 0) then
			local _, specName, _, _, _, _, specClass = GetSpecializationInfoByID(specID);
			SendChatMessage(i..": "..specClass.." - "..specName, "INSTANCE_CHAT");
		end
	end
end

local function RaidCheck( membernum )
	if not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and not IsInRaid() then 
		print("你不在一個團隊中!") return 
	end
	local RaidMembertoCheck = membernum or GetNumGroupMembers()
	local NoFlask = 0
	local NoFood = 0
	local ResultFlask = "無合劑: ", tempResultFlask
	local ResultFood = "無食物: ", tempResultFood
	for i = 1,RaidMembertoCheck do 
		for j = 1, 41 do 
			UnitBuffName = UnitBuff("raid"..i,j);
			if (UnitBuffName) then
				if strfind(UnitBuffName, "合剂") or UnitBuffName == "疯狂耳语" or 
				strfind(UnitBuffName, "精煉藥劑") or UnitBuffName == "瘋狂呢喃" then
					break;
				end
			elseif( j == 41 ) then
				tempResultFlask = ResultFlask..UnitName("raid"..i)..".";
				NoFlask = NoFlask +1;
				if (strlen(tempResultFlask) > MaxCharacterLength)  then
					SendChatMessage(ResultFlask,"raid");
					ResultFlask = "無合劑: "..UnitName("raid"..i)..".";
				else
					ResultFlask = tempResultFlask;
				end
			end
		end 
		for j = 1, 41 do 
			UnitBuffName = UnitBuff("raid"..i,j);
			if (UnitBuffName) then
				if UnitBuffName == "进食充分" or UnitBuffName == "充分進食" then
					break;
				end
			elseif( j == 41 ) then
				tempResultFood = ResultFood..UnitName("raid"..i)..".";
				NoFood = NoFood +1;
				if (strlen(tempResultFood) > MaxCharacterLength)  then
					SendChatMessage(ResultFood,"raid");
					ResultFlask = "無食物: "..UnitName("raid"..i)..".";
				else
					ResultFood = tempResultFood;
				end
			end
		end
	end
	if (NoFlask == 0) then
		SendChatMessage("合劑檢查：全員皆有合劑！","raid")
	else
		SendChatMessage(ResultFlask.."("..NoFlask.."人)","raid")
	end
	if (NoFood==0) then
		SendChatMessage("食物檢查：全員皆有進食！","raid")
	else
		SendChatMessage(ResultFood.."("..NoFood.."人)","raid")
	end
end

local function LevelCheck( RaidLevel )
	if not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and not IsInRaid() then 
		print("你不在一個團隊中!") return 
	end
	local RaidLeveltoCheck = RaidLevel or 100
	local nonlevelnum = 0
	local nonlevel = "未滿"..RaidLeveltoCheck.."級: "
	local tempnonlevel
	for i = 1,GetNumGroupMembers() do
		if UnitLevel("raid"..i) < RaidLeveltoCheck then
			nonlevelnum = nonlevelnum +1
			tempnonlevel = nonlevel..UnitName("raid"..i).."("..UnitLevel("raid"..i)..") "
			if (strlen(tempnonlevel) > MaxCharacterLength)  then
				SendChatMessage(nonlevelnum,"raid")
				nonlevel = "未滿"..RaidLeveltoCheck.."級: "..UnitName("raid"..i).."("..UnitLevel("raid"..i)..")."
			else
				nonlevel = tempnonlevel
			end
		end 
	end
	if (nonlevelnum == 0) then
		SendChatMessage("等級檢查：全員均已達到"..RaidLeveltoCheck.."級!","raid")
	else
		SendChatMessage(nonlevel.." [共"..nonlevelnum.."人]","raid")
	end
end

local function Help()
	print("|cffffd200Linker|r v2.4 by |cFFBF00FFMakazeu|r");
	print("請輸入正確的指令！");
end

SLASH_LINKER1, SLASH_LINKER2 = '/linker','/lk'
local function handler(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if command == "i" and rest ~= "" then
		LinkItem(tonumber(rest))
	elseif command == "s" and rest ~= "" then
		LinkSpell(tonumber(rest))
	elseif command == "sd" and rest~="" then
		SpellDescription(tonumber(rest))
	elseif command =="n" and rest == "" then
		GetNPC()
	elseif command == "gaes" and rest =="" then
		GetArenaEnemySpec()
	elseif command == "p" then
		GetPosition()
	elseif command == "rc" then
		if rest == "" then
			RaidCheck()
		else 
			RaidCheck(tonumber(rest))
		end
	elseif command == "lc" then
		if rest == "" then 
			LevelCheck()
		else
			LevelCheck(tonumber(rest))
		end
	elseif command == "realm" then
		GetRealm(tonumber(rest))
	else
		Help()
	end
end
SlashCmdList["LINKER"] = handler;