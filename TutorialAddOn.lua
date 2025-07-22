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

-- Create the money counters
mainFrame.totalGold = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)
mainFrame.totalGold:SetPoint(
    "TOPLEFT",
    mainFrame.playerName,
    "BOTTOMRIGHT",
    0,
    -22
)
mainFrame.totalGold:SetText(
    "Gold: " .. (tao_db.gold or "0")
)
mainFrame.totalSilver = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)
mainFrame.totalSilver:SetPoint(
    "TOPLEFT",
    mainFrame.playerName,
    "BOTTOMRIGHT",
    0,
    -34
)
mainFrame.totalSilver:SetText(
    "Silver: " .. (tao_db.silver or "0")
)
mainFrame.totalCopper = mainFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormal"
)
mainFrame.totalCopper:SetPoint(
    "TOPLEFT",
    mainFrame.playerName,
    "BOTTOMRIGHT",
    0,
    -46
)
mainFrame.totalCopper:SetText(
    "Copper: " .. (tao_db.copper or "0")
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
    mainFrame.totalGold:SetText(
        "Gold: " .. (tao_db.gold or "0")
    )
    mainFrame.totalSilver:SetText(
       "Silver: " .. (tao_db.silver or "0")
    )
    mainFrame.totalCopper:SetText(
       "Copper: " .. (tao_db.copper or "0")
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

-- Convert money
local function moneyConverter(lower, upper)
    upper = upper + math.floor(lower / 100)
    lower = lower % 100
    return lower, upper
end

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
    elseif event == "CHAT_MSG_MONEY" then
        local msg = ... -- the chat message to be parsed
        local gold = tonumber(string.match(msg, "(%d+) Gold")) or 0
        local silver = tonumber(string.match(msg, "(%d+) Silver")) or 0
        local copper = tonumber(string.match(msg, "(%d+) Copper")) or 0

        tao_db.gold = (tao_db.gold or 0) + gold
        tao_db.silver = (tao_db.silver or 0) + silver
        tao_db.copper = (tao_db.copper or 0) + copper

        if tao_db.copper >= 100 then
            tao_db.copper, tao_db.silver = moneyConverter(
                tao_db.copper, 
                tao_db.silver
            )
        end

        if tao_db.silver >= 100 then
            tao_db.silver, tao_db.gold = moneyConverter(
                tao_db.silver,
                tao_db.gold
            )
        end
    end

    -- update the window if it is shown
    if mainFrame:IsShown() then
        mainFrame.totalPlayerKills:SetText(
            "Total Kills: " .. (tao_db.kills or "0")
        )
        mainFrame.totalGold:SetText(
            "Gold: " .. (tao_db.gold or "0")
        )
        mainFrame.totalSilver:SetText(
            "Silver: " .. (tao_db.silver or "0")
        )
        mainFrame.totalCopper:SetText(
            "Copper: " .. (tao_db.copper or "0")
        )
    end
end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventListenerFrame:RegisterEvent("CHAT_MSG_MONEY")