local function for_each(table, callback)
  for i, v in ipairs(table) do
    callback(v, i)
  end
end

local wezterm = require "wezterm"

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.window_decorations = "RESIZE"
config.default_prog = { "wsl", "~" }
config.window_background_opacity = 0.75
config.window_close_confirmation = "NeverPrompt"
config.audible_bell = "Disabled"
config.skip_close_confirmation_for_processes_named = {
  "bash",
  "sh",
  "zsh",
  "fish",
  "tmux",
  "nu",
  "cmd.exe",
  "pwsh.exe",
  "powershell.exe",
  "wsl.exe",
  "wslhost.exe",
  "conhost.exe",
}

config.font = wezterm.font("0xProto Nerd Font Mono", { weight = "Regular", stretch = "Normal", style = "Normal" })

local mux = wezterm.mux
wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window {}
  window:gui_window():maximize()
end)

-- Set F13 as toggleable layer key
local is_f13_pressed = false
wezterm.on('toggle-f13', function(window, pane)
  is_f13_pressed = not is_f13_pressed
end)

local secondary_pane_id = nil
local act = wezterm.action
config.keys = {
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
      local panes = current_tab:panes_with_info()

      main_pane = panes[1]
      secondary_pane = nil
      for_each(panes, function(p, i)
        local pane_id = p.pane:pane_id()
        if pane_id == secondary_pane_id then
          secondary_pane = p
        end
      end)

      -- if secondary_pane doesn't exist yet, make it and register it's id
      if secondary_pane == nil then
        pane:split {
          direction = "Right",
          size = 0.4,
        }

        local _panes = current_tab:panes_with_info()
        secondary_pane_id = _panes[#_panes].pane:pane_id()
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
  { key = "F13",        mods = "NONE",       action = act { EmitEvent = "toggle-f13" } },
  {
    key = "LeftArrow",
    mods = "NONE",
    action = wezterm.action_callback(function(window, pane)
      if is_f13_pressed then
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
      if is_f13_pressed then
        window:perform_action(act { MoveTabRelative = 1 }, pane)
      else
        window:perform_action(act { SendKey = { key = "RightArrow" } }, pane)
      end
    end)
  },
}

return config
