--[[
WoW Addon
Name: Annomilter
Description: Annoying Message Filter
Version: 20151217
Author: Makazeu
]]
print("|cffff7d0aAnnomilter|r v2.4 已經載入!")
NRAenable = 1
local msglen
local myvalue
local star = "**"
local filtertime = 0
local kaetime
local lastfilmess
local lastfiltime
local Raidwords = {
	["EUI:"] = true,
	["任务进度提示"] = true,
	["(任务完成)"] = true,
	["大脚...队提示"] = true,
	["<没有目标>"] = true,
}
local Namewords = {
	["淘寶"]  = true,
	["淘寳"] = true,
	["淘宝"]  = true,
	["陶宝"] = true,
	["掏宝"] = true,
	["大锤"] = true,
	["小羊"] = true,
	["皇冠"] = true,
	["网代"] = true,
	["門票"] = true,
}
local BannedName = { }
local Strreplace = {
	["%s"] = "",
	["丨"] = "",
	["│"] = "",
	["{rt%d}"] = "",
	["{...}"] = "",
	["{......}"] = "",
	["{.........}"] = "",
	["‖"] = "",
	["~"] = "",
	["%."]="",
	["·"] ="",
	["丶"] = "",
	["＼"]="",
	["`"] = "",
}

local WordValue = {
	["低价处理"] = 40,
	["打工已经就位"] = 60,
	["大卡"] = 20,
	["小卡"] = 20,
	["出%d%dWG"] = 30,
	["%d%dWG"] = 60,
	["十万G"] = 80,
	["打包"] = 40,
	["%dw=%d"] = 60,
	["%d元"] = 40,
	[".块钱"] = 60,
	["%d0000g"] = 40,
	["H...只%d"] = 100,
	["货到付款"] = 50,
	["诚心要的"] = 50,
	["急甩"] = 40,
	["%d/位"] = 80,
	["%d一位"] = 80,
	["需%d元"] = 40,
	["=%d元"] = 50,
	["%dW=%d%d元"] = 100,
	["%d-100="] = 40,
	["%d-100级="] = 80,
	["全通"] = 50,
	["打手"] = 50,
	["老板"]  = 50,
	["彳正"] = 100,
	["代练"] = 80,
	["包毕业"] = 90,
	["记者"] = 40,
	["包团"] = 70,
	["抱团"] = 50,
	["优惠"] = 40,
	["散拍"] = 90,
	["散卖"] = 80,
	["%d%d0000"] = 40,
	["1%d%d两天完"] = 80, 
	["完单"] = 60,
	["下单秒"] = 90,
	["价格最"] = 40,
	[".天完成"] = 50,
	["=%d小时"] = 40,
	["...G的朋友"] = 100,
	["躺尸"] = 60,
	["躺着赢"] = 60,
	["躺赢"] = 60,
	["包过"] = 40,
	["包過"] = 60,
	["包赢"] = 50,
	["保赢"] = 50,
	["随便来"] = 20, 
	["跟打"] = 60,
	["消费"] = 40,
	["打工"] = 40,
	["支持老"] = 80,
	["自己上号"] = 80,
	["门票"] = 80,
	["門票"] = 100,
	["雪人"] = 40,
	["换化"] = 40,
	["樰人"] = 100,
	["化武器"] = 40,
	["帮您做"] = 50,
	["帮你打"] = 50,
	["大神带"] = 70,
	["大神戴"] = 70,
	["%d分钟一波"] = 80,
	["手工"] = 80,
	["手工G"] = 90,
	["店铺"] = 90,
	["TB"] = 50,
	["淘宝"]=100,
	["綯宝"]=100,
	["幣"]=50,
	["皇冠"]=50,
	["淘寶"] =100,
	["陶宝"] = 100,
	["X宝"] = 50,
	["宝搜"] = 80,
	["寶"] = 30,
	["寳"] = 30,
	["淘%s宝"] = 100,
	["ZFB"] = 70,
	["支付宝"] = 100,
	["比例1."] = 50,
	["...万G"] = 70,
	["需要请加"] = 80,
	["%d萬"] = 90,
	["MMMMM"] = 20,  
	["黒"] = 100,
	["H嘿"] = 100,
	["%d筷"] = 100,
	["原祖角斗士"] = 30,
	["引领潮流"] = 40,
	["千钧一发"] = 40,
	["接全职业"] = 100,
	["踏血小戈隆"] = 40,
	["灵爪飞鹰"] = 40,
	["特惠%d"] = 100,
	["德拉诺团队的荣耀"] = 40,
	["挑战德拉诺"] = 60,
	["%d点征服点数"] = 40,
	["混...服点"] = 60,
	["随便来个秒开"] = 60,
	["[100级]"] = 20,
	["骗子"] = -80,
	["诈骗"] = -80,
	["大{圆形}"] = 50,
	["小{圆形}"] = 50,
	["①"] = 50,
	["⑥"] = 60,
	["④"] = 50,
	["②"] = 50,
	["⒌"] = 50,
	["⑤"] = 50,
	["㈤"] = 50,
	["⒐"] = 50,
	["⑼"] = 50,
	["⑨"] = 50,
	["上丫"] = 60,
	["丫丫"] = 60,
	["还有%d坑"] = 20,
	["跨服......G团"] = 30,
	["视频...聊"] = 100,
	["吖吖"] = 100,
	["《6.》"] = 100,
	["%d人民币"] = 100,
	["☆"] = 50,
	["○"] = 50,
	["◆"] = 50,
	["★"] = 50,
	["卖点g"] = 80,
	["卖点G"] = 80,
}

