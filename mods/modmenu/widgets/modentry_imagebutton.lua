local Clickable = require "widgets.clickable"
local Panel = require "widgets.panel"
local Image = require "widgets.image"
local easing = require "util.easing"

-- image button meant to be placed in line next to a mod entry (star button, config button, ...)
ModEntryImageButton = Class(Clickable, function(self, texture, width, height)
    Clickable._ctor(self, "ModEntryImageButton")

    -- Set up sizings
	self.paddingH = 80
	self.paddingHRight = 40
	self.paddingV = 30
	self.width = width or 1600
	self.height = height or 110

    -- Set up colors
	self.bgSelectedColor = GLOBAL.UICOLORS.FOCUS
	self.bgUnselectedColor = GLOBAL.HexToRGB(0xF6B74200)

	self.imageSelectedColor = GLOBAL.UICOLORS.BACKGROUND_DARK
	self.imageUnselectedColor = GLOBAL.UICOLORS.LIGHT_TEXT

	-- Build background
	self.bg = self:AddChild(Panel("images/ui_ftf_options/listrow_bg.tex"))
		:SetNineSliceCoords(40, 28, 508, 109)
		:SetSize(self.width, self.height)
		:SetMultColor(self.bgUnselectedColor)
	self.image = self:AddChild(Image(texture))
		:LayoutBounds("center", "center", self.bg)

	-- Handle events
	self:SetScales(1, 1.02, 1.02, 0.2)
	self:SetOnGainFocus(function() self:OnFocusChange(true) end)
	self:SetOnLoseFocus(function() self:OnFocusChange(false) end)

	self:OnFocusChange(false)
end)

function ModEntryImageButton:OnFocusChange(hasFocus)
	if hasFocus then
		self.bg:TintTo(nil, self.bgSelectedColor, 0.2, easing.outQuad)
		self.image:TintTo(nil, self.imageSelectedColor, 0.2, easing.outQuad)
	else
		self.bg:TintTo(nil, self.bgUnselectedColor, 0.4, easing.outQuad)
		self.image:TintTo(nil, self.imageUnselectedColor, 0.4, easing.outQuad)
	end

	return self
end

function ModEntryImageButton:SetImageOffset(x, y)
	self.image:Offset(x,y)
	return self
end