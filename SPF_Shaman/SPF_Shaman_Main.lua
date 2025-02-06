local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "SPF_Shaman" then
        print("|cFFFFA500SPF>>> Welcome Shaman|r")
    end
end)

