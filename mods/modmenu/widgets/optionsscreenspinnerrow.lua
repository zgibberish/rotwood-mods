local ImageButton = require --[[  ]]"widgets.imagebutton"
local Text = require "widgets.text"
local easing = require "util.easing"

modimport("widgets/optionsscreenbaserow")
modimport("widgets/optionsrowpagination")

------------------------------------------------------------------------------------------
--- An option row that allows you to loop through discrete values
----
OptionsScreenSpinnerRow = Class(OptionsScreenBaseRow, function(self, width, rightColumnWidth)
	OptionsScreenBaseRow._ctor(self, width, rightColumnWidth)
	self:SetName("OptionsScreenSpinnerRow")


	-- Set up sizings
	self.arrowSize = 60
	self.valueTextWidth = self.rightColumnWidth - self.arrowSize * 2


	-- Set up colors
	self.arrowSelectedColor = self.titleSelectedColor
	self.arrowFocusColor = self.subtitleSelectedColor
	self.arrowUnselectedColor = self.titleUnselectedColor
	self.paginationUnselectedColor = GLOBAL.HexToRGB(0xB6965500)


	-- Build right column contents
	self.valueLeftArrow = self.rightContainer:AddChild(ImageButton("images/ui_ftf_options/pagination_left.tex"))
		:SetSize(self.arrowSize, self.arrowSize)
		:SetOnClick(function() self:OnArrowLeft() end)
		:SetScaleOnFocus(false)
	self.valueText = self.rightContainer:AddChild(Text(GLOBAL.FONTFACE.DEFAULT, GLOBAL.FONTSIZE.OPTIONS_ROW_TITLE, "", GLOBAL.UICOLORS.WHITE))
		:SetAutoSize(self.valueTextWidth)
	self.valueRightArrow = self.rightContainer:AddChild(ImageButton("images/ui_ftf_options/pagination_right.tex"))
		:SetSize(self.arrowSize, self.arrowSize)
		:SetOnClick(function() self:OnArrowRight() end)
		:SetScaleOnFocus(false)
	self.pagination = self.rightContainer:AddChild(OptionsRowPagination())

	-- Default values
	self.currentIndex = 0

	-- Swallow sideways focus moves since that's how you change us.
	self:SetFocusDir("right", self, true)
	self:SetFocusDir("left", self, true)

	self:OnFocusChange(false)
end)

OptionsScreenSpinnerRow.CONTROL_MAP = {
	{
		control = GLOBAL.Controls.Digital.MENU_ONCE_RIGHT,
		hint = function(self, left, right)
			-- table.insert(right, loc.format(LOC"UI.CONTROLS.NEXT", Controls.Digital.MENU_ONCE_RIGHT))
		end,
		fn = function(self)
			self:OnArrowRight()
			return true
		end,
	},
	{
		control = GLOBAL.Controls.Digital.MENU_ONCE_LEFT,
		hint = function(self, left, right)
			-- table.insert(right, loc.format(LOC"UI.CONTROLS.PREV", Controls.Digital.MENU_ONCE_LEFT))
		end,
		fn = function(self)
			self:OnArrowLeft()
			return true
		end,
	},
}

function OptionsScreenSpinnerRow:Layout()

	-- Layout right column elements
	self.valueLeftArrow:LayoutBounds("left", "center", self.rightColumnHitbox)
	self.valueRightArrow:LayoutBounds("right", "center", self.rightColumnHitbox)
	self.valueText:LayoutBounds("center", "center", self.rightColumnHitbox)
	self.pagination:LayoutBounds("center", "below", self.valueText)
		:Offset(0, -4)

	OptionsScreenSpinnerRow._base.Layout(self)

	self.rightContainer:LayoutBounds("right", "center", self.bg)
		:Offset(-self.paddingHRight, 0)

	return self
end

function OptionsScreenSpinnerRow:OnFocusNudge(direction)
	if direction == "down"
		or direction == "up"
	then
		return OptionsScreenSpinnerRow._base.OnFocusNudge(self, direction)
	end
	-- else: Skip nudge when adjusting value.
	return self
end

function OptionsScreenSpinnerRow:OnFocusChange(hasFocus)
	OptionsScreenSpinnerRow._base.OnFocusChange(self, hasFocus)

	if not self.valueText then
		return self
	end

	if hasFocus then
		self.valueText:TintTo(nil, self.titleSelectedColor, 0.2, easing.inOutQuad)
		self.pagination:TintTo(nil, self.titleSelectedColor, 0.2, easing.inOutQuad)
		self.valueLeftArrow:SetImageNormalColour(self.arrowSelectedColor)
			:SetImageFocusColour(self.arrowFocusColor)
		self.valueRightArrow:SetImageNormalColour(self.arrowSelectedColor)
			:SetImageFocusColour(self.arrowFocusColor)
	else
		self.valueText:TintTo(nil, self.titleUnselectedColor, 0.4, easing.inOutQuad)
		self.pagination:TintTo(nil, self.paginationUnselectedColor, 0.4, easing.inOutQuad)
		self.subtitle:TintTo(nil, self.subtitleUnselectedColor, 0.4, easing.inOutQuad)
		self.valueLeftArrow:SetImageNormalColour(self.arrowUnselectedColor)
			:SetImageFocusColour(self.arrowUnselectedColor)
		self.valueRightArrow:SetImageNormalColour(self.arrowUnselectedColor)
			:SetImageFocusColour(self.arrowUnselectedColor)
	end

	return self
end

function OptionsScreenSpinnerRow:SetValues(values)
	GLOBAL.assert(type(values[1].data) ~= "boolean", "Use OptionsScreenToggleRow for bools.")
	-- I don't think there's a hard requirement on type, but you probably want
	-- an enum string since settings has support for them.
	GLOBAL.assert(type(values[1].data) == "string" or type(values[1].data) == "number", "Are you storing the right kind of data?")

	OptionsScreenSpinnerRow._base.SetValues(self, values)
	if #self.values > 0 then
		-- TODO(ui): Does changing this to be after _SetValue break things?
		self.pagination:SetCount(#self.values)
	end

	return self
end

-- Updates the spinner to display this value's data
function OptionsScreenSpinnerRow:_SetValue(index)
	self.currentIndex = index
	self.pagination:SetCurrent(self.currentIndex)

	local valueData = self.values[self.currentIndex]

	if valueData then
		if valueData.name then
			self.valueText:SetText(valueData.name)
		end
		if valueData.desc then
			self:SetSubtitle(valueData.desc)
		end
	end

	if self.onValueChangeFn then
		self.onValueChangeFn(valueData.data, self.currentIndex, valueData)
	end

	-- Need to relayout to align pagination.
	self:Layout()
	return self
end

function OptionsScreenSpinnerRow:HidePagination()
	self.pagination:Hide()
	return self
end

function OptionsScreenSpinnerRow:OnArrowRight()
	if self.values then
		self.currentIndex = self.currentIndex + 1
		if self.currentIndex > #self.values then
			self.currentIndex = 1
		end
		self:_SetValue(self.currentIndex)
	end
	return self
end

function OptionsScreenSpinnerRow:OnArrowLeft()
	if self.values then
		self.currentIndex = self.currentIndex - 1
		if self.currentIndex < 1 then
			self.currentIndex = #self.values
		end
		self:_SetValue(self.currentIndex)
	end
	return self
end