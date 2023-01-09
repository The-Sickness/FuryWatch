-- FuryWatch
-- Made by Sharpedge_Gaming
-- v0.1	 - 10.0.2

if select(2, UnitClass("player")) ~= "DEMONHUNTER" then
    return
end


local _,FuryWatch=...
local Frame=CreateFrame("ScrollingMessageFrame","FuryWatch",UIParent)	
Frame.Threshold=95
Frame.Warned=false
-- Initialize
function FuryWatch:Initialize()	
	Frame:SetWidth(450)
	Frame:SetHeight(200)
	Frame:SetPoint("CENTER",UIParent,"CENTER",0,0)	
	Frame:SetFont("Interface\\AddOns\\FuryWatch\\Res\\RESEGRG_.TTF",30,"THICKOUTLINE")
	Frame:SetShadowColor(0.00,0.00,0.00,0.75)
	Frame:SetShadowOffset(3.00,-3.00)
	Frame:SetJustifyH("CENTER")		
	Frame:SetMaxLines(2)
	--Frame:SetInsertMode("BOTTOM")
	Frame:SetTimeVisible(1)
	Frame:SetFadeDuration(1)		
	FuryWatch:Update()
end
-- Update Fury warning
function FuryWatch:Update()	
	if(floor((UnitPower("player", 17)/UnitPowerMax("player", 17))*100)>=Frame.Threshold and Frame.Warned==false)then
		PlaySoundFile("Interface\\AddOns\\FuryWatch\\Res\\Fury_max.ogg")	
		Frame:AddMessage("Maximum Fury", 1, 0.3, 0, nil, 3)
		Frame.Warned=true
		return
	end
	if(floor((UnitPower("player", 17)/UnitPowerMax("player", 17))*100)<Frame.Threshold)then
		Frame.Warned=false
		return
	end	
end
-- Handle events
function FuryWatch:OnEvent(Event,Arg1,...)
	if(Event=="PLAYER_LOGIN")then
		FuryWatch:Initialize()
		return
	end	
	if(Event=="UNIT_POWER_UPDATE" and Arg1=="player")then
		FuryWatch:Update()
		return
	end	
end
Frame:SetScript("OnEvent",FuryWatch.OnEvent)
Frame:RegisterEvent("PLAYER_LOGIN")
Frame:RegisterEvent("UNIT_POWER_UPDATE")