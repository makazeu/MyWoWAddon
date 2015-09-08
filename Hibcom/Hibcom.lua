--Author: Makazeu
local function Display( questID, name )
	if IsQuestFlaggedCompleted(questID) == false then
			print("|cff69ccf0"..name.."|r |cffff0000未完成|r")
		else
			print("|cff69ccf0"..name.."|r |cff00ff00已完成|r")
	end
end 

local function Patch62Rares( ... )
	print("|cFFBF00FF========地狱火之怒========|r")
	--Uninstanced Hellfire Citadel
	Display(40107, "邪能监工玛德拉普(HFC)")
	--The Dark Portal
	Display(40104, "萨姆逊·强掠(TDP)")
	Display(40105, "达库姆(TDP)")
	Display(40106, "贡达(TDP)")
	--Uninstanced Highmaul
	Display(40073, "普格(Highmaul)")
	Display(40074, "甘克(Highmaul)")
	Display(40075, "鲁克都格(Highmaul)")
	--Champions of Hellfire Citadel
	Display(39287, "死爪(Hellbane)")
	Display(39288, "泰罗菲斯特(Hellbane)")
	Display(39289, "末日之轮(Hellbane)")
	Display(39290, "维金斯(Hellbane)")
end

local function PandariaWeekly( ... )
	print("=======潘达利亚週常=======")
	local panwk = {
	Sha = { id=32099,name="怒之煞(昆莱山)"},
	Galleon= {id=32098,name="炮舰(四风谷)"},
	Nalak= {id=32518,name="纳拉克(雷神岛)"},
	Oondasta = {id=32519,name="乌达斯塔(巨兽岛)"},
	Celestrials = {id=33117,name="至尊天神(永恒岛)"},
	Ordos = {id=33118,name="斡耳朵斯(永恒岛)"},
	}
	for k,v in pairs(panwk) do
		if IsQuestFlaggedCompleted(v["id"]) == false then
			print(v["name"].." |cffff0000未完成|r！")
		else
			print(v["name"].."|cff00ff00已完成|r！")
		end	
	end
end

local function DraenorWeekly( ... )
	print("=======德拉諾週常=======")
	local draenorweek = {
	Rukhmar  = { id=37464,name="魯克瑪(阿蘭卡峯)"},
	Tarlna = {id=37462,name="戈爾隆德首領"},
	GoldInvasion = { id = 37640, name = "黃金要塞入侵" },
	PInvasion = { id = 38482, name = "白金要塞入侵" },
	}
	for k,v in pairs(draenorweek) do
		if IsQuestFlaggedCompleted(v["id"]) == false then
			print(v["name"].." |cffff0000未完成|r！")
		else
			 print(v["name"].."|cff00ff00已完成|r！")
		end	
	end
end

local function GetQuest( QuestID )
	if IsQuestFlaggedCompleted(QuestID) == false then
		print("Quest "..QuestID.." : 未完成或不存在！")
	else
		print("Quest "..QuestID.." : 已完成！")
	end
end

local function Help( ... )
	print("|cff00ff00Hibcom|r v1.0 by Makazeu");
	print("用法：/hibcom xxx")
	print("panda: 潘達利亞週常")
	print("dw:德拉諾週常")
	print("q ID: 特定任務狀態")
end

SLASH_HIBCOM1 = '/hibcom'
local function handler( msg,editbox )
	local command , rest = msg:match("^(%S*)%s*(.-)$")
	if command == "panda" then 
		PandariaWeekly()
	elseif command == "dw" then
		DraenorWeekly()
	elseif command == "62" then
		Patch62Rares()
	elseif command == "q" and rest ~= "" then
		GetQuest(tonumber(rest))
	else 
		Help()	
	end
end
SlashCmdList['HIBCOM'] = handler
