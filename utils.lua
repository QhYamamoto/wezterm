local _C = require "consts"
local _wt = require "wezterm"

-- toggleable layer key flags
local layer_key_flags = {}
local function toggle_layer_key_flag(layer_key_name)
  layer_key_flags[layer_key_name] = not layer_key_flags[layer_key_name]
end
local layer_key_toggle_events = {}
-- function to update active tab color when toggleable layer key is pressed
local function update_tab_color_on_layer_key_pressed(layer_key_name)
  local bg_color = _C.COLOR_TAB_BAR_BG_DEFAULT
  if layer_key_flags[layer_key_name] then
    bg_color = _C.COLORS_TAB_BAR_BG_LAYERED[layer_key_name]
  end

  return {
    colors = {
      tab_bar = {
        active_tab = {
          bg_color = bg_color,
          fg_color = _C.COLOR_TAB_BAR_FG_DEFAULT,
        },
      },
    }
  }
end


return {
  foreach = function(table, callback)
    for i, v in ipairs(table) do
      callback(v, i)
    end
  end,
  register_toggleable_layer_key = function(layer_key_name)
    layer_key_flags[layer_key_name] = false
    local toggle_event_name = "toggle-" .. layer_key_name
    layer_key_toggle_events[layer_key_name] = toggle_event_name
    _wt.on(toggle_event_name, function(window)
      toggle_layer_key_flag(layer_key_name)
      window:set_config_overrides(update_tab_color_on_layer_key_pressed(layer_key_name))
    end)
  end,
  get_layer_key_flag = function(layer_key_name)
    return layer_key_flags[layer_key_name]
  end,
  get_layer_key_toggle_event = function(layer_key_name)
    return layer_key_toggle_events[layer_key_name]
  end
}
