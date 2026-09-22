-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- Trader Workstation (TWS): ensure modal dialogs, reconnect prompts, and popups float and stay focused
o.window(".*(install4j-jclient-LoginFrame|Trader Workstation).*", {
  tag = "-default-opacity",
  opacity = "1 1",
  float = true,
  center = true,
  stay_focused = true,
})

-- Allow the main TWS window to tile normally while dialogs remain floating
o.window({
  class = ".*(install4j-jclient-LoginFrame|Trader Workstation).*",
  title = "^(Trader Workstation|IBKR Trader Workstation).*$",
}, {
  tile = true,
  stay_focused = false,
})


-- sudo askpass popup (~/.local/bin/sudo-askpass): small centered floating terminal
o.window({ class = "^dev\\.enric\\.sudo-askpass$" }, {
  float = true,
  center = true,
  size = "600 160",
  stay_focused = true,
  tag = "-default-opacity",
  opacity = "1 1",
})
