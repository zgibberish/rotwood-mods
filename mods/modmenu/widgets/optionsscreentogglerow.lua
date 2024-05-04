local CheckBox = require "widgets.checkbox"
local easing = require "util.easing"
local kassert = require "util.kassert"

modimport("widgets/optionsscreenbaserow")

------------------------------------------------------------------------------------------
--- Displays a row with an on/off toggle option
----
OptionsScreenToggleRow = Class(OptionsScreenBaseRow, function(self, width, rightColumnWidth)
	OptionsScreenBaseRow._ctor(self, width, rightColumnWidth)
	self:SetName("OptionsScreenToggleRow")

	-- Set up sizings
	self.rightPadding = 40 -- How much spacing to leave on the right, so right-most elements look aligned

	-- Set up colors
	self.arrowSelectedColor = self.titleSelectedColor
	self.arrowFocusColor = self.subtitleSelectedColor
	self.arrowUnselectedColor = self.titleUnselectedColor
	self.paginationUnselectedColor = GLOBAL.HexToRGB(0xB6965500)

	self:SetControlDownSound(nil)
	self:SetControlUpSound(nil)

	-- Build right column contents
	local palette = {
		primary_active = self.titleSelectedColor,
		primary_inactive = self.titleUnselectedColor,
	}
	self.toggleButton = self.rightContainer:AddChild(CheckBox(palette))
		:IgnoreInput(true)

	-- Default values
	self.currentIndex = 0

	self:OnFocusChange(false)
	local onclick = function() self:OnClick() end
	self:SetOnClick(onclick)
	self.toggleButton:SetOnClick(onclick)
end)

OptionsScreenToggleRow.CONTROL_MAP = {
}

function OptionsScreenToggleRow:Layout()
	-- Layout right column elements
	self.toggleButton:LayoutBounds("right", "center", self.rightColumnHitbox)
	self.toggleButton:Layout()

	OptionsScreenToggleRow._base.Layout(self)

	self.rightContainer:Offset(-self.rightPadding, 0)

	return self
end

function OptionsScreenToggleRow:OnFocusChange(hasFocus)
	OptionsScreenToggleRow._base.OnFocusChange(self, hasFocus)

	if not self.toggleButton then
		return self
	end

	if hasFocus then
		self.toggleButton:TintTo(nil, self.titleSelectedColor, 0.2, easing.outQuad)
	else
		self.toggleButton:TintTo(nil, self.titleUnselectedColor, 0.4, easing.outQuad)
	end

	self.toggleButton:OnFocusChange(hasFocus)

	return self
end

function OptionsScreenToggleRow:SetValues(values)
	kassert.typeof("boolean", values[1].data)
	return OptionsScreenToggleRow._base.SetValues(self, values)
end

-- Updates the spinner to display this value's data
function OptionsScreenToggleRow:_SetValue(index)
	self.currentIndex = index

	local valueData = self.values[self.currentIndex]

	if valueData then
		if valueData.desc then
			self:SetSubtitle(valueData.desc)
		end
	end

	self.toggleButton:SetValue(self.currentIndex == 1)
	self:Layout()

	if self.onValueChangeFn then
		self.onValueChangeFn(valueData.data, self.currentIndex, valueData)
	end

	return self
end

function OptionsScreenToggleRow:OnClick()
	if self.values then
		self.currentIndex = self.currentIndex + 1
		if self.currentIndex > #self.values then
			self.currentIndex = 1
		end

		if self.currentIndex == 1 then
			GLOBAL.TheFrontEnd:GetSound():PlaySound(self.toggleButton.toggleon_sound)
		else
			GLOBAL.TheFrontEnd:GetSound():PlaySound(self.toggleButton.toggleoff_sound)
		end

		self:_SetValue(self.currentIndex)
	end
	return self
end