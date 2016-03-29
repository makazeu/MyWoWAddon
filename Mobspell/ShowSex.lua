local linestr
local script = GameTooltip:GetScript("OnTooltipSetUnit")
local function HookedOnTooltipSetUnit( frame, ... )
	if script and type(script) == "function" then
		script(frame, ...)
	end
	local unitid = select(2,GameTooltip:GetUnit())
	if unitid then
		local guid = UnitGUID(unitid)
		local type, _, _, _, _, npcid, _ = strsplit("-",guid)
		if type ~= "Player" then return end
		local class, _, race, _, sex, _, _ = GetPlayerInfoByGUID(guid)
		
		local flag = true
		for i=1,12 do
			local Arace, Alevel, Aflag = GetAchievementCriteriaInfo(2422,i)
			if Arace == race then
				flag = Aflag
				break
			end
		end
		
		linestr = "Sex: " .. (sex == 3 and "Female" or "Male")
		if not flag and sex == 3 then
			linestr = linestr .. " |cFFFF8000未完成!|r"
		end
		
		frame:AddLine(linestr, 1, 1, 1, true)
	end
end
GameTooltip:SetScript("OnTooltipSetUnit", HookedOnTooltipSetUnit)