local function MessageCounter(thismess,thisauthor,filstyle)
	if lastfilmess and lastfilmess == thismess and time()-lastfiltime <= 1 then
		return
	end
	if filstyle ~= "Underline" then
		BannedName[thisauthor] = true
	end
	filtertime = filtertime + 1
	lastfiltime = time()
	lastfilmess = thismess
	if filtertime % 100 == 0 then
		print("|cff69ccf0本次載入後,|r |cffff7d0aAnnomilter|r|cff69ccf0已爲您過濾了|r|cffff7d0a"..filtertime.."|r|cff69ccf0條垃圾信息!|r")
	end
	if not Gomirec then Gomirec = {} end
	if not Gomirec[thisauthor] then Gomirec[thisauthor] = {} end
	thismess = thismess.." Reason:"..filstyle
	Gomirec[thisauthor][thismess] = Gomirec[thisauthor][thismess] and Gomirec[thisauthor][thismess] + 1 or 1
end

local function MessageFilter( NFself, NFevent, NFmsg, NFauthor, ... )
	if NRAenable == 0 then
		return false
	end
	NFauthor = strfind(NFauthor,"-") and strsub(NFauthor, 1, strfind(NFauthor,"-")-1) or  NFauthor
	--Filter by Name--
	if BannedName[NFauthor] then
		MessageCounter(NFmsg, NFauthor, "BannedName")
			return true
	end
	for k,v in pairs(Namewords) do
		if strfind(NFauthor, k) then
			MessageCounter(NFmsg, NFauthor, "Namewords")
			return true
		end
	end
	--Delete given characters
	kaetime = 0
	for k,v in pairs(Strreplace) do
		NFmsg, kaetimenow = string.gsub(NFmsg, k, v)
		if strsub(k,1,1) == "{" then
			kaetime = kaetime + kaetimenow
		end
	end

	if NFmsg=="_" or NFmsg =="-" then
		MessageCounter(NFmsg, NFauthor, "Underline")
		return true
	end
	--Filter by  keywords
	myvalue = kaetime * 20
	for k,v in pairs(WordValue) do
		if strfind(NFmsg,k) then
			myvalue = myvalue + v
			if myvalue >= 100 then
				MessageCounter(NFmsg, NFauthor, "Keywords")
				Gomirec[NFauthor][NFmsg.." Reason:Keywords"] = myvalue
				return true
			end
		end
	end
	return false
end


local function IsRaidAlerter( NRAself, NRAevent, NRAmsg, NRAauthor, ... )
	if NRAenable == 0 then
		return false
	end
	msglen = string.len(NRAmsg)
	if string.sub(NRAmsg,1,2) == star and string.sub(NRAmsg,msglen-1,msglen) == star then
		return true
	end
	for k,v in pairs(Raidwords) do
		if strfind(NRAmsg, k) then
			return true
		end
	end
	return false
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", MessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", MessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", MessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", MessageFilter)

SLASH_ANNOMILTER1, SLASH_ANNOMILTER2 = "/annomilter", "/anm"
local function handler( msg, editbox )
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if command == "on" then
		print("|cffff7d0aAnnomilter|r 已經開啓!")
		NRAenable = 1
	elseif command == "off" then
		print("|cffff7d0aAnnomilter|r 已經關閉!")
		NRAenable = 0
	elseif command == "ban" then
		local bannednum = 0
		print("本次載入後已被攔截的玩家：")
		for k,v in pairs(BannedName) do
			print("|cff69ccf0"..k.."|r")
			bannednum = bannednum + 1
		end
		print("顯示完畢, 共計|cff69ccf0"..bannednum.."|r人。")
	elseif command == "num" then
		print("|cff69ccf0本次載入後,|r |cffff7d0aAnnomilter|r|cff69ccf0已爲您過濾了|r|cffff7d0a"..filtertime.."|r|cff69ccf0條垃圾信息!|r")
	else 
		print("|cffff7d0a請輸入正確的命令!|r")
		print("|cff69ccf0Annomilter|r by |cffff7d0aMakazeu|r")
	end
end
SlashCmdList["ANNOMILTER"] = handler