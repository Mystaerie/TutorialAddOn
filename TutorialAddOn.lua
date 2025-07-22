--[[
the "..." passes in the addon name and a namespace that you can attach
variables and functions to so that other parts of the addon can access them
]]
local tao, tao_namespace = ...

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

mainFrame:Hide()

mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")

mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

mainFrame:SetScript("OnShow", function()
    PlaySound(808)
end)

mainFrame:SetScript("OnHide", function()
    PlaySound(808)
end)