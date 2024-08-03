local _C = require "consts"
local _wt = require "wezterm"
local _u = require "utils"

local config = {}
if _wt.config_builder then config = _wt.config_builder() end

config.colors = require "colors"
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

config.font = _wt.font("0xProto Nerd Font Mono", { weight = "Regular", stretch = "Normal", style = "Normal" })

-- open window in maximum size
local mux = _wt.mux
_wt.on("gui-startup", function()
  local _, _, window = mux.spawn_window {}
  window:gui_window():maximize()
end)

-- register F13 as toggleable layer key
_u.register_toggleable_layer_key(_C.F13)

-- import key settigs after registering layer keys
config.keys = require "keys"

return config
