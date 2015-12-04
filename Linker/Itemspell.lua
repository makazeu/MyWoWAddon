-- WoW UI Lua 
-- Show item's spell on the tooltip
-- Author: Makazeu
local script = GameTooltip:GetScript("OnTooltipSetUnit") 
local function HookedOnTooltipSetItem( frame, ... )
	if script and type(script) == "function" then
		script(frame, ...)
	end
	local itemid, itemlink = GameTooltip:GetItem()
	if itemlink then
		local itemspell = GetItemSpell(select(2,GetItemInfo(itemlink)))
		if itemspell then
			frame:AddLine("|cFFFF80FF效果:"..itemspell.."|r", 1, 1, 1, true)
			--print("|cFFFF80FF效果:"..itemspell.."|r")
		end
	end
end
GameTooltip:SetScript("OnTooltipSetItem", HookedOnTooltipSetItem)