local wezterm = require("wezterm")

return {
	-- font = wezterm.font("JetBrains Mono Nerd Font"),
  font = wezterm.font('JetBrains Mono'),
	font_size = 10,
	cursor_blink_rate = 800,
  enable_tab_bar = false,
  window_background_opacity = 0.4,
  window_decorations = 'RESIZE',
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  }
	-- cursor_thickness = "2px",
	-- line_height = "2.5px",
	-- underline_position = "1px",
	-- underline_thickness = "2px",
}
