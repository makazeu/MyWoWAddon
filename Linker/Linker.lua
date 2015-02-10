--WoW In-game Item Linker
--Makazeu@gmail.com
--Verison: 2.1.1
function LinkItem(ItemID) 
	local iName, iLink, iRarity, iLevel, iMinLevel, iType, iSubType, iStackCount = GetItemInfo(ItemID);
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
	if not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and not IsInRaid() then return end;
	local RaidMembertoCheck = membernum and membernum or GetNumGroupMembers();
	local NoFlask = 0;
	local NoFood = 0;
	local ResultFlask = "無合劑: ", tempResultFlask; 
	local ResultFood = "無食物: ", tempResultFood;
	local MaxCharacterLength = 250;
	for i = 1,RaidMembertoCheck do 
		for j = 1, 41 do 
			UnitBuffName = UnitBuff("raid"..i,j);
			if (UnitBuffName) then
				if( string.find(UnitBuffName, "合剂") or UnitBuffName == "疯狂耳语" ) then
					break;
				end
			elseif( j == 41 ) then
				tempResultFlask = ResultFlask..UnitName("raid"..i)..".";
				NoFlask = NoFlask +1;
				if (string.len(tempResultFlask) > MaxCharacterLength)  then
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
				if( UnitBuffName == "进食充分" ) then
					break;
				end
			elseif( j == 41 ) then
				tempResultFood = ResultFood..UnitName("raid"..i)..".";
				NoFood = NoFood +1;
				if (string.len(tempResultFood) > MaxCharacterLength)  then
					SendChatMessage(ResultFood,"raid");
					ResultFlask = "無食物: "..UnitName("raid"..i)..".";
				else
					ResultFood = tempResultFood;
				end
			end
		end
	end
	if (NoFlask == 0) then
		SendChatMessage("合劑檢查：全員皆有合劑！","raid");
	else
		SendChatMessage(ResultFlask.."("..NoFlask.."人)","raid");
	end
	if (NoFood==0) then
		SendChatMessage("食物檢查：全員皆有進食！","raid");
	else
		SendChatMessage(ResultFood.."("..NoFood.."人)","raid");
	end
end

local function Help()
	print("|cffffd200Linker|r v1.1 by |cFFBF00FFMakazeu|r");
	print("語法: 鏈接物品|法術/lk (i|s) id，獲取NPC id：/lk n");
	print("/lk rc (num): Raid Check for Flask and Food.");
	print("/lk gaes: Get Arena Enemies' Specializations.");
end

SLASH_LINKER1, SLASH_LINKER2 = '/linker','/lk';
local function handler(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$");
	if command == "i" and rest ~= "" then
		LinkItem(tonumber(rest));
	elseif command == "s" and rest ~= "" then
		LinkSpell(tonumber(rest));
	elseif command =="n" and rest == "" then
		GetNPC();
	elseif command == "gaes" and rest =="" then
		GetArenaEnemySpec();
	elseif command == "rc" then
		if rest == "" then
			RaidCheck();
		else 
			RaidCheck(tonumber(rest));
		end
	else
		Help();
	end
end
SlashCmdList["LINKER"] = handler;