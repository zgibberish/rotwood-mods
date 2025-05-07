local ConfirmDialog = require "screens.dialogs.confirmdialog"
local Image = require "widgets.image"
local Panel = require "widgets.panel"
local Screen = require "widgets.screen"
local ScrollPanel = require "widgets.scrollpanel"
local TabGroup = require "widgets.tabgroup"
local Text = require "widgets.text"
local Widget = require "widgets.widget"
local easing = require "util.easing"
local fmodtable = require "defs.sound.fmodtable"
local lume = require "util.lume"
local templates = require "widgets.ftf.templates"

modimport("widgets/optionsscreencategorytitle")
modimport("widgets/optionsscreenbaserow")
modimport("widgets/optionsscreenspinnerrow")
modimport("widgets/modentry_imagebutton")

local mod_entry_button_width = 200

------------------------------------------------------------------------------------------
--- Modified optionsscreen designed to only show 1 page (the config page of the selected mod)
--- most unnecessary functionalities have been removed
----
ModConfiguratorScreen = Class(Screen, function(self, modname)
	Screen._ctor(self, "ModConfiguratorScreen")

	self.modname = modname

	local mod_is_client = false
    if GLOBAL.KnownModIndex.savedata.known_mods[modname] and GLOBAL.KnownModIndex.savedata.known_mods[modname] and GLOBAL.KnownModIndex.savedata.known_mods[modname].modinfo and GLOBAL.KnownModIndex.savedata.known_mods[modname].modinfo.client_only_mod and GLOBAL.KnownModIndex.savedata.known_mods[modname].modinfo.client_only_mod == true then
        mod_is_client = true
    end
    self.configuration_options = GLOBAL.KnownModIndex:LoadModConfigurationOptions(modname, mod_is_client)
	self.configuration_options_backup = GLOBAL.deepcopy(self.configuration_options)

	--sound
	self:SetAudioCategory(Screen.AudioCategory.s.Fullscreen)
	self:SetAudioExitOverride(nil)

	-- Setup sizings
	self.rowWidth = 2520
	self.rowRightColumnWidth = 880
	self.rowSpacing = 120

	-- Add background
	self.bg = self:AddChild(templates.BackgroundImage("images/ui_ftf_options/optionsscreen_bg.tex"))

	-- Add nav header
	self.navbarWidth = GLOBAL.RES_X - 160
	self.navbarHeight = 180
	local icon_size = GLOBAL.FONTSIZE.OPTIONS_SCREEN_TAB * 1.1

	self.navbar = self:AddChild(Widget("navbar"))
		:LayoutBounds("center", "top", self.bg)
		:Offset(0, -150)
	self.navbar.bg = self.navbar:AddChild(Panel("images/ui_ftf_options/topbar_bg.tex"))
		:SetNineSliceCoords(40, 0, 560, 170)
		:SetSize(self.navbarWidth, self.navbarHeight)
		:SetMultColor(GLOBAL.HexToRGB(0x0F0C0AFF))
	self.navbar.tabs = self.navbar:AddChild(TabGroup())
		:SetTheme_LightTransparentOnDark()
		:SetTabOnClick(function(tab_btn) end) -- even though this deosnt do anything on click, without this line, the default tab (the only one) isnt highlighted
		:SetTabSpacing(120)
		:SetFontSize(GLOBAL.FONTSIZE.OPTIONS_SCREEN_TAB)

	-- Add navbar options
	self.tabs = {}
	local mod_fancyname = GLOBAL.KnownModIndex:GetModFancyName(modname)
	self.tabs.main = self.navbar.tabs:AddIconTextTab("images/ui_ftf_dialog/ic_options.tex", mod_fancyname)
	self.tabs.main:SetGainFocusSound(fmodtable.Event.hover)

	local tab_count = lume.count(self.tabs)
	self.navbar.tabs
		:SetTabSize(nil, icon_size)
		:SetNavFocusable(false) -- rely on CONTROL_MAP
		:LayoutChildrenInGrid(tab_count + 2, 90)
		:LayoutBounds("center", "center", self.navbar.bg)

	-- Add navbar back button
	self.backButton = self.navbar:AddChild(templates.BackButton())
		:SetNormalScale(0.8)
		:SetFocusScale(0.85)
		:SetSecondary()
		:LayoutBounds("left", "center", self.navbar.bg)
		:Offset(40, 0)
		:SetOnClick(function() self:OnClickClose() end)

	-- Add navbar save button
	self.saveButton = self.navbar:AddChild(templates.AcceptButton(GLOBAL.STRINGS.UI.OPTIONSSCREEN.SAVE_BUTTON))
		:SetNormalScale(0.8)
		:SetFocusScale(0.85)
		:SetPrimary()
		:LayoutBounds("right", "center", self.navbar.bg)
		:Offset(-50, 0)
		:SetOnClick(function() self:OnClickSave() end)
		:Hide()
		:SetControlUpSound(fmodtable.Event.ui_input_up_confirm_save)

	-- Add a confirmation label to be displayed when the options are saved
	self.saveConfirmationLabel = self.navbar:AddChild(Text(GLOBAL.FONTFACE.DEFAULT, GLOBAL.FONTSIZE.OPTIONS_SCREEN_TAB))
		:SetGlyphColor(GLOBAL.UICOLORS.LIGHT_TEXT)
		:SetAutoSize(600)
		:SetText(GLOBAL.STRINGS.UI.OPTIONSSCREEN.SAVED_OPTIONS_LABEL)
		:LayoutBounds("center", "center", self.saveButton)
		:SetMultColorAlpha(0)
	self.labelX, self.labelY = self.saveConfirmationLabel:GetPosition()

	-- Add scrolling panel below the navbar
	self.scrollSideMargin = 60
	self.scrollTopMargin = 220
	self.scroll = self:AddChild(ScrollPanel())
		:SetSize(GLOBAL.RES_X - self.scrollSideMargin * 2, GLOBAL.RES_Y - self.scrollTopMargin)
		:SetVirtualMargin(200)
		:SetVirtualBottomMargin(1000)
		:LayoutBounds("center", "bottom", self.bg)
	self.scrollContents = self.scroll:AddScrollChild(Widget())

	-- Add tab-specific views
	self.pages = {}
	self.pages.main = self.scrollContents:AddChild(Widget("Page Main (mod configs)"))
	-- Fill up all the pages with content!
	self:_BuildMainPage()
	self.tabs.main.page = self.pages.main

	self.scroll:RefreshView()

	dbassert(not self:IsDirty(), "Shouldn't be dirty before making changes. Are we clamping? (Should migrate save data in gamesettings.)")

	-- Add a gradient fading out the options at the bottom of the screen
	self.bottomGradientFade = self:AddChild(Image("images/ui_ftf_options/bottom_gradient.tex"))
		:SetSize(GLOBAL.RES_X, 600)
		:LayoutBounds("center", "bottom", self.bg)
	-- Move the gradient into the scroll panel, so I can place the scroll bar on top
	self.bottomGradientFade:Reparent(self.scroll)
	self.scroll.scroll_bar:SendToFront()

	-- Position navbar in front of the scroll panel
	self.navbar:SendToFront()

	self.default_focus = self.pages.main.default_focus or self.backButton
	self.default_focus:SetFocus()
end)

