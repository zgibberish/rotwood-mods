local fmodtable = require "defs.sound.fmodtable"
local lume = require "util.lume"

modimport("widgets/vtabgroup")

local function ModifyTabBar(self)
	-- make the navbar background taller to account for the taller tab buttons
	self.navbar.bg
		:SetNineSliceCoords(40, 0, 560, 170)
		:SetSize(self.navbarWidth, self.navbarHeight+30)
	-- replace the default tab group
	self.navbar.tabs:Remove()
	self.navbar.tabs = self.navbar:AddChild(VTabGroup())
		:SetTheme_LightTransparentOnDark()
		:SetFontSize(60)
		:SetTabSpacing(120)
	
	-- re adding all the tabs and connecting the pages to their tab buttons
	-- this is very stupid and if the game adds a new default tab, this mod
	-- will break, please find better solutions in the future :(
	self.tabs = {}
	self.tabs.gameplay = self.navbar.tabs:AddIconTextTab("images/ui_ftf_options/ic_gameplay.tex", GLOBAL.STRINGS.UI.OPTIONSSCREEN.NAVBAR_GAMEPLAY)
		:SetGainFocusSound(fmodtable.Event.hover)
	self.tabs.graphics = self.navbar.tabs:AddIconTextTab("images/ui_ftf_options/ic_graphics.tex", GLOBAL.STRINGS.UI.OPTIONSSCREEN.NAVBAR_GRAPHICS)
		:SetGainFocusSound(fmodtable.Event.hover)
	self.tabs.audio    = self.navbar.tabs:AddIconTextTab("images/ui_ftf_options/ic_audio.tex", GLOBAL.STRINGS.UI.OPTIONSSCREEN.NAVBAR_AUDIO)
		:SetGainFocusSound(fmodtable.Event.hover)
	self.tabs.controls = self.navbar.tabs:AddIconTextTab("images/ui_ftf_options/ic_controls.tex", GLOBAL.STRINGS.UI.OPTIONSSCREEN.NAVBAR_CONTROLS)
		:SetGainFocusSound(fmodtable.Event.hover)
	self.tabs.other    = self.navbar.tabs:AddIconTextTab("images/ui_ftf_options/ic_other.tex", GLOBAL.STRINGS.UI.OPTIONSSCREEN.NAVBAR_OTHER)
		:SetGainFocusSound(fmodtable.Event.hover)
	self.tabs.gameplay.page = self.pages.gameplay
	self.tabs.graphics.page = self.pages.graphics
	self.tabs.audio.page = self.pages.audio
	self.tabs.controls.page = self.pages.controls
	self.tabs.other.page = self.pages.other

	local icon_size = GLOBAL.FONTSIZE.OPTIONS_SCREEN_TAB * 1.1
	local tab_count_v = lume.count(self.tabs)
	self.navbar.tabs
		:SetTabSize(nil, icon_size)
		:SetTabOnClick(function(tab_btn) self:OnChangeTab(tab_btn) end)
		:SetNavFocusable(false) -- rely on CONTROL_MAP
		:LayoutChildrenInGrid(tab_count_v + 2, 90)
		:LayoutBounds("center", "center", self.navbar.bg)
		:AddCycleIcons()
		:SetOffset(0, -10)
end

AddClassPostConstruct("screens/optionsscreen", ModifyTabBar)
