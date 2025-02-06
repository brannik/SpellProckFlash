local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "SPF_Mage" then
        print("|cFFFFA500SPF>>> Welcome Mage|r")
    end
end)

