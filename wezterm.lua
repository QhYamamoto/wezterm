local wezterm = require 'wezterm'

if wezterm.config_builder then
  config = wezterm.config_builder()
end


config.window_decorations = "RESIZE"
config.default_prog = { 'wsl', '~' }
config.window_background_opacity = 0.75
config.window_close_confirmation = 'NeverPrompt'
config.skip_close_confirmation_for_processes_named = {
  'bash',
  'sh',
  'zsh',
  'fish',
  'tmux',
  'nu',
  'cmd.exe',
  'pwsh.exe',
  'powershell.exe',
  'wsl.exe',
  'wslhost.exe',
  'conhost.exe',
}

config.font = wezterm.font('0xProto Nerd Font Mono', { weight = 'Regular', stretch = 'Normal', style = 'Normal' })

local mux = wezterm.mux
wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window {}
  window:gui_window():maximize()
end)

local act = wezterm.action
config.keys = {
  -- new tab
  { key = 't',          mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
  -- cursor movements
  { key = 'LeftArrow',  mods = 'SHIFT|CTRL', action = act.SendKey { key = 'b', mods = 'META', } },
  { key = 'RightArrow', mods = 'CTRL',       action = act.SendKey { key = 'f', mods = 'META', } },
  { key = 'LeftArrow',  mods = 'CTRL',       action = act.SendKey { key = 'b', mods = 'META', } },
  { key = 'i',          mods = 'SHIFT|CTRL', action = act.SendKey { key = 'e', mods = 'CTRL', } },
  { key = 'Space',      mods = 'CTRL',       action = act.ActivateCopyMode },
  -- copy & paste
  { key = 'v',          mods = 'CTRL',       action = act.PasteFrom 'Clipboard' },
}

return config
