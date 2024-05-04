local kassert = require "util.kassert"
local fmodtable = require "defs.sound.fmodtable"

modimport("widgets/modentry_imagebutton")

ModEntryImageButtonToggle = Class(ModEntryImageButton, function(self, texture, width, height)
    ModEntryImageButton._ctor(self, texture, width, height)    

    self.IMAGE_COLOR_DISABLED = GLOBAL.UICOLORS.BACKGROUND_LIGHT
    self.IMAGE_COLOR_ENABLED = GLOBAL.UICOLORS.LIGHT_TEXT

	local onclick = function() self:OnClick() end
	self:SetOnClick(onclick)
end)

function ModEntryImageButtonToggle:SetValues(values)
	kassert.typeof("boolean", values[1].data)
    self.values = values or {}
    return self
end

function ModEntryImageButtonToggle:_SetValue(index)
	self.currentIndex = index

    local valueData = self.values[self.currentIndex]

    if self.currentIndex == 1 then
        -- on
        self.imageSelectedColor = self.IMAGE_COLOR_ENABLED
        self.imageUnselectedColor = self.IMAGE_COLOR_ENABLED
        self.image:SetMultColor(self.IMAGE_COLOR_ENABLED)
    else
        -- off
        self.imageSelectedColor = self.IMAGE_COLOR_DISABLED
        self.imageUnselectedColor = self.IMAGE_COLOR_DISABLED
        self.image:SetMultColor(self.IMAGE_COLOR_DISABLED)
    end

	if self.onValueChangeFn then
		self.onValueChangeFn(valueData.data, self.currentIndex, valueData)
	end

	return self
end

function ModEntryImageButtonToggle:SetOnValueChangeFn(fn)
    self.onValueChangeFn = fn
    return self
end

function ModEntryImageButtonToggle:OnClick()
    if self.values then
		self.currentIndex = self.currentIndex + 1
		if self.currentIndex > #self.values then
			self.currentIndex = 1
		end

		if self.currentIndex == 1 then
            -- on
			GLOBAL.TheFrontEnd:GetSound():PlaySound(fmodtable.Event.ui_toggle_on)
		else
            -- off
			GLOBAL.TheFrontEnd:GetSound():PlaySound(fmodtable.Event.ui_toggle_off)
		end

		self:_SetValue(self.currentIndex)
	end
    return self
end
