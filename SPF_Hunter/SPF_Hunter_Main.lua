local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "SPF_Hunter" then
        print("|cFFFFA500SPF>>> Welcome Hunter|r")
    end
end)

