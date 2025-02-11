local CooldownTracker = CreateFrame("Frame")
CooldownTracker:RegisterEvent("PLAYER_LOGIN")
CooldownTracker:RegisterEvent("SPELL_UPDATE_COOLDOWN")
CooldownTracker:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

local trackedCooldowns = {
    [12472] = {duration = 180},  -- Icy Veins
    [12042] = {duration = 120},  -- Arcane Power
    [55342] = {duration = 180},  -- Mirror Image
}

local cooldownFrame = CreateFrame("Frame", "CooldownTrackerFrame", UIParent)
cooldownFrame:SetSize(50, 400)
cooldownFrame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)

local iconFrames = {}

local function GetRemainingCooldown(spellID)
    local start, duration, enabled = GetSpellCooldown(spellID)
    if enabled == 1 and duration > 1.5 then
        return (start + duration) - GetTime()
    end
    return nil
end

local function UpdateCooldownIcons()
    local index = 0
    for spellID, data in pairs(trackedCooldowns) do
        local remaining = GetRemainingCooldown(spellID)
        local spellName, _, icon = GetSpellInfo(spellID)

        if remaining and remaining > 0 then
            local iconFrame = iconFrames[index] or CreateFrame("Frame", "CooldownIcon" .. index, cooldownFrame)
            iconFrame:SetSize(40, 40)
            iconFrame:SetPoint("TOP", cooldownFrame, "TOP", 0, -index * 45)

            local iconTexture = iconFrame.icon or iconFrame:CreateTexture(nil, "ARTWORK")
            iconTexture:SetAllPoints()
            iconTexture:SetTexture(icon)
            iconFrame.icon = iconTexture

            local timeText = iconFrame.text or iconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            timeText:SetPoint("CENTER", iconFrame, "CENTER", 55, 0)
            timeText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
            timeText:SetText(string.format("%.1fs", remaining))
            iconFrame.text = timeText

            iconFrame:Show()
            iconFrames[index] = iconFrame
            index = index + 1
        end
    end

    for i = index, #iconFrames do
        local iconFrame = iconFrames[i]
        if iconFrame then
            iconFrame:Hide()
            iconFrame.icon:Hide()
            iconFrame.text:Hide()
            iconFrame:ClearAllPoints()
            iconFrame:Hide()
            iconFrames[i] = nil
        end
    end
end

CooldownTracker:SetScript("OnEvent", function(self, event, ...)
    if event == "SPELL_UPDATE_COOLDOWN" or event == "UNIT_SPELLCAST_SUCCEEDED" then
        UpdateCooldownIcons()
    end
end)

cooldownFrame:SetScript("OnUpdate", function()
    UpdateCooldownIcons()
end)