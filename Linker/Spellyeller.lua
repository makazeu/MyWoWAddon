--[[
Script: WoW Spell Yeller
Author : Makazeu
makazeu@gmail.com
Thanks: Gamepedia, Olalala
]]
print("WoW Spell Yeller已經加載！")

local frame = CreateFrame("FRAME");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
frame:SetScript("OnEvent", function(self, event, ...)

  local timestamp, type, hideCaster,
    sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

  --[[
    * Note, for this example, you could just use 'local type = select(2, ...)'.  The others are included
      so that it's clear what's available.
    * You can also lump all of the arguments into one block (or one really long line):

    local timestamp, type, hideCaster,                                                                      -- arg1  to arg3
      sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags,   -- arg4  to arg11
      spellId, spellName, spellSchool,                                                                      -- arg12 to arg14
      amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...             -- arg15 to arg23
  ]]
  local playerGUID = UnitGUID("player")
  local FeastSpell = { 
  ["160914"] = true, --千水魚宴
  ["175215"] = true --狂野大餐
}
  local Portals = {
  ["324"] = true,
  ["176246"] = true, --暴風之盾
  ["176244"] = true, --戰爭之矛
  ["132620"] = true, --錦繡谷
  ["132626"] = true, --錦繡谷
  ["88345"] = true, --托爾巴拉德
  ["88346"] = true, --托爾巴拉德
  ["120146"] = true, --遠古達拉然
  ["53142"] = true, --達拉然
  ["33691"] = true, --沙塔斯
  ["35717"] = true, --沙塔斯
  ["49361"] = true, --斯通納德
  ["11419"] = true, --達納蘇斯
  ["32266"] = true, --埃索達
  ["11416"] = true, --鐵爐堡
  ["11417"] = true, --奧格瑞瑪
  ["32267"] = true, --銀月城
  ["10059"] = true, --暴風城
  ["49360"] = true, --塞拉摩
  ["11420"] = true, --雷霆崖
  ["11418"] = true --幽暗城
}


  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then

    if (type == "SPELL_STOLEN") then --法術竊取
      local spellId, spellName, spellSchool, 
      extraSpellId, extraSpellName, extraSchool, auraType = select(12, ...)
      local spellLink = GetSpellLink(spellId)
      local extraSpellLink = GetSpellLink(extraSpellId)
      if(sourceGUID == playerGUID) then
        SendChatMessage("我的"..spellLink.."偷取了>>"..destName.."<<的"..extraSpellLink.."！","yell")
        elseif (destGUID == playerGUID) then
        SendChatMessage("我的"..extraSpellLink.."被>>"..sourceName.."<<的"..spellLink.."偷走了，艹！","yell")
      end
    end

    if (type == "SPELL_DISPEL") then  --驅散
      local spellId, spellName, spellSchool, 
      extraSpellId, extraSpellName, extraSchool, auraType = select(12, ...)
      local spellLink = GetSpellLink(spellId)
      local extraSpellLink = GetSpellLink(extraSpellId)
      if(sourceGUID == playerGUID) then 
        SendChatMessage("我的"..spellLink.."驅散了>>"..destName.."<<的"..extraSpellLink.."！","yell")
        elseif (destGUID == playerGUID) then
        SendChatMessage("我的"..extraSpellLink.."被>>"..sourceName.."<<的"..spellLink.."驅散了！","yell")
      end
    end

    if (type == "SPELL_INTERRUPT") then  --打斷
      local spellId, spellName, spellSchool, 
      extraSpellId, extraSpellName, extraSchool = select(12, ...)
      local spellLink = GetSpellLink(spellId)
      local extraSpellLink = GetSpellLink(extraSpellId)
      if(sourceGUID == playerGUID) then
        SendChatMessage("我的"..spellLink.."打斷了>>"..destName.."<<的"..extraSpellLink.."！","yell")
       elseif (destGUID == playerGUID) then
        SendChatMessage("我的"..extraSpellLink.."被TM的>>"..sourceName.."<<用"..spellLink.."給打斷掉了！","yell")
      end
    end


    if( UnitInParty(sourceName) and type == "SPELL_CAST_SUCCESS") then --雜項
      local spellId, spellName, spellSchool = select(12, ...)
      local spellLink = GetSpellLink(spellId)
      local spellIdstring = tostring(spellId)

      if(spellId == 698 ) then 
        SendChatMessage(">>"..sourceName.."<<使用了"..spellLink.."，快來拉人啦！","raid")
        elseif (spellId == 29893) then
          SendChatMessage(">>"..sourceName.."<<使用了"..spellLink.."，快來拿屬於自己的糖果啦！","raid")
        elseif (spellId == 67826) then
          SendChatMessage(">>"..sourceName.."<<放置了"..spellLink.."，快來修修自己的裝備啦！","raid")
        elseif (spellId == 43987) then
          SendChatMessage(">>"..sourceName.."<<使用了"..spellLink.."，快來吃面包啦！","raid")
        elseif (FeastSpell[spellIdstring]) then 
          SendChatMessage(">>"..sourceName.."<<放置了"..spellLink.."，快來享用啦！","raid")
        elseif (spellId == 161414 or spellLink == 126459) then
          SendChatMessage(">>"..sourceName.."<<放置了"..spellLink.."，快來拿禮物啦！","raid") 
        elseif (Portals[spellIdstring]) then
          SendChatMessage(">>"..sourceName.."<<放置了"..spellLink.."，要跑路的快走啦！","raid") 
      end
    end

  end 
end);
