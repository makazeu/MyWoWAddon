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
		end	
	end
end

local function DraenorWeekly( ... )
	print("=======德拉諾週常=======")
	local draenorweek = {
	Rukhmar  = { id=37474,name="魯克瑪(阿蘭卡峯)"},
	Tarlna = {id=37462,name="戈爾隆德兩隻首領"},
	}
	for k,v in pairs(draenorweek) do
		if IsQuestFlaggedCompleted(v["id"]) == false then
			print(v["name"].." |cffff0000未完成|r！")
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
	print("quest ID: 特定任務狀態")
end

SLASH_HIBCOM1 = '/hibcom'
local function handler( msg,editbox )
	local command , rest = msg:match("^(%S*)%s*(.-)$")
	if command == "panda" then 
		PandariaWeekly()
	elseif command == "dw" then
		DraenorWeekly()
	elseif command == "quest" and rest ~= "" then
		GetQuest(tonumber(rest))
	else 
		Help()	
	end
end
SlashCmdList['HIBCOM'] = handler
