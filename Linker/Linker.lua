--WoW In-game Item Linker
--Makazeu@gmail.com
--Verison: 2.2.0

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
function LinkItem(ItemID) 
	local iName, iLink = GetItemInfo(ItemID);
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
	print("|cffffd200Linker|r v1.1 by |cFFBF00FFMakazeu|r");
	print("語法: 鏈接物品|法術/lk (i|s) id，獲取NPC id：/lk n");
	print("/lk rc (num): Raid Check for Flask and Food.");
	print("/lk gaes: Get Arena Enemies' Specializations.");
end

SLASH_LINKER1, SLASH_LINKER2 = '/linker','/lk'
local function handler(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if command == "i" and rest ~= "" then
		LinkItem(tonumber(rest))
	elseif command == "s" and rest ~= "" then
		LinkSpell(tonumber(rest))
	elseif command =="n" and rest == "" then
		GetNPC()
	elseif command == "gaes" and rest =="" then
		GetArenaEnemySpec()
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
	else
		Help()
	end
end
SlashCmdList["LINKER"] = handler;