local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "SPF_Druid" then
        print("|cFFFFA500SPF>>> Welcome Druid|r")
    end
end)

