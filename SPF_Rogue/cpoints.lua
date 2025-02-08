local frame = CreateFrame("Frame", "ComboPointTracker", UIParent)
frame:SetSize(150, 40)  -- Adjusted size to fit the larger empty points and full points
frame:SetPoint("CENTER", UIParent, "CENTER", -10, -100)  -- Adjust position
frame:EnableMouse(true)
frame:SetMovable(true)

-- Only move if Shift + Left Click
frame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and IsShiftKeyDown() then
        self:StartMoving()
    end
end)

frame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
    end
end)

-- Paths to textures
local EMPTY_TEXTURE = "Interface\\AddOns\\SPF_Rogue\\Resources\\empty_cpoint.tga"
local FULL_TEXTURE = "Interface\\AddOns\\SPF_Rogue\\Resources\\full_cpoint.tga"

-- Define colors for each combo point (RGB format)
local pointsColors = {
    [1] = {1, 1, 0},    -- Yellow
    [2] = {1, 1, 0},    -- Yellow
    [3] = {1, 1, 0},    -- Yellow
    [4] = {1, 0.5, 0},  -- Orange
    [5] = {0, 1, 0},    -- Red
}

-- Create combo point circles
local circles = {}
for i = 1, 5 do
    -- Empty point (larger for the border effect)
    local emptyCircle = frame:CreateTexture(nil, "OVERLAY")
    emptyCircle:SetSize(30, 30)  -- Larger empty circle for border effect
    emptyCircle:SetTexture(EMPTY_TEXTURE)
    emptyCircle:SetPoint("LEFT", frame, "LEFT", (i - 1) * 35, 0)  -- Position circles with extra space
    circles[i] = {empty = emptyCircle}

    -- Filled point (smaller, inside the empty circle)
    local fullCircle = frame:CreateTexture(nil, "OVERLAY")
    fullCircle:SetSize(20, 20)  -- Smaller filled circle
    fullCircle:SetTexture(FULL_TEXTURE)
    fullCircle:SetPoint("CENTER", emptyCircle, "CENTER")  -- Position inside the empty circle
    fullCircle:Hide()  -- Hide by default
    circles[i].full = fullCircle
end

-- Function to update combo point display
local function UpdateComboPoints()
    local points = GetComboPoints("player", "target")

    -- Ensure all circles are set to empty and hidden
    for i = 1, 5 do
        circles[i].full:Hide()
        circles[i].empty:SetVertexColor(1, 1, 1)  -- Reset color to default white
    end

    -- Fill active combo points with colors and show full circles inside the empty ones
    for i = 1, points do
        circles[i].full:Show()
        circles[i].full:SetVertexColor(unpack(pointsColors[i]))  -- Apply color to full combo point
    end

    -- Always show frame, even at 0 combo points (with border empty circles)
    frame:Show()
end

-- Event handling
frame:SetScript("OnEvent", function(self, event, arg1)
    if not UnitAffectingCombat("player") then return end
    if event == "UNIT_COMBO_POINTS" and arg1 == "player" then
        UpdateComboPoints()
    elseif event == "PLAYER_TARGET_CHANGED" then
        UpdateComboPoints()
    end
end)

-- Register events
frame:RegisterEvent("UNIT_COMBO_POINTS")  -- Fires in real-time when combo points change
frame:RegisterEvent("PLAYER_TARGET_CHANGED")  -- Fires when target changes

-- Initialize display
UpdateComboPoints()
