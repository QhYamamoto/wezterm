local consts = require "consts"
local wezterm = require "wezterm"
local u = require "utils"

local config = {}
if wezterm.config_builder then config = wezterm.config_builder() end

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

-- open window in maximum size
local mux = wezterm.mux
wezterm.on("gui-startup", function()
  local _, _, window = mux.spawn_window {}
  window:gui_window():maximize()
end)

-- F13 toggle event handler
wezterm.on(consts.TOGGLE_EVENTS[consts.F13], function(window, _)
  u.toggle_layer_key_flag(consts.F13)
  window:set_config_overrides(u.update_tab_colors(consts.F13))
end)

config.colors = require "colors"
config.keys = require "keys"

return config
