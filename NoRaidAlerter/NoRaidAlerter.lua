--[[
WoW Addon
Name: Filterbylevel
Description: RaidAlerter messages filter
Version: 1.0
Author: Makazeu
]]
NRAenable = 1
local msglen
local star = "**"
local questpro = "任务进度提示"
local function IsRaidAlerter( NRAself, NRAevent, NRAmsg, NRAauthor, ... )
	if NRAenable == 0 then
		return false
	end
	msglen = string.len(NRAmsg)
	if string.sub(NRAmsg,1,2) == star and string.sub(NRAmsg,msglen-1,msglen) == star then
		return true
	elseif string.find(NRAmsg,questpro) then
		return true
	else
		return false
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", IsRaidAlerter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", IsRaidAlerter)