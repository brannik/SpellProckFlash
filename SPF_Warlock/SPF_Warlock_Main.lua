local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "SPF_Warlock" then
        print("|cFFFFA500SPF>>> Welcome Warlock|r")
    end
end)