ModConfiguratorScreen.CONTROL_MAP =
{
	{
		control = GLOBAL.Controls.Digital.MENU_SCREEN_ADVANCE,
		hint = function(self, left, right)
			table.insert(right, loc.format(LOC"UI.CONTROLS.ACCEPT", GLOBAL.Controls.Digital.MENU_SCREEN_ADVANCE))
		end,
		fn = function(self)
			self:OnClickClose()
			GLOBAL.TheFrontEnd:GetSound():PlaySound(fmodtable.Event.ui_simulate_click)
			return true
		end,
	},
	{
		control = GLOBAL.Controls.Digital.CANCEL,
		hint = function(self, left, right)
			table.insert(right, loc.format(LOC"UI.CONTROLS.CANCEL", GLOBAL.Controls.Digital.CANCEL))
		end,
		fn = function(self)
			self:OnClickClose()
			GLOBAL.TheFrontEnd:GetSound():PlaySound(fmodtable.Event.ui_simulate_click)
			return true
		end,
	},
}

function ModConfiguratorScreen:_BuildMainPage()
	local function ModConfigSpinnerRow(setting, setting_index)
		local function _indexOf_options(array, value)
			for i,v in ipairs(array) do
				if v.data == value then
					return i
				end
			end
			return nil
		end
		
		local setting_selected = setting.saved or setting.default
		local spinner_selected_index  = _indexOf_options(setting.options, setting_selected) or 1

		local spinner_values = {}
		for _,option in ipairs(setting.options) do
			table.insert(spinner_values, {
				name = option.description,
				data = option.data
			})
		end

		local opt = Widget("Mod Config Row Container")
		opt.main = opt:AddChild(OptionsScreenSpinnerRow(self.rowWidth - mod_entry_button_width - 10, self.rowRightColumnWidth))
            :SetText(setting.label, setting.hover)
            :SetValues(spinner_values)
            :_SetValue(spinner_selected_index)
            :SetOnValueChangeFn(function(data)
				self.configuration_options[setting_index].saved = data
				self:MakeDirty()
            end)
		opt.reset_btn = opt:AddChild(ModEntryImageButton("images/ui_ftf_icons/restart.tex", mod_entry_button_width, opt.main.height))
			:SetImageOffset(4, 4)
			:SetOnClickFn(function()
				self.configuration_options[setting_index].saved = nil
				opt.main:_SetValue(setting.default)
				self:MakeDirty()
			end)

		opt
			:LayoutChildrenInRow(10)
			:Offset(-mod_entry_button_width/2, 0) -- for some reason spinner rows with side buttons have to be offset like this to make them look aligned like normal rows

		return opt
	end

	local function _LayoutModConfigRows()
		self.pages.main.mod_config_rows_container:RemoveAllChildren()

		for setting_index,setting in ipairs(self.configuration_options) do
			if #setting.options > 1 then
				local spinner_row = ModConfigSpinnerRow(setting, setting_index)
				self.pages.main.mod_config_rows_container:AddChild(spinner_row)
			else
				self.pages.main.mod_config_rows_container:AddChild(OptionsScreenCategoryTitle(self.rowWidth, setting.label))
			end
		end

		self.pages.main.mod_config_rows_container:LayoutChildrenInColumn(self.rowSpacing * 0.5)
	end

	-- add "reset all to default values" row
	local reset_row = self.pages.main:AddChild(OptionsScreenBaseRow(self.rowWidth, 0))
            :SetText(
                "<p img='images/ui_ftf_icons/restart.tex' color=0 scale=1> Reset All",
                "Click here to reset all config optoins to their default values (your changes won't get saved until you press Save)."
            )
            :SetOnClickFn(function()
                for setting_index,setting in ipairs(self.configuration_options) do
					setting.saved = nil
				end
				_LayoutModConfigRows()
				self:MakeDirty()
            end)

	self.pages.main.mod_config_rows_container = self.pages.main:AddChild(Widget("Mod Config Rows Container"))
	_LayoutModConfigRows()

	self.pages.main:LayoutChildrenInColumn(self.rowSpacing * 0.5)

	self.pages.main.default_focus = reset_row

	return self
