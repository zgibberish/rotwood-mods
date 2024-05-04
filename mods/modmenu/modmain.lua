local fmodtable = require "defs.sound.fmodtable"
local lume = require "util.lume"
local Widget = require "widgets.widget"

modimport("widgets/optionsscreencategorytitle")
modimport("widgets/optionsscreenbaserow")
modimport("widgets/optionsscreentogglerow")
modimport("widgets/optionsscreenspinnerrow")
modimport("widgets/modentry_imagebutton")
modimport("widgets/modentry_imagebutton_toggle")
modimport("screens/modconfiguratorscreen")

local mod_entry_button_width = 200

local sorting_comparators = {
    function(a, b) -- 1: alphabetical
        return GLOBAL.KnownModIndex:GetModFancyName(a) < GLOBAL.KnownModIndex:GetModFancyName(b)
    end,
    function(a, b) -- 1: reversed alphabetical
        return GLOBAL.KnownModIndex:GetModFancyName(a) > GLOBAL.KnownModIndex:GetModFancyName(b)
    end,
    function(a, b) -- 3: author
        local author_a = "unknown"
        if GLOBAL.KnownModIndex and GLOBAL.KnownModIndex.GetModInfo and GLOBAL.KnownModIndex:GetModInfo(a) and GLOBAL.KnownModIndex:GetModInfo(a)["author"] then
            author_a = GLOBAL.KnownModIndex:GetModInfo(a)["author"]
        end
        local author_b = "unknown"
        if GLOBAL.KnownModIndex and GLOBAL.KnownModIndex.GetModInfo and GLOBAL.KnownModIndex:GetModInfo(b) and GLOBAL.KnownModIndex:GetModInfo(b)["author"] then
            author_b = GLOBAL.KnownModIndex:GetModInfo(b)["author"]
        end
        return author_a < author_b
    end,
    function(a, b) -- 4: reversed author
        local author_a = "unknown"
        if GLOBAL.KnownModIndex and GLOBAL.KnownModIndex.GetModInfo and GLOBAL.KnownModIndex:GetModInfo(a) and GLOBAL.KnownModIndex:GetModInfo(a)["author"] then
            author_a = GLOBAL.KnownModIndex:GetModInfo(a)["author"]
        end
        local author_b = "unknown"
        if GLOBAL.KnownModIndex and GLOBAL.KnownModIndex.GetModInfo and GLOBAL.KnownModIndex:GetModInfo(b) and GLOBAL.KnownModIndex:GetModInfo(b)["author"] then
            author_b = GLOBAL.KnownModIndex:GetModInfo(b)["author"]
        end
        return author_a > author_b
    end,
    function(a, b) -- 5: enabled first
        local enabled_a = GLOBAL.KnownModIndex.savedata.known_mods[a].enabled
        local enabled_b = GLOBAL.KnownModIndex.savedata.known_mods[b].enabled
        if enabled_a and not enabled_b then
            return true
        end
        return false
    end,
    function(a, b) -- 6: disabled first
        local enabled_a = GLOBAL.KnownModIndex.savedata.known_mods[a].enabled
        local enabled_b = GLOBAL.KnownModIndex.savedata.known_mods[b].enabled
        if enabled_b and not enabled_a then
            return true
        end
        return false
    end,
    function(a, b) -- 7: favorited first
        local favorited_a = GLOBAL.Profile:IsModFavorited(a)
        local favorited_b = GLOBAL.Profile:IsModFavorited(b)
        if favorited_a and not favorited_b then
            return true
        end
        return false
    end,
}
-- see table above for details about sorting methods
local default_sorting_method = 1
local selected_sorting_method = default_sorting_method

local function OptionsScreen_AddModsTab(self)
    if self.navbar ~= nil and self.navbar.tabs ~= nil and self.tabs ~= nil and self.scrollContents ~= nil then
        self.tabs.mods = self.navbar.tabs:AddIconTextTab("images/icons_ftf/stat_luck.tex", "Mods")
        self.tabs.mods:SetGainFocusSound(fmodtable.Event.hover)

        local function _LayoutModEntries()
            self.pages.mods.mod_entries:RemoveAllChildren()

            -- add mod entries
            local function _AddModEntry(modname)
                local mod_fancyname = GLOBAL.KnownModIndex:GetModFancyName(modname)
                local mod_description = "No description"
                local mod_author = "unknown"
                local mod_version = "unknown"
                local mod_enabled = false
                if GLOBAL.KnownModIndex:GetModInfo(modname) and GLOBAL.KnownModIndex:GetModInfo(modname).description then
                    mod_description = GLOBAL.KnownModIndex:GetModInfo(modname).description
                end
                if GLOBAL.KnownModIndex:GetModInfo(modname) and GLOBAL.KnownModIndex:GetModInfo(modname).author then
                    mod_author = GLOBAL.KnownModIndex:GetModInfo(modname).author
                end
                if GLOBAL.KnownModIndex:GetModInfo(modname) and GLOBAL.KnownModIndex:GetModInfo(modname).version then
                    mod_version = GLOBAL.KnownModIndex:GetModInfo(modname).version
                end
                if GLOBAL.KnownModIndex and GLOBAL.KnownModIndex.savedata and GLOBAL.KnownModIndex.savedata.known_mods and GLOBAL.KnownModIndex.savedata.known_mods[modname] and GLOBAL.KnownModIndex.savedata.known_mods[modname].enabled then
                    mod_enabled = true
                end
                local entry_desc = mod_description.."\n<i>Author: "..mod_author.."\nVersion: "..mod_version.."\nDirectory: "..modname.."</i>"
                local mod_is_favorited = GLOBAL.Profile:IsModFavorited(modname)
                local mod_has_configurations = GLOBAL.KnownModIndex:HasModConfigurationOptions(modname)
                
                local entry = self.pages.mods.mod_entries:AddChild(Widget("Mod Entry Row"))
                entry.entry_main = entry:AddChild(OptionsScreenToggleRow(self.rowWidth - mod_entry_button_width - 10))
                    :SetText(mod_fancyname)
                    :SetValues({
                        { desc = entry_desc, data = true },
                        { desc = entry_desc, data = false }
                    })
                    :_SetValue(mod_enabled and 1 or 2)
                    :SetOnValueChangeFn(function(data)
                        if GLOBAL.KnownModIndex and GLOBAL.KnownModIndex.savedata and GLOBAL.KnownModIndex.savedata.known_mods and GLOBAL.KnownModIndex.savedata.known_mods[modname] and GLOBAL.KnownModIndex.savedata.known_mods[modname].enabled ~= nil then
                            if data then 
                                GLOBAL.KnownModIndex:Enable(modname)
                            else
                                GLOBAL.KnownModIndex:Disable(modname)
                            end
                        end
                    end)

                entry.sidebuttons_container = entry:AddChild(Widget("Mod Entry Side Buttons Container"))
                -- offset the icons inside the mod row's side buttons
                if mod_has_configurations then
                    -- favorite button
                    entry.sidebuttons_container:AddChild(ModEntryImageButtonToggle("images/icons_ftf/stat_health.tex", mod_entry_button_width, (entry.entry_main.height/2 - 10)))
                        :SetImageOffset(4, 4)
                        :SetValues({
                            {data = true},
                            {data = false}
                        })
                        :_SetValue(mod_is_favorited and 1 or 2)
                        :OnFocusChange(false) -- to help the button updates its image color after setting its values manually
                        :SetOnValueChangeFn(function(data)
                            GLOBAL.Profile:SetModFavorited(modname, data)
                            GLOBAL.Profile.dirty = true
                            GLOBAL.Profile:Save()

                            if selected_sorting_method == 7 then
                                _LayoutModEntries()
                            end
                        end)
                    -- mod configs button
                    entry.sidebuttons_container:AddChild(ModEntryImageButton("images/ui_ftf_dialog/ic_options.tex", mod_entry_button_width, (entry.entry_main.height/2 - 10)))
                        :SetImageOffset(4, 4)
                        :SetOnClickFn(function()
                            local configurator_screen = ModConfiguratorScreen(modname)
                            GLOBAL.TheFrontEnd:PushScreen(configurator_screen)
                        end)

                    entry.sidebuttons_container:LayoutChildrenInColumn(10)
                else
                    -- favorite button
                    entry.sidebuttons_container:AddChild(ModEntryImageButtonToggle("images/icons_ftf/stat_health.tex", mod_entry_button_width, entry.entry_main.height))
                        :SetImageOffset(4, 4)
                        :SetValues({
                            {data = true},
                            {data = false}
                        })
                        :_SetValue(mod_is_favorited and 1 or 2)
                        :OnFocusChange(false) -- to help the button updates its image color after setting its values manually
                        :SetOnValueChangeFn(function(data)
                            GLOBAL.Profile:SetModFavorited(modname, data)
                            GLOBAL.Profile.dirty = true
                            GLOBAL.Profile:Save()

                            if selected_sorting_method == 7 then
                                _LayoutModEntries()
                            end
                        end)
                end

                entry:LayoutChildrenInRow(10)
            end

            self.pages.mods.mod_entries:AddChild(OptionsScreenCategoryTitle(self.rowWidth, "Client Mods"))
            -- mods are shown sorted by their fancy name (the name defined in modinfo), if there is no fancy name, the moddir name is used
            local list_client = GLOBAL.KnownModIndex:GetClientModNames()
            if selected_sorting_method == 7 then
                -- the user has chose to view favorites first, but we will also
                -- sort the list alphabetically first, then push the favorites on
                -- top after
                table.sort(list_client, sorting_comparators[1])
                table.sort(list_client, sorting_comparators[7])
            else
                table.sort(list_client, sorting_comparators[selected_sorting_method])
            end
            for _,modname in ipairs(list_client) do
                _AddModEntry(modname)
            end
            self.pages.mods.mod_entries:AddChild(OptionsScreenCategoryTitle(self.rowWidth, "Server Mods"))
            local list_server = GLOBAL.KnownModIndex:GetServerModNames()
            if selected_sorting_method == 7 then
                -- the user has chose to view favorites first, but we will also
                -- sort the list alphabetically first, then push the favorites on
                -- top after
                table.sort(list_server, sorting_comparators[1])
                table.sort(list_server, sorting_comparators[7])
            else
                table.sort(list_server, sorting_comparators[selected_sorting_method])
            end
            for _,modname in ipairs(list_server) do
                _AddModEntry(modname)
            end

            self.pages.mods.mod_entries:LayoutChildrenInColumn(self.rowSpacing * 0.5)
            self.pages.mods:LayoutChildrenInColumn(self.rowSpacing * 0.5)
        end

        -- refresh the nav bar again
	    local icon_size = GLOBAL.FONTSIZE.OPTIONS_SCREEN_TAB * 1.1
        local tab_count = lume.count(self.tabs)
        self.navbar.tabs
            :SetTabSize(nil, icon_size)
            :LayoutChildrenInGrid(tab_count + 2, 90)
            :LayoutBounds("center", "center", self.navbar.bg) -- re center the tab bar after adding the Mods tab
            :Layout() -- fix the cycle icons on both sides
        
        self.pages.mods = self.scrollContents:AddChild(Widget("Page Mods"))
        self.tabs.mods.page = self.pages.mods

        -- reload entry (click to reload the game)
        local reload_row = self.pages.mods:AddChild(OptionsScreenBaseRow(self.rowWidth, 0))
            :SetText(
                "Confirm options and Reload",
                "Click here to save mod config changes and reload the game.\n<i>ANY UNSAVED IN-GAME PROGRESS WILL BE LOST!</i>"
            )
            :SetOnClickFn(function()
                GLOBAL.KnownModIndex:Save()
                GLOBAL:c_reset()
            end)
        reload_row.bgSelectedColor = GLOBAL.UICOLORS.ACTION_PRIMARY
        reload_row.bgUnselectedColor = GLOBAL.HexToRGB(0x61e49e00)

        -- sort method spinner option (sort by.../.../...)
        self.pages.mods:AddChild(OptionsScreenSpinnerRow(self.rowWidth, self.rowRightColumnWidth))
            :SetText("Sort by", "Sort the mod list by this method.")
            :SetValues({
                {name = "Name", data = 1},
                {name = "Name Descending", data = 2},
                {name = "Author", data = 3},
                {name = "Author Descending", data = 4},
                {name = "Enabled First", data = 5},
                {name = "Disabled First", data = 6},
                {name = "Favorites First", data = 7},
            })
            :_SetValue(selected_sorting_method)
            :SetOnValueChangeFn(function(data)
                selected_sorting_method = data
                _LayoutModEntries()
            end)

        self.pages.mods.mod_entries = self.pages.mods:AddChild(Widget("Mod Entries"))
        _LayoutModEntries()
    end
end

AddClassPostConstruct("screens/optionsscreen", OptionsScreen_AddModsTab)