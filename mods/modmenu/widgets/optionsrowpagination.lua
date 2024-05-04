local Widget = require "widgets.widget"
local Image = require "widgets.image"

------------------------------------------------------------------------------------------
--- Displays a number of options and the currently selected one
----
OptionsRowPagination = Class(Widget, function(self)
	Widget._ctor(self, "OptionsRowPagination")

	self.dotSize = 12
	self.selectedAlpha = 1
	self.normalAlpha = 0.25

end)

function OptionsRowPagination:SetCount(count)

	-- Remove old dots
	self:RemoveAllChildren()

	-- Add new ones
	for k = 1, count do
		self:AddChild(Image("images/ui_ftf_options/pagination_dot.tex"))
			:SetSize(self.dotSize, self.dotSize)
			:SetMultColorAlpha(self.normalAlpha)
	end

	-- Layout
	self:LayoutChildrenInGrid(100, 2)

	return self
end

function OptionsRowPagination:SetCurrent(current)

	for k, dot in ipairs(self.children) do
		dot:SetMultColorAlpha(k == current and self.selectedAlpha or self.normalAlpha)
	end

	return self
end