local consts = require "consts"
local wezterm = require "wezterm"
local u = require "utils"

local secondary_pane_ids = {}
local act = wezterm.action

return {
  -- tabs
  { key = "t",          mods = "SHIFT|CTRL", action = act.SpawnTab "CurrentPaneDomain" },
  -- panes
  { key = "LeftArrow",  mods = "CTRL|ALT",   action = act.ActivatePaneDirection "Left" },
  { key = "RightArrow", mods = "CTRL|ALT",   action = act.ActivatePaneDirection "Right" },
  { key = "UpArrow",    mods = "CTRL|ALT",   action = act.ActivatePaneDirection "Up" },
  { key = "DownArrow",  mods = "CTRL|ALT",   action = act.ActivatePaneDirection "Down" },
  { key = "d",          mods = "CTRL|SHIFT", action = act.CloseCurrentPane { confirm = true } },
  {
    key = "r",
    mods = "CTRL|SHIFT|ALT",
    action = wezterm.action_callback(function(window, pane)
      local current_tab = pane:tab()
      local current_tab_id = current_tab:tab_id()
      local panes = current_tab:panes_with_info()

      main_pane = panes[1]
      secondary_pane = nil
      u.foreach(panes, function(p, i)
        local pane_id = p.pane:pane_id()
        if pane_id == secondary_pane_ids[current_tab_id] then
          secondary_pane = p
        end
      end)

      -- if secondary_pane doesn't exist yet, make it and register it's id
      if secondary_pane == nil or #panes == 1 then
        pane:split {
          direction = "Right",
          size = 0.4,
        }

        local _panes = current_tab:panes_with_info()
        secondary_pane_ids[current_tab_id] = _panes[#_panes].pane:pane_id()
        -- if main_pane isn't zoomed, activate and zoom it (in order to hide secondary_pane)
      elseif not main_pane.is_zoomed then
        main_pane.pane:activate()
        current_tab:set_zoomed(true)
        -- if main_pane is zoomed, quit zoom mode and activate secondary_pane
      elseif main_pane.is_zoomed then
        current_tab:set_zoomed(false)
        secondary_pane.pane:activate()
      end
    end)
  },
  -- cursor movements
  { key = "LeftArrow",  mods = "SHIFT|CTRL", action = act.SendKey { key = "b", mods = "META", } },
  { key = "RightArrow", mods = "CTRL",       action = act.SendKey { key = "f", mods = "META", } },
  { key = "LeftArrow",  mods = "CTRL",       action = act.SendKey { key = "b", mods = "META", } },
  { key = "i",          mods = "SHIFT|CTRL", action = act.SendKey { key = "e", mods = "CTRL", } },
  -- copy & paste
  { key = "Space",      mods = "CTRL",       action = act.ActivateCopyMode },
  { key = "v",          mods = "CTRL",       action = act.PasteFrom "Clipboard" },
  -- F13 layer key mappings
  {
    key = consts.F13,
    mods = "NONE",
    action = act { EmitEvent = consts.TOGGLE_EVENTS[consts.F13] }
  },
  {
    key = "LeftArrow",
    mods = "NONE",
    action = wezterm.action_callback(function(window, pane)
      if u.get_layer_key_flag(consts.F13) then
        window:perform_action(act { MoveTabRelative = -1 }, pane)
      else
        window:perform_action(act { SendKey = { key = "LeftArrow" } }, pane)
      end
    end)
  },
  {
    key = "RightArrow",
    mods = "NONE",
    action = wezterm.action_callback(function(window, pane)
      if u.get_layer_key_flag(consts.F13) then
        window:perform_action(act { MoveTabRelative = 1 }, pane)
      else
        window:perform_action(act { SendKey = { key = "RightArrow" } }, pane)
      end
    end)
  },
}
