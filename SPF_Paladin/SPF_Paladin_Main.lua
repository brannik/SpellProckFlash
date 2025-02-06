local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "SPF_Paladin" then
        print("|cFFFFA500SPF>>> Welcome Paladin|r")
    end
end)

