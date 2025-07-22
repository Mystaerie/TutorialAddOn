--[[
the "..." passes in the addon name and a namespace that you can attach
variables and functions to so that other parts of the addon can access them
]]
local tao, tao_namespace = ...

-- Create the persistant per character database, if it doesn't already exist
if not tao_db then
    tao_db = {}
end

-- Create the main frame
local mainFrame = CreateFrame(
    "Frame", 
    "TutorialAddOnMainFrame",
    UIParent,
    "BasicFrameTemplateWithInset"
)
mainFrame:SetSize(
    500,
    350
)
mainFrame:SetPoint(
    "CENTER",
    UIParent,
    "CENTER",
    0,
    0
)

-- Create the title for the main frame
mainFrame.TitleBg:SetHeight(30)
mainFrame.title = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
)
mainFrame.title:SetPoint(
    "TOPLEFT",
    mainFrame.TitleBg,
    "TOPLEFT",
    5,
    -3
)
mainFrame.title:SetText(tao)

-- Create the player name
mainFrame.playerName = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)
mainFrame.playerName:SetPoint(
    "TOPLEFT",
    mainFrame,
    "TOPLEFT",
    15,
    -35
)
mainFrame.playerName:SetText(
    -- .. concatenates strings
    "Character: " .. UnitName("player") .. " (Level " .. UnitLevel("player") .. ")"
)

-- Create the total player kills
mainFrame.totalPlayerKills = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)
mainFrame.totalPlayerKills:SetPoint(
    "TOPLEFT",
    mainFrame.playerName,
    "BOTTOMRIGHT",
    0, 
    -10
)
mainFrame.totalPlayerKills:SetText(
    "Total Kills: " .. (tao_db.kills or "0")
)

-- Main frame settings
mainFrame:Hide()
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")

-- What the frame should do on events
mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
mainFrame:SetScript("OnShow", function()
    PlaySound(808)
    mainFrame.totalPlayerKills:SetText(
       "Total Kills: " .. (tao_db.kills or "0")
    )
end)
mainFrame:SetScript("OnHide", function()
    PlaySound(808)
end)

--[[
Create the slash command
The name in the SlashCmdList and the SLASH_ variable MUST MATCH except the number!!!
]]
SLASH_TUTORIALADDON1 = "/tao"
SlashCmdList["TUTORIALADDON"] = function()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

-- Make the main frame special, this means that the escape key will close the window
table.insert(
    UISpecialFrames, 
    "TutorialAddOnMainFrame"
)

-- Create an event listener
local eventListenerFrame = CreateFrame(
    "Frame",
    "TutorialAddOnEventListenerFrame",
    UIParent
)

local function eventHandler(self, event, ...)
    local _, eventType = CombatLogGetCurrentEventInfo()
    
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if eventType and eventType == "PARTY_KILL" then
            if not tao_db.kills then
                tao_db.kills = 1
            else
                tao_db.kills = tao_db.kills + 1
            end
        end
    end
end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")