end

--- Called when an option was edited by the player
function ModConfiguratorScreen:MakeDirty()
	-- Check if something actually changed compared to the stored settings
	if self:IsDirty() then
		-- Show the save button
		self.saveButton:Show()
	else
		-- Hide the save button
		self.saveButton:Hide()
	end
end

function ModConfiguratorScreen:IsDirty()
	local matches_saved = GLOBAL.deepcompare(self.configuration_options_backup, self.configuration_options)
	return not matches_saved
end

function ModConfiguratorScreen:_SaveChanges()
	-- placeholder: save mod configs and update self.configuration_options to match the saved data
	GLOBAL.KnownModIndex:SaveConfigurationOptions(function() end, self.modname, self.configuration_options, self.mod_is_client)
	self.configuration_options_backup = GLOBAL.deepcopy(self.configuration_options)
	self:MakeDirty() -- update dirty status
	return false
end

function ModConfiguratorScreen:OnClickClose()
	local ExitScreen = function(success)
		self:_AnimateOut() -- will pop our dialog
	end

	local function CreateConfirm(title, subtitle, text, confirm_yes, confirm_no)
		return ConfirmDialog(
			self:GetOwningPlayer(),
			self.backButton,
			true,
			title,
			subtitle,
			text
		)
			:SetYesButtonText(confirm_yes)
			:SetNoButtonText(confirm_no)
			:SetArrowUp()
			:SetArrowXOffset(20) -- extra right shift looks more centred
			:SetAnchorOffset(305, 0)
	end

	if self:IsDirty() then
		-- Show confirmation to save the changes or reject them
		local dialog = CreateConfirm(
			GLOBAL.STRINGS.UI.OPTIONSSCREEN.CONFIRM_TITLE,
			GLOBAL.STRINGS.UI.OPTIONSSCREEN.CONFIRM_SUBTITLE,
			GLOBAL.STRINGS.UI.OPTIONSSCREEN.CONFIRM_TEXT,
			GLOBAL.STRINGS.UI.OPTIONSSCREEN.CONFIRM_OK,
			GLOBAL.STRINGS.UI.OPTIONSSCREEN.CONFIRM_NO)

		-- Set its callback
		dialog:SetOnDoneFn(function(confirm_save)
			if confirm_save then
				self:_SaveChanges()
			end
			self:_AnimateOut()
			GLOBAL.TheFrontEnd:PopScreen(self)
		end)

		-- Show the popup
		GLOBAL.TheFrontEnd:PushScreen(dialog)

		-- And animate it in!
		dialog:AnimateIn()
	else
		self:Close() --go back
	end
end

function ModConfiguratorScreen:OnClickSave()
	if self:IsDirty() then
		self:_SaveChanges()
		-- Animate confirmation label and button
		self.saveConfirmationLabel:RunUpdater(GLOBAL.Updater.Series({

			-- Fade button out
			GLOBAL.Updater.Ease(function(v) self.saveButton:SetMultColorAlpha(v) end, 1, 0, 0.2, easing.inOutQuad),
			GLOBAL.Updater.Do(function()
				self.saveButton:Hide()
					:SetMultColorAlpha(1)
			end),

			-- Animate in label
			GLOBAL.Updater.Parallel({
				GLOBAL.Updater.Ease(function(v) self.saveConfirmationLabel:SetMultColorAlpha(v) end, 0, 1, 0.3, easing.inOutQuad),
				GLOBAL.Updater.Ease(function(v) self.saveConfirmationLabel:SetPosition(self.labelX, v) end, self.labelY - 10, self.labelY, 0.8, easing.outQuad),
			}),

			GLOBAL.Updater.Wait(0.8),

			-- Animate label out
			GLOBAL.Updater.Parallel({
				GLOBAL.Updater.Ease(function(v) self.saveConfirmationLabel:SetMultColorAlpha(v) end, 1, 0, 0.8, easing.inOutQuad),
				GLOBAL.Updater.Ease(function(v) self.saveConfirmationLabel:SetPosition(self.labelX, v) end, self.labelY, self.labelY + 10, 0.8, easing.inQuad),
			}),

		}))
	end
end

function ModConfiguratorScreen:Close()
	--fallback code to catch errant loop
	if GLOBAL.TheFrontEnd:GetSound():IsPlayingSound("options_volume_sound") then
		GLOBAL.TheFrontEnd:GetSound():KillSound("options_volume_sound")
	end

	self:_AnimateOut()
end

function ModConfiguratorScreen:OnBecomeActive()
	ModConfiguratorScreen._base.OnBecomeActive(self)
	-- Hide the topfade, it'll obscure the pause menu if paused during fade. Fade-out will re-enable it
	GLOBAL.TheFrontEnd:HideTopFade()

	if not self.animatedIn then
		-- Select first tab
		self.tabs.main:Click()
		self:_AnimateIn()
		self.animatedIn = true
	end
end

function ModConfiguratorScreen:_AnimateIn()
	self:_AnimateInFromDirection(GLOBAL.Vector2.unit_y)
end

function ModConfiguratorScreen:_AnimateOut()
	self:_AnimateOutToDirection(GLOBAL.Vector2.unit_y)
end
