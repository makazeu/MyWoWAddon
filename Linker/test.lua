
nf="[Flask!]: ";
for i=1,GetNumRaidMembers()do 
	for b=1,41 
		do ufl=UnitAura('raid'..i,b);
		if ufl then 
			if strfind(ufl,"Flask")then 
				break;
			end;
		elseif b==41 then 
			nf=nf..UnitName('raid'..i).." ";
		end;
	end;
end;
SendChatMessage(nf,"raid");

nfb="[Eat!]: ";
for i=1,GetNumRaidMembers()do 
	for b=1,40 do 
		ua=UnitAura('raid'..i,b);
		if ua=="Well Fed"or ua=="Food"then 
			break;
		elseif b==40 and ua~="Well Fed"then 
			nfb=nfb..UnitName('raid'..i).." ";
		end;
	end;
end;
SendChatMessage(nfb,"raid");


    --[[if( UnitInParty(destName) and type == "SPELL_DAMAGE" ) then --死亡通報
      local spellId, spellName, spellSchool, amount,
      overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, ...)
      local spellLink = GetSpellLink(spellId)
      if(overkill >= 0) then
        --SendChatMessage(">>"..destName.."<<死翹翹咯，死因："..spellLink.."！","raid")
      end
    end]]