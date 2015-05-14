local iname, sname
SLASH_EXPORTOR1, SLASH_EXPORTOR2 = '/exportor','/exp'
local function handler(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if command == "item" then
		rest = rest and tonumber(rest) or 120000
		Wowdb = { ["item"] = { } }
		for i=rest,130000 do
			iname = GetItemInfo(i)
			if iname then
				Wowdb["item"][i] = iname
			end
			if i % 1000 == 0 then
				print(i)
			end 
		end
	elseif command == "spell" then
		rest = rest and tonumber(rest) or 170000
		Wowdb = { ["spell"]={ } }
		for i=rest,200000 do
			sname = GetSpellInfo(i)
			if sname then
				Wowdb["spell"][i] = sname
			end
			if i % 5000 == 0 then
				print(i)
			end
		end
	end
end
SlashCmdList["EXPORTOR"] = handler;