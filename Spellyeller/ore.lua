orehelper = 1
orenumber = 5
local oreid = 156877
local rollid = 155819
local oreorder = 0 
local noirtime = 0
local timestamp, type, hideCaster,sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags
local channel, alertchannel
local spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(self, event, ...)
	if(event == "ENCOUNTER_START") then
		oreorder = 0
		noirtime = 0
		if GetRaidDifficultyID() == 16 then
			orenumber = 5
		else
			orenumber = 3
		end
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and orehelper == 1 then
		timestamp, type, hideCaster,sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
		channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "Raid" or IsInGroup() and "Party"
		alertchannel = ( UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and "RAID_WARNING" or "Raid"
		if type == "SPELL_AURA_APPLIED" then
			spellId, spellName, spellSchool = select(12, ...)
			if GetSpellInfo(spellId) == GetSpellInfo(rollid) then
				oreorder = 0
				print( "Rolling Fury starts!" )
			end
		end
		if type == "SPELL_CAST_START"  then
			spellId, spellName, spellSchool = select(12, ...)
			if GetSpellInfo(spellId) == GetSpellInfo(oreid) then
				oreorder = oreorder +1
				print( GetSpellLink(spellId).." "..oreorder)
			end
		end
		if type == "SPELL_INTERRUPT" then
			spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool = select(12, ...)
			if GetSpellInfo(extraSpellId) == GetSpellInfo(oreid) then
				spellLink = GetSpellLink(spellId)
				extraSpellLink = GetSpellLink(extraSpellId)
				SendChatMessage("【".. ( oreorder - 1 ) % orenumber + 1 .."断】成功！ "..extraSpellLink.." <= "..sourceName..spellLink,channel)
			end
		end
		if  type == "SPELL_CAST_SUCCESS"  then
			spellId, spellName, spellSchool = select(12, ...)
			if GetSpellInfo(spellId) == GetSpellInfo(oreid) and time()-noirtime >2 then
				noirtime = time()
				spellLink = GetSpellLink(spellId)
				SendChatMessage("【".. ( oreorder - 1 ) % orenumber + 1 .."断】失败！ "..spellLink.."没人打断！",channel)
			end
		end
	end
end)