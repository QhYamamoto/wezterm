local _C = require "consts"
local _wt = require "wezterm"
local _u = require "utils"

local secondary_pane_ids = {}
local act = _wt.action

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
    action = _wt.action_callback(function(_, pane)
      local current_tab = pane:tab()
      local current_tab_id = current_tab:tab_id()
      local panes = current_tab:panes_with_info()

      local primary_pane = panes[1]
      local secondary_pane = nil
      _u.foreach(panes, function(p, _)
        local pane_id = p.pane:pane_id()
        if pane_id == secondary_pane_ids[current_tab_id] then
          secondary_pane = p
        end
      end)

      -- if secondary_pane doesn't exist yet, create that and register pane_id
      if secondary_pane == nil or #panes == 1 then
        pane:split {
          direction = "Right",
          size = 0.5,
        }

        local _panes = current_tab:panes_with_info()
        secondary_pane_ids[current_tab_id] = _panes[#_panes].pane:pane_id()
        -- if primary_pane isn't zoomed, activate and zoom it (in order to hide secondary_pane)
      elseif not primary_pane.is_zoomed then
        primary_pane.pane:activate()
        current_tab:set_zoomed(true)
        -- if primary_pane is zoomed, quit zoom mode and activate secondary_pane
      elseif primary_pane.is_zoomed then
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
    key = _C.F13,
    mods = "NONE",
    action = act { EmitEvent = _u.get_layer_key_toggle_event(_C.F13) }
  },
  {
    key = "LeftArrow",
    mods = "NONE",
    action = _wt.action_callback(function(window, pane)
      if _u.get_layer_key_flag(_C.F13) then
        window:perform_action(act { MoveTabRelative = -1 }, pane)
      else
        window:perform_action(act { SendKey = { key = "LeftArrow" } }, pane)
      end
    end)
  },
  {
    key = "RightArrow",
    mods = "NONE",
    action = _wt.action_callback(function(window, pane)
      if _u.get_layer_key_flag(_C.F13) then
        window:perform_action(act { MoveTabRelative = 1 }, pane)
      else
        window:perform_action(act { SendKey = { key = "RightArrow" } }, pane)
      end
    end)
  },
}
