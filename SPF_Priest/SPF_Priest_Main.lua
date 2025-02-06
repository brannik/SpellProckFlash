local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "SPF_Priest" then
        print("|cFFFFA500SPF>>> Welcome Priest|r")
    end
end)

