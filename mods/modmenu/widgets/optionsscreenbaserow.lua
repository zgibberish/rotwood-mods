local Widget = require "widgets.widget"
local Panel = require "widgets.panel"
local Image = require "widgets.image"
local Text = require "widgets.text"
local Clickable = require "widgets.clickable"
local easing = require "util.easing"

------------------------------------------------------------------------------------------
--- A basic option row. Selectable, but doesn't do anything on its own. Meant to be extended
----
OptionsScreenBaseRow = Class(Clickable, function(self, width, rightColumnWidth)
	Clickable._ctor(self, "OptionsScreenBaseRow")

	-- Set up sizings
	self.paddingH = 80
	self.paddingHRight = 40
	self.paddingV = 30
	self.width = width or 1600
	self.rightColumnWidth = rightColumnWidth or 300
	self.textWidth = self.width - self.rightColumnWidth - self.paddingH * 2 - self.paddingHRight -- padding on the left and right, and between the text and the right column
	self.height = 110

	-- Set up colors
	self.bgSelectedColor = GLOBAL.UICOLORS.FOCUS
	self.bgUnselectedColor = GLOBAL.HexToRGB(0xF6B74200)

	self.titleSelectedColor = GLOBAL.UICOLORS.BACKGROUND_DARK
	self.titleUnselectedColor = GLOBAL.UICOLORS.LIGHT_TEXT

	self.subtitleSelectedColor = GLOBAL.UICOLORS.BACKGROUND_MID
	self.subtitleUnselectedColor = GLOBAL.UICOLORS.LIGHT_TEXT_DARKER

	-- Build background
	self.bg = self:AddChild(Panel("images/ui_ftf_options/listrow_bg.tex"))
		:SetNineSliceCoords(40, 28, 508, 109)
		:SetSize(self.width, self.height)
		:SetMultColor(self.bgUnselectedColor)
	self.rightColumnHitbox = self:AddChild(Image("images/global/square.tex"))
		:SetSize(self.rightColumnWidth, self.height)
		:SetMultColor(GLOBAL.HexToRGB(0xff00ff30))
		:LayoutBounds("right", "center", self.bg)
		:Offset(-self.paddingH, 0)
		:SetMultColorAlpha(0)


	-- Add text
	self.textContainer = self:AddChild(Widget("Text Container"))
	self.title = self.textContainer:AddChild(Text(GLOBAL.FONTFACE.DEFAULT, GLOBAL.FONTSIZE.OPTIONS_ROW_TITLE, "", GLOBAL.UICOLORS.WHITE))
		:LeftAlign()
	self.subtitle = self.textContainer:AddChild(Text(GLOBAL.FONTFACE.DEFAULT, GLOBAL.FONTSIZE.OPTIONS_ROW_SUBTITLE, "", GLOBAL.UICOLORS.WHITE))
		:OverrideLineHeight(GLOBAL.FONTSIZE.OPTIONS_ROW_SUBTITLE * 0.85)
		:LeftAlign()

	-- Add right column container
	self.rightContainer = self:AddChild(Widget("Right Container"))

	-- Handle events
	self:SetScales(1, 1.02, 1.02, 0.2)
	self:SetOnGainFocus(function() self:OnFocusChange(true) end)
	self:SetOnLoseFocus(function() self:OnFocusChange(false) end)

	self:OnFocusChange(false)
end)

function OptionsScreenBaseRow:SetText(title, subtitle)

	self.title:SetText(title)
		:SetShown(title)
	self.subtitle:SetText(subtitle)
		:SetShown(subtitle)

	self:Layout()

	return self
end

function OptionsScreenBaseRow:SetSubtitle(subtitle)

	self.subtitle:SetText(subtitle)
		:SetShown(subtitle)

	self:Layout()

	return self
end

function OptionsScreenBaseRow:_TrySetValueToValue(option_key, desired)
	if self.values then
		for i,val in ipairs(self.values) do
			if deepcompare(val.data, desired) then
				--~ TheLog.ch.Settings:print(option_key, "set initial value to index", i)
				self:SetToValueIndex(i)
				return true
			end
		end
	else
		--~ TheLog.ch.Settings:print(option_key, "set initial value to ", desired)
		local silent = true
		self:_SetValue(desired, silent)
		return true
	end
	TheLog.ch.Settings:print(option_key, "FAILED to set initial value to ", desired)
end

function OptionsScreenBaseRow:HookupSetting(option_key, screen)
	-- Set before hookup so we don't trigger all the applies on entering options screen.
	local current = TheGameSettings:Get(option_key)
	kassert.assert_fmt(current ~= nil, "gamesettings doesn't have a default for %s", option_key)
	self:_TrySetValueToValue(option_key, current)

	-- If we wanted to lookup widgets by option name, we could track them like this:
	--   screen.options[option_key] = self
	self:SetOnValueChangeFn(function(data, valueIndex, value)
		--~ TheLog.ch.Settings:print(option_key, "value changed", data, valueIndex)
		TheGameSettings:Set(option_key, data)
		screen:MakeDirty()
	end)
	return self
end

function OptionsScreenBaseRow:SetValues(values)
	self.values = values or {}
	return self
end

function OptionsScreenBaseRow:SetToValueIndex(selectedIndex)
	self:_SetValue(selectedIndex)
end

function OptionsScreenBaseRow:SetOnValueChangeFn(onValueChangeFn)
	self.onValueChangeFn = onValueChangeFn
	return self
end

function OptionsScreenBaseRow:Layout()
	-- Position text
	self.title:SetAutoSize(self.textWidth)
	self.subtitle:SetAutoSize(self.textWidth)
		:LayoutBounds("left", "below", self.title)
		:Offset(0, 2)

	-- Get text size
	local textW, textH = self.textContainer:GetSize()

	-- Get right column size
	local rightW, rightH = self.rightContainer:GetSize()

	-- Resize the background to accomodate both
	self.height = math.max(textH, rightH) + self.paddingV * 2
	self.bg:SetSize(self.width, self.height)
	self.rightColumnHitbox:SetSize(self.rightColumnWidth, self.height)
		:Offset(-self.paddingHRight, 0)

	-- Position stuff
	self.textContainer:LayoutBounds("left", "center", self.bg)
		:Offset(self.paddingH, 0)
	self.rightContainer:LayoutBounds("right", "center", self.bg)
		:Offset(-self.paddingHRight, 0)
	self.rightColumnHitbox:LayoutBounds("right", "center", self.bg)
		:Offset(-self.paddingHRight, 0)

	return self
end

function OptionsScreenBaseRow:OnFocusChange(hasFocus)
	if hasFocus then
		self.bg:TintTo(nil, self.bgSelectedColor, 0.2, easing.outQuad)
		self.title:TintTo(nil, self.titleSelectedColor, 0.2, easing.outQuad)
		self.subtitle:TintTo(nil, self.subtitleSelectedColor, 0.2, easing.outQuad)
	else
		self.bg:TintTo(nil, self.bgUnselectedColor, 0.4, easing.outQuad)
		self.title:TintTo(nil, self.titleUnselectedColor, 0.4, easing.outQuad)
		self.subtitle:TintTo(nil, self.subtitleUnselectedColor, 0.4, easing.outQuad)
	end

	return self
end