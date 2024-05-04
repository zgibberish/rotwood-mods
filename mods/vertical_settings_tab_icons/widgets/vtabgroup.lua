local TabGroup = require "widgets.tabgroup"
local Clickable = require "widgets.clickable"
local Image = require "widgets.image"
local Text = require "widgets.text"

VTabGroup = Class(TabGroup, function(self)
    TabGroup._ctor(self, "VTabGroup")
	self.offset_x = 0
	self.offset_y = 0
end)

function VTabGroup:Layout()
	self._base.Layout(self)

	self:Offset(self.offset_x, self.offset_y)

	return self
end

function VTabGroup:SetOffset(x, y)
	if x then
		self.offset_x = x
	end
	if y then
		self.offset_y = y
	end
	self:Layout()

	return self
end

function VTabGroup:AddIconTextTab(icon, text)
	GLOBAL.assert(icon)
	GLOBAL.assert(text)
	local tab = self.tabs_container:AddChild(Clickable())
	tab.icon = tab:AddChild(Image(icon))
		:SetMultColor(GLOBAL.WEBCOLORS.WHITE)

	tab.text = tab:AddChild(Text(GLOBAL.FONTFACE.DEFAULT, self.font_size or 20))
		:SetGlyphColor(GLOBAL.WEBCOLORS.WHITE)
		:SetText(text)

	function tab:RelayoutTab()
		self.text
			:LayoutBounds("below", "center", self.icon)
			:Offset(0, -80)

		return self
	end
	function tab:SetSize(x, y)
		self.icon:SetSize(y, y)
		if x then
			-- Force the text to fill up remaining space. Useful for vertical
			-- alignment, but not so great for horizontal tabs.
			local w = x - y
			self.text:SetSize(w, y)
		end
		return self:RelayoutTab()
	end

	tab:RelayoutTab()

	self:_ApplyFancyTint(tab)
	return self:_HookupTab(tab)
end