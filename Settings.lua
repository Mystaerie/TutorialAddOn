--[[
the "..." passes in the addon name and a namespace that you can attach
variables and functions to so that other parts of the addon can access them
]]
local tao, tao_namespace = ...

local settings = {
    {
        settingText = "Enable tracking of Kills",
        settingKey = "enableKillTracking",
        settingTooltip = "While enabled, your kills will be tracked.",
    },
    {
        settingText = "Enable tracking of Currency",
        settingKey = "enableCurrencyTracking",
        settingTooltip = "While enabled, your currency gained will be tracked.",
    },
}

-- Create the settings frame
local settingsFrame = CreateFrame(
    "Frame",
    "TutorialAddOnSettingsFrame",
    UIParent,
    "BasicFrameTemplateWithInset"
)
settingsFrame:SetSize(
    400,
    300
)
settingsFrame:SetPoint("CENTER")

-- Create the settings title
settingsFrame.TitleBg:SetHeight(30)
settingsFrame.title = settingsFrame:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
)
settingsFrame.title:SetPoint(
    "CENTER",
    settingsFrame.TitleBg,
    "CENTER",
    0,
    -3
)
settingsFrame.title:SetText(
    tao .. " Settings"
)

-- Settings frame settings
settingsFrame:Hide()
settingsFrame:EnableMouse(true)
settingsFrame:SetMovable(true)
settingsFrame:RegisterForDrag("LeftButton")

-- What the settings frame should do on events
settingsFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
settingsFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Time to make some checkboxes
local checkboxes = 0

local function createCheckbox(checkboxText, key, checkboxTooltip)
    -- make a single checkbox
    local checkbox = CreateFrame(
        "CheckButton",
        "TutorialAddOnCheckboxID" .. checkboxes,
        settingsFrame,
        "UICheckButtonTemplate"
    )
    checkbox.Text:SetText(checkboxText)
    checkbox:SetPoint(
        "TOPLEFT", 
        settingsFrame, 
        "TOPLEFT", 
        10, 
        -30 + (checkboxes * -30)
    )

    -- check that the settings key for this checkbox exists
    if not tao_db.settingsKeys[key] then
        tao_db.settingsKeys[key] = true
    end

    -- set the checkbox
    checkbox:SetChecked(tao_db.settingsKeys[key])

    -- set up the checkbox events
    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(checkboxTooltip, nil, nil, nil, nil, true)
    end)

    checkbox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    checkbox:SetScript("OnClick", function(self)
        tao_db.settingsKeys[key] = self:GetChecked()
    end)

    checkboxes = checkboxes + 1

    -- return the checkbox
    return checkbox
end

-- Event listener
local eventListenerFrame = CreateFrame(
    "Frame",
    "TutorialAddOnSettingsEventListenerFrame",
    UIParent
)
eventListenerFrame:RegisterEvent("PLAYER_LOGIN")

eventListenerFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if not tao_db.settingsKeys then
            tao_db.settingsKeys = {}
        end

        for _, setting in pairs(settings) do
            createCheckbox(
                setting.settingText, 
                setting.settingKey, 
                setting.settingTooltip
            )
        end
    end
end)

-- creating a minimap icon
local addon = LibStub("AceAddon-3.0"):NewAddon("TutorialAddOn")

local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("TutorialAddOn", {
    type = "data source",
    text = "TutorialAddOn",
    icon = "Interface\\AddOns\\TutorialAddOn\\minimap.tga",
    OnClick = function(self, btn)
        if btn == "LeftButton" then
            TutorialAddOn:ToggleMainFrame()
        elseif btn == "RightButton" then
            if settingsFrame:IsShown() then
                settingsFrame:Hide()
            else
                settingsFrame:Show()
            end
        end
    end,

    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then
            return
        end

        tooltip:AddLine("TutorialAddOn\n\nLeft-click: Open TutorialAddOn\nRight-click: Open TutorialAddOn Settings", nil, nil, nil, nil)
    end,
})

TutorialAddOnMinimapButton = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("TutorialAddOnMinimapPOS", {
        profile = {
            minimap = {
                hide = false,
            }
        }
    })

    TutorialAddOnMinimapButton:Register("TutorialAddOn", miniButton, self.db.profile.minimap)
end

TutorialAddOnMinimapButton:Show("TutorialAddOn")