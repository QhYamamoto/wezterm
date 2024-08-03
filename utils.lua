local _C = require "consts"

-- Toggleable layer key flags
local layer_key_flags = {}
layer_key_flags[_C.F13] = false

return {
  foreach = function(table, callback)
    for i, v in ipairs(table) do
      callback(v, i)
    end
  end,
  -- function to update acrive tab color
  update_tab_color_on_layer_key_pressed = function(layer_key_name)
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
  end,
  toggle_layer_key_flag = function(layer_key_name)
    layer_key_flags[layer_key_name] = not layer_key_flags[layer_key_name]
  end,
  get_layer_key_flag = function(layer_key_name)
    return layer_key_flags[layer_key_name]
  end,
}
