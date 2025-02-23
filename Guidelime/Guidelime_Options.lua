local addonName, addon = ...
local L = addon.L

local function HexToRGB(hex)
	local rhex, ghex, bhex = string.sub(hex, 5, 6), string.sub(hex, 7, 8), string.sub(hex, 9, 10)
	return tonumber(rhex, 16) / 255, tonumber(ghex, 16) / 255, tonumber(bhex, 16) / 255
end

local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("|cFF%02x%02x%02x", r*255, g*255, b*255)
end

local function showColorPicker(color, callback)
	ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = false, nil;
	local r,g,b = HexToRGB(color)
	ColorPickerFrame.previousValues = {r,g,b,1};
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = callback, nil, nil;
	ColorPickerFrame:SetColorRGB(r,g,b);
	ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
	ColorPickerFrame:Show();
end

local function getColorPickerColor()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	return RGBToHex(r, g, b)
end

function addon.fillOptions()
	addon.optionsFrame = CreateFrame("FRAME", nil, addon.guidesFrame)
	addon.optionsFrame.name = GAMEOPTIONS_MENU
	addon.optionsFrame.parent = GetAddOnMetadata(addonName, "title")
	InterfaceOptions_AddCategory(addon.optionsFrame)

	addon.optionsFrame.title = addon.optionsFrame:CreateFontString(nil, addon.optionsFrame, "GameFontNormal")
	addon.optionsFrame.title:SetText(GetAddOnMetadata(addonName, "title") .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version") .." - " .. GAMEOPTIONS_MENU)
	addon.optionsFrame.title:SetPoint("TOPLEFT", 20, -20)
	addon.optionsFrame.title:SetFontObject("GameFontNormalLarge")
	local prev = addon.optionsFrame.title

    local scrollFrame = CreateFrame("ScrollFrame", nil, addon.optionsFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -20)
    scrollFrame:SetPoint("RIGHT", addon.optionsFrame, "RIGHT", -30, 0)
    scrollFrame:SetPoint("BOTTOM", addon.optionsFrame, "BOTTOM", 0, 10)

    local content = CreateFrame("Frame", nil, scrollFrame) 
    content:SetSize(1, 1) 
    scrollFrame:SetScrollChild(content)
	prev = content

	-- Guide window options

	addon.optionsFrame.titleGuideWindow = content:CreateFontString(nil, content, "GameFontNormal")
	addon.optionsFrame.titleGuideWindow:SetText("|cFFFFFFFF___ " .. L.GUIDE_WINDOW .. " _______________________________________________________")
	addon.optionsFrame.titleGuideWindow:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	addon.optionsFrame.titleGuideWindow:SetFontObject("GameFontNormalLarge")
	local prev = addon.optionsFrame.titleGuideWindow

	content.options = {}		
	local checkbox = addon.addCheckOption(content, GuidelimeDataChar, "mainFrameShowing", L.SHOW_MAINFRAME, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.showMainFrame()
		elseif addon.mainFrame ~= nil then
			HBDPins:RemoveAllWorldMapIcons(Guidelime)
			HBDPins:RemoveAllMinimapIcons(Guidelime)
			addon.mainFrame:Hide()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox
	
	local slider = addon.addSliderOption(content, GuidelimeDataChar, "mainFrameWidth", 50, 800, 1, L.MAIN_FRAME_WIDTH, nil, function()
		if addon.mainFrame ~= nil then 
			addon.mainFrame:SetWidth(GuidelimeDataChar.mainFrameWidth) 
			addon.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
		end
	end, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame(true)
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -10)
	slider = addon.addSliderOption(content, GuidelimeDataChar, "mainFrameHeight", 50, 600, 1, L.MAIN_FRAME_HEIGHT, nil, function()
		if addon.mainFrame ~= nil then 
			addon.mainFrame:SetHeight(GuidelimeDataChar.mainFrameHeight) 
			addon.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
		end
	end, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -50)
	slider = addon.addSliderOption(content, GuidelimeDataChar, "mainFrameAlpha", 0, 1, 0.01, L.MAIN_FRAME_ALPHA, nil, function()
		if addon.mainFrame ~= nil then 
			addon.mainFrame.bg:SetColorTexture(0, 0, 0, GuidelimeDataChar.mainFrameAlpha)
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -90)
	
	slider = addon.addSliderOption(content, GuidelimeDataChar, "mainFrameFontSize", 8, 24, 1, L.MAIN_FRAME_FONT_SIZE, nil, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame(true)
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -130)

	slider = addon.addSliderOption(content, GuidelimeData, "maxNumOfSteps", 0, 50, 1, L.MAX_NUM_OF_STEPS, nil, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -180)

	checkbox = addon.addCheckOption(content, GuidelimeDataChar, "mainFrameLocked", L.LOCK_MAINFRAME, nil, function()
		if GuidelimeDataChar.mainFrameLocked then
	    	addon.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Unlocked-Down")
	    	addon.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Locked-Up")
		else
	    	addon.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Unlocked-Down")
	    	addon.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Locked-Up")
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox
	
	addon.optionsFrame.showCompletedSteps = addon.addCheckOption(content, GuidelimeDataChar, "showCompletedSteps", L.SHOW_COMPLETED_STEPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	addon.optionsFrame.showCompletedSteps:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = addon.optionsFrame.showCompletedSteps
	
	checkbox = addon.addCheckOption(content, GuidelimeDataChar, "showUnavailableSteps", L.SHOW_UNAVAILABLE_STEPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	checkbox = addon.addCheckOption(content, GuidelimeData, "showQuestLevels", L.SHOW_SUGGESTED_QUEST_LEVELS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	checkbox = addon.addCheckOption(content, GuidelimeData, "showMinimumQuestLevels", L.SHOW_MINIMUM_QUEST_LEVELS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	text = content:CreateFontString(nil, content, "GameFontNormal")
	text:SetText(L.SELECT_COLORS)
	text:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 30, -8)
	prev = text

	local button = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	button:SetWidth(100)
	button:SetHeight(20)
	button:SetText(GuidelimeData.fontColorACCEPT .. L.QUEST_ACCEPT)
	button:SetPoint("TOPLEFT", checkbox, "BOTTOMLEFT", 110, -4)
	button:SetScript("OnClick", function()
		showColorPicker(GuidelimeData.fontColorACCEPT, function()
			GuidelimeData.fontColorACCEPT = getColorPickerColor()
			button:SetText(GuidelimeData.fontColorACCEPT .. L.QUEST_ACCEPT)
			if GuidelimeDataChar.mainFrameShowing then
				addon.updateStepsText()
			end
		end)
	end)
	local button = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	button:SetWidth(100)
	button:SetHeight(20)
	button:SetText(GuidelimeData.fontColorCOMPLETE .. L.QUEST_COMPLETE)
	button:SetPoint("TOPLEFT", checkbox, "BOTTOMLEFT", 210, -4)
	button:SetScript("OnClick", function()
		showColorPicker(GuidelimeData.fontColorCOMPLETE, function()
			GuidelimeData.fontColorCOMPLETE = getColorPickerColor()
			button:SetText(GuidelimeData.fontColorCOMPLETE .. L.QUEST_COMPLETE)
			if GuidelimeDataChar.mainFrameShowing then
				addon.updateStepsText()
			end
		end)
	end)
	local button = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	button:SetWidth(100)
	button:SetHeight(20)
	button:SetText(GuidelimeData.fontColorTURNIN .. L.QUEST_TURNIN)
	button:SetPoint("TOPLEFT", checkbox, "BOTTOMLEFT", 110, -24)
	button:SetScript("OnClick", function()
		showColorPicker(GuidelimeData.fontColorTURNIN, function()
			GuidelimeData.fontColorTURNIN = getColorPickerColor()
			button:SetText(GuidelimeData.fontColorTURNIN .. L.QUEST_TURNIN)
			if GuidelimeDataChar.mainFrameShowing then
				addon.updateStepsText()
			end
		end)
	end)
	local button = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	button:SetWidth(100)
	button:SetHeight(20)
	button:SetText(GuidelimeData.fontColorSKIP .. L.QUEST_SKIP)
	button:SetPoint("TOPLEFT", checkbox, "BOTTOMLEFT", 210, -24)
	button:SetScript("OnClick", function()
		showColorPicker(GuidelimeData.fontColorSKIP, function()
			GuidelimeData.fontColorSKIP = getColorPickerColor()
			button:SetText(GuidelimeData.fontColorSKIP .. L.QUEST_SKIP)
			if GuidelimeDataChar.mainFrameShowing then
				addon.updateStepsText()
			end
		end)
	end)

	-- Arrow options

	addon.optionsFrame.titleArrow = content:CreateFontString(nil, content, "GameFontNormal")
	addon.optionsFrame.titleArrow:SetText("|cFFFFFFFF___ " .. L.ARROW .. " _____________________________________________________________________")
	addon.optionsFrame.titleArrow:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -30, -30)
	addon.optionsFrame.titleArrow:SetFontObject("GameFontNormalLarge")
	prev = addon.optionsFrame.titleArrow

	checkbox = addon.addCheckOption(content, GuidelimeDataChar, "showArrow", L.SHOW_ARROW, nil, function()
		if addon.arrowFrame ~= nil then
			if GuidelimeDataChar.showArrow then
				addon.arrowFrame:Show()
			else
				addon.arrowFrame:Hide()
			end
			addon.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox
	
	slider = addon.addSliderOption(content, GuidelimeData, "arrowStyle", 1, 2, 1, L.ARROW_STYLE, nil, 
	function(self)
		self.editbox:SetText("   " .. addon.getArrowIconText())
    	self.editbox:SetCursorPosition(0)
	end, function()
		if addon.arrowFrame ~= nil then
			addon.setArrowTexture()
			addon.updateSteps() 
		end
	end)
	slider.editbox:SetText("   " .. addon.getArrowIconText())
    slider.editbox:SetCursorPosition(0)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -10)

	slider = addon.addSliderOption(content, GuidelimeDataChar, "arrowAlpha", 0, 1, 0.01, L.ARROW_ALPHA, nil, function()
		if addon.arrowFrame ~= nil then 
			addon.arrowFrame:SetAlpha(GuidelimeDataChar.arrowAlpha)
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -50)

	checkbox = addon.addCheckOption(content, GuidelimeData, "arrowDistance", L.SHOW_DISTANCE, nil, function()
		if addon.arrowFrame ~= nil then 
			addon.updateSteps() 
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	-- Map marker options

	addon.optionsFrame.titleMapMarkers = content:CreateFontString(nil, content, "GameFontNormal")
	addon.optionsFrame.titleMapMarkers:SetText("|cFFFFFFFF___ " .. L.MAP_MARKERS .. " _______________________________________________________")
	addon.optionsFrame.titleMapMarkers:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	addon.optionsFrame.titleMapMarkers:SetFontObject("GameFontNormalLarge")
	prev = addon.optionsFrame.titleMapMarkers

	addon.optionsFrame.textShowMarkersGOTO = content:CreateFontString(nil, content, "GameFontNormal")
	addon.optionsFrame.textShowMarkersGOTO:SetText(string.format(L.SHOW_MARKERS_GOTO_ON, addon.getMapMarkerText({t = "GOTO", mapIndex = 1}) .. "," .. addon.getMapMarkerText({t = "GOTO", mapIndex = 2}) .. "," .. addon.getMapMarkerText({t = "GOTO", mapIndex = 3})))
	addon.optionsFrame.textShowMarkersGOTO:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
	prev = addon.optionsFrame.textShowMarkersGOTO

	slider = addon.addSliderOption(content, GuidelimeData, "maxNumOfMarkersGOTO", 0, 50, 1, L.MAX_NUM_OF_MARKERS_GOTO, nil, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateSteps()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -20)

	slider = addon.addSliderOption(content, GuidelimeData, "maxNumOfMarkersLOC", 0, 50, 1, L.MAX_NUM_OF_MARKERS_LOC, nil, nil, function()
		addon.loadCurrentGuide()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -70)

	slider = addon.addSliderOption(content, GuidelimeData, "mapMarkerStyle", 1, 3, 1, L.MAP_MARKER_STYLE, nil, function(self)
		self.editbox:SetText(addon.getMapMarkerText({t = "GOTO", mapIndex = 0}) .. addon.getMapMarkerText({t = "GOTO", mapIndex = 1}))
    	self.editbox:SetCursorPosition(0)
		addon.optionsFrame.textShowMarkersGOTO:SetText(string.format(L.SHOW_MARKERS_GOTO_ON, addon.getMapMarkerText({t = "GOTO", mapIndex = 1}) .. "," .. addon.getMapMarkerText({t = "GOTO", mapIndex = 2}) .. "," .. addon.getMapMarkerText({t = "GOTO", mapIndex = 3})))
		addon.optionsFrame.textShowMarkersLOC:SetText(string.format(L.SHOW_MARKERS_LOC_ON, addon.getMapMarkerText({t = "monster"}) .. "," .. addon.getMapMarkerText({t = "item"}) .. "," .. addon.getMapMarkerText({t = "object"})))
	end, function()
		addon.setMapIconTextures()
		addon.updateSteps() 
	end)
	slider.editbox:SetText(addon.getMapMarkerText({t = "GOTO", mapIndex = 0}) .. addon.getMapMarkerText({t = "GOTO", mapIndex = 1}))
    slider.editbox:SetCursorPosition(0)
	
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -110)

	slider = addon.addSliderOption(content, GuidelimeData, "mapMarkerSize", 8, 32, 1, L.MAP_MARKER_SIZE, nil, nil, function()
		addon.setMapIconTextures()
		addon.updateSteps() 
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -150)

	checkbox = addon.addCheckOption(content, GuidelimeData, "showMapMarkersGOTO", L.MAP, nil, function()
		addon.loadCurrentGuide()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox
	
	checkbox = addon.addCheckOption(content, GuidelimeData, "showMinimapMarkersGOTO", L.MINIMAP, nil, function()
		addon.loadCurrentGuide()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", addon.optionsFrame.textShowMarkersGOTO, "BOTTOMLEFT", 80, 0)

	addon.optionsFrame.textShowMarkersLOC = content:CreateFontString(nil, content, "GameFontNormal")
	addon.optionsFrame.textShowMarkersLOC:SetText(string.format(L.SHOW_MARKERS_LOC_ON, addon.getMapMarkerText({t = "monster"}) .. "," .. addon.getMapMarkerText({t = "item"}) .. "," .. addon.getMapMarkerText({t = "object"})))
	addon.optionsFrame.textShowMarkersLOC:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = addon.optionsFrame.textShowMarkersLOC

	checkbox = addon.addCheckOption(content, GuidelimeData, "showMapMarkersLOC", L.MAP, nil, function()
		addon.loadCurrentGuide()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	checkbox = addon.addCheckOption(content, GuidelimeData, "showMinimapMarkersLOC", L.MINIMAP, nil, function()
		addon.loadCurrentGuide()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", addon.optionsFrame.textShowMarkersLOC, "BOTTOMLEFT", 80, 0)

	-- General options
	
	addon.optionsFrame.titleGeneral = content:CreateFontString(nil, content, "GameFontNormal")
	addon.optionsFrame.titleGeneral:SetText("|cFFFFFFFF___ " .. L.GENERAL_OPTIONS .. " _______________________________________________________")
	addon.optionsFrame.titleGeneral:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -70)
	addon.optionsFrame.titleGeneral:SetFontObject("GameFontNormalLarge")
	prev = addon.optionsFrame.titleGeneral

	checkbox = addon.addCheckOption(content, GuidelimeData, "autoAddCoordinates", L.AUTO_ADD_COORDINATES, nil, function()
		addon.loadCurrentGuide()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox

	checkbox = addon.addCheckOption(content, GuidelimeDataChar, "autoCompleteQuest", L.AUTO_COMPLETE_QUESTS)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	checkbox = addon.addCheckOption(content, GuidelimeData, "skipCutscenes", L.SKIP_CUTSCENES, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	checkbox = addon.addCheckOption(content, GuidelimeData, "displayDemoGuides", L.DISPLAY_DEMO_GUIDES, nil, addon.fillGuides)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	checkbox = addon.addCheckOption(content, GuidelimeData, "showTooltips", L.SHOW_TOOLTIPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	-- Debugging options

	addon.optionsFrame.titleDebugging = content:CreateFontString(nil, content, "GameFontNormal")
	addon.optionsFrame.titleDebugging:SetText("|cFFFFFFFF___ " .. L.DEBUGGING_OPTIONS .. " _______________________________________________________")
	addon.optionsFrame.titleDebugging:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	addon.optionsFrame.titleDebugging:SetFontObject("GameFontNormalLarge")
	prev = addon.optionsFrame.titleDebugging

	checkbox = addon.addCheckOption(content, GuidelimeData, "debugging", L.DEBUGGING, nil, function()
		addon.debugging = GuidelimeData.debugging
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox

	checkbox = addon.addCheckOption(content, GuidelimeData, "showLineNumbers", L.SHOW_LINE_NUMBERS, nil, function()
		addon.debugging = GuidelimeData.debugging
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	checkbox = addon.addCheckOption(content, GuidelimeData, "dataSourceQuestie", L.USE_QUESTIE_AS_DATA_SOURCE, L.USE_QUESTIE_AS_DATA_SOURCE_TOOLTIP, function()
		addon.optionsFrame.options.dataSourceInternal:SetChecked(not GuidelimeData.dataSourceQuestie)
		if GuidelimeDataChar.mainFrameShowing and GuidelimeData.autoAddCoordinates then
			addon.loadCurrentGuide()
			addon.updateSteps()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	checkbox:SetEnabled(Questie ~= nil)
	if Questie == nil then checkbox.text:SetTextColor(0.4, 0.4, 0.4) end
	prev = checkbox
	
	content.options.dataSourceInternal = addon.addCheckbox(content, L.USE_INTERNAL_DATA_SOURCE)
	if not GuidelimeData.dataSourceQuestie then content.options.dataSourceInternal:SetChecked(true) end
	content.options.dataSourceInternal:SetScript("OnClick", function()
		GuidelimeData.dataSourceQuestie = Questie ~= nil and not content.options.dataSourceInternal:GetChecked() 
		content.options.dataSourceInternal:SetChecked(not GuidelimeData.dataSourceQuestie)
		content.options.dataSourceQuestie:SetChecked(GuidelimeData.dataSourceQuestie)
		if GuidelimeDataChar.mainFrameShowing and GuidelimeData.autoAddCoordinates then
			addon.loadCurrentGuide()
			addon.updateSteps()
		end
	end)
	content.options.dataSourceInternal:SetPoint("TOPLEFT", prev, "TOPLEFT", 270, 0)
end

function addon.isOptionsShowing()
	return InterfaceOptionsFrame:IsShown() and InterfaceOptionsFramePanelContainer.displayedPanel == addon.optionsFrame
end

function addon.showOptions()
	if not addon.dataLoaded then loadData() end
	if addon.isOptionsShowing() then 
		InterfaceOptionsFrame:Hide()
	else
		if addon.isEditorShowing() then addon.editorFrame:Hide() end
		-- calling twice ensures options are shown. calling once might only show game options. why? idk
		InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame)
	end
end
