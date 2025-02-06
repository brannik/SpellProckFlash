local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "SPF_Rogue" then
        print("|cFFFFA500SPF>>> Welcome Rogue|r")
    end
end)

