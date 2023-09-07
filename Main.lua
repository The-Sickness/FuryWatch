-- FuryWatch 
-- Made by Sharpedge_Gaming
-- v0. - 10.1.7

if select(2, UnitClass("player")) ~= "DEMONHUNTER" then
    return
end

local _, FuryWatch = ...
local AceAddon = LibStub("AceAddon-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
FuryWatch = AceAddon:NewAddon("FuryWatch", "AceConsole-3.0", "AceEvent-3.0")

local Frame = CreateFrame("ScrollingMessageFrame", "FuryWatch", UIParent)
Frame.Threshold = 95
Frame.Warned = false

-- Define sound options
FuryWatch.soundOptions = {
    ["Sound1"] = "Interface\\Addons\\FuryWatch\\Res\\ReadyCheck.mp3",
    ["Sound2"] = "Interface\\Addons\\FuryWatch\\Res\\AxeCrit.mp3",
    ["Sound3"] = "Interface\\Addons\\FuryWatch\\Res\\Parry.mp3",
    ["Sound4"] = "Interface\\Addons\\FuryWatch\\Res\\SealofMight.mp3",
    ["Sound5"] = "Interface\\Addons\\FuryWatch\\Res\\Sheldon.mp3",
    ["Sound6"] = "Interface\\Addons\\FuryWatch\\Res\\Arrow Swoosh.mp3",
    ["Sound7"] = "Interface\\Addons\\FuryWatch\\Res\\Buzzer.mp3",
    ["Sound8"] = "Interface\\Addons\\FuryWatch\\Res\\Gun Cocking.mp3",
    ["Sound9"] = "Interface\\Addons\\FuryWatch\\Res\\Laser.mp3",
    ["Sound10"] = "Interface\\Addons\\FuryWatch\\Res\\Target Acquired.mp3",
    ["Sound11"] = "Interface\\Addons\\FuryWatch\\Res\\NoAlert.mp3",
}

local soundOptionNames = {
    ["Sound1"] = "Ready Check",
    ["Sound2"] = "Axe Crit",
    ["Sound3"] = "Parry",
    ["Sound4"] = "Seal of Might",
    ["Sound5"] = "Sheldon",
    ["Sound6"] = "Arrow Swoosh",
    ["Sound7"] = "Buzzer",
    ["Sound8"] = "Gun Cocking",
    ["Sound9"] = "Laser",
    ["Sound10"] = "Target Acquired",
    ["Sound11"] = "No Alert",
}

-- Configuration options table
local options = {
    name = "FuryWatch",
    handler = FuryWatch,
    type = 'group',
    args = {
        font = {
            type = 'select',
            name = 'Font Selection',
            desc = 'Choose the font for the Fury warning message',
            values = function()
                local fontOptionNames = {}
                for _, fontName in ipairs(LSM:List("font")) do
                    fontOptionNames[fontName] = fontName
                end
                return fontOptionNames
            end,
            get = function(info) return FuryWatch.db.profile.font end,
            set = function(info, value) FuryWatch.db.profile.font = value; FuryWatch:UpdateFont() end,
        },
        fontSize = {
            type = 'range',
            name = 'Font Size',
            desc = 'Set the font size for the Fury warning message',
            min = 10,
            max = 100,
            step = 1,
            get = function(info) return FuryWatch.db.profile.fontSize end,
            set = function(info, value) FuryWatch.db.profile.fontSize = value; FuryWatch:UpdateFont() end,
        },
        fontColor = {
            type = 'color',
            name = 'Font Color',
            desc = 'Set the font color for the Fury warning message',
            get = function(info)
                return unpack(FuryWatch.db.profile.fontColor)
            end,
            set = function(info, r, g, b, a)
                FuryWatch.db.profile.fontColor = {r, g, b, a}
                FuryWatch:UpdateFontColor()
            end,
            hasAlpha = true,
        },
        message = {
            type = 'select',
            name = 'Message',
            desc = 'Select the message to display when Fury is maxed out',
            values = {
                ["Maximum Fury"] = "Maximum Fury",
                ["Fury Full"] = "Fury Full",
                ["Fury Capped"] = "Fury Capped",
                ["Fury Maxed"] = "Fury Maxed",
                ["Fury Ready"] = "Fury Ready",
                ["Fury Overcap"] = "Fury Overcap",
                ["Fury Saturated"] = "Fury Saturated",
                ["Fury Ready"] = "Fury Ready"
            },
            get = function(info) return FuryWatch.db.profile.message end,
            set = function(info, value) FuryWatch.db.profile.message = value; FuryWatch:UpdateMessage() end,
        },
        soundSelection = {
            type = 'select',
            name = 'Sound Selection',
            desc = 'Choose the sound to play when Fury is maxed out',
            values = soundOptionNames,
            get = function(info) return FuryWatch.db.profile.selectedSound end,
            set = function(info, value) FuryWatch.db.profile.selectedSound = value end,
        },
    },
}

-- Initialize
function FuryWatch:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("FuryWatchDB", {
        profile = {
            font = "Friz Quadrata TT",
            fontSize = 30,
            message = "Maximum Fury",
            selectedSound = "Sound1",
            fontColor = {1, 1, 1, 1} -- default to white color
        },
    })
    LibStub("AceConfig-3.0"):RegisterOptionsTable("FuryWatch", options, {"furywatch", "fw"})
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("FuryWatch", "FuryWatch")
    FuryWatch:InitializeFrame()
end

function FuryWatch:InitializeFrame()
    Frame:SetWidth(450)
    Frame:SetHeight(200)
    Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    Frame:SetShadowColor(0.00, 0.00, 0.00, 0.75)
    Frame:SetShadowOffset(3.00, -3.00)
    Frame:SetJustifyH("CENTER")
    Frame:SetMaxLines(2)
    Frame:SetTimeVisible(1)
    Frame:SetFadeDuration(1)
    FuryWatch:UpdateFont()
    FuryWatch:UpdateFontColor() -- Added this line
end

-- Function to update the font
function FuryWatch:UpdateFont()
    local font = LSM:Fetch("font", self.db.profile.font)
    local size = self.db.profile.fontSize
    Frame:SetFont(font, size, "THICKOUTLINE")
end

-- Function to update the font color
function FuryWatch:UpdateFontColor()
    local color = self.db.profile.fontColor
    Frame:SetTextColor(unpack(color))
end

-- Function to update the message
function FuryWatch:UpdateMessage()
    -- Logic for updating the message goes here
end

-- Update Fury warning
function FuryWatch:Update()
    if (floor((UnitPower("player", 17) / UnitPowerMax("player", 17)) * 100) >= Frame.Threshold and Frame.Warned == false) then
        local soundFile = FuryWatch.soundOptions[self.db.profile.selectedSound]
        if soundFile then
            PlaySoundFile(soundFile, "Master")
        end
        
        local message = self.db.profile.message
        local color = self.db.profile.fontColor
        Frame:AddMessage(message, color[1], color[2], color[3], color[4], 3)
        Frame.Warned = true
        return
    end
    
    if (floor((UnitPower("player", 17) / UnitPowerMax("player", 17)) * 100) < Frame.Threshold) then
        Frame.Warned = false
        return
    end
end


-- Handle events
Frame:RegisterEvent("PLAYER_LOGIN")
Frame:RegisterEvent("PLAYER_REGEN_DISABLED")
Frame:RegisterEvent("PLAYER_REGEN_ENABLED")
Frame:RegisterEvent("UNIT_POWER_FREQUENT")
Frame:RegisterEvent("UNIT_MAXPOWER")
Frame:RegisterEvent("PLAYER_TARGET_CHANGED")
Frame:SetScript("OnEvent", function(self, event, arg1, arg2)
    FuryWatch:Update()
end)





