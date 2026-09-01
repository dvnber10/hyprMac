-- =====================================================================
-- ~/.config/hypr/hyprland.lua
-- Configuración estilo macOS Tahoe para Hyprland.
-- Basado en tu config autogenerada, con lo necesario agregado/cambiado
-- para: ventanas flotantes por defecto, barra de título estilo Mac
-- (hyprbars con semáforo rojo/amarillo/verde), y el botón verde
-- creando un Escritorio nuevo en pantalla completa (como Spaces).
-- =====================================================================


------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -show drun -theme ~/.config/rofi/launchpad.rasi"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("eww daemon")
    hl.exec_cmd("nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start -ico $HOME/.local/share/icons/WhiteSur-dark/actions/symbolic/view-app-grid-symbolic.svg -c $HOME/.config/nwg-dock-hyprland/dock_launcher.sh -s $HOME/.config/nwg-dock-hyprland/style.css")
    hl.exec_cmd("qs")               -- Quickshell: Centro de Control
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("hyprpm reload")

    -- Forzar modo oscuro WhiteSur en schemas GNOME/GTK
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.cursor-theme 'WhiteSur-cursor'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_THEME", "WhiteSur-cursor")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "WhiteSur-cursor")
hl.env("HYPRCURSOR_SIZE", "24")

-- Forzar modo oscuro WhiteSur en GTK y Qt
hl.env("GTK_THEME", "WhiteSur-dark")
hl.env("GDK_THEME", "WhiteSur-dark")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_STYLE_OVERRIDE", "Breeze")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland:KDE")


-----------------------
---- PLUGINS ----------
-----------------------

-- hyprbars: barra de título compositor-side con botones tipo semáforo.
-- Instálalo antes con:
--   hyprpm add https://github.com/hyprwm/hyprland-plugins
--   hyprpm enable hyprbars

hl.config({
    plugin = {
        hyprbars = {
            bar_height              = 20,
            bar_color                = "rgba(40,40,42,0.75)", -- translúcido, se ve "glass" con el blur global
            bar_blur                 = true,
            col = { text = "rgba(230,230,235,1.0)" },
            bar_title_enabled        = true,
            bar_text_size            = 12,
            bar_text_weight          = "semibold",
            bar_text_font            = "SF Pro Display",
            bar_text_align           = "center",
            bar_buttons_alignment    = "left",   -- macOS: semáforo a la IZQUIERDA
            bar_part_of_window       = true,
            bar_precedence_over_border = true,
            bar_padding              = 10,
            bar_button_padding       = 6,
            icon_on_hover             = true,     -- iconos (x, -, +) solo aparecen al pasar el mouse, como Mac
            inactive_button_color    = "rgba(255,255,255,0.15)",
        },
    },
})

-- Botones, de izquierda a derecha: rojo (cerrar), amarillo (minimizar), verde (fullscreen en Space nuevo)
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(ff5f57)",
    fg_color = "rgb(4d0000)",
    size     = 12,
    icon     = "✕",
    action   = "hyprctl dispatch 'hl.dsp.window.close()'",
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(febc2e)",
    fg_color = "rgb(4d3900)",
    size     = 12,
    icon     = "–",
    action   = "bash ~/.config/hypr/scripts/macos_minimize.sh",
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(28c840)",
    fg_color = "rgb(003d0a)",
    size     = 12,
    icon     = "⤢",
    action   = "bash ~/.config/hypr/scripts/macos_fullscreen.sh",
})


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 12,
        border_size = 1,

        col = {
            active_border   = "rgba(ffffff55)",   -- borde sutil claro, no el gradiente neón por defecto
            inactive_border = "rgba(00000022)",
        },

        resize_on_border = true,   -- macOS permite redimensionar arrastrando el borde
        allow_tearing    = false,

        -- OJO: seguimos usando dwindle como "layout de respaldo" pero
        -- todas las ventanas se abren flotando por la regla de abajo,
        -- así que en la práctica el layout de mosaico casi no se usa
        -- (igual que en macOS, donde todo es flotante por defecto).
        layout = "dwindle",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.96,

        shadow = {
            enabled      = true,
            range        = 18,
            render_power = 3,
            color        = 0x66000000,
        },

        blur = {
            enabled  = true,
            size     = 6,
            passes   = 3,
            vibrancy = 0.18,
        },
    },

    animations = { enabled = true },
})

hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("quick", { type = "bezier", points = { {0.15, 0}, {0.1, 1} } })
hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

-- Animaciones suaves de "fade + scale" al abrir ventanas: se parece
-- mucho más al "genie effect" sutil de macOS que el pop-in por defecto.
hl.animation({ leaf = "windows",    enabled = true, speed = 4.5, spring = "easy" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 3.5, spring = "easy", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.2, bezier = "easeOutQuint", style = "popin 92%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3.0, bezier = "quick" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.2, bezier = "easeInOutCubic", style = "slidefade 15%" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3.0, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",   enabled = true, speed = 3.0, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",  enabled = true, speed = 1.5, bezier = "linear", style = "fade" })

hl.config({
    dwindle = { preserve_split = true },
    master  = { new_status = "master" },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = { natural_scroll = true }, -- macOS: scroll natural por defecto
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" }) -- swipe entre Spaces, como Mac
hl.gesture({ fingers = 4, direction = "down", action = "special", workspace_name = "minimized" })


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- en tu teclado esta es la tecla "Windows"; en Mac sería CMD

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())                          -- CMD+W cierra ventana, como Mac
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))                      -- CMD+Espacio = Spotlight
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/macos_minimize.sh"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("~/.config/hypr/scripts/macos_fullscreen.sh"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("bash ~/.config/eww/scripts/wallpaper_picker.sh"))
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd("hyprctl dispatch exit"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })



hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- *** ESTA es la regla clave para "modo macOS": ***
-- Todas las ventanas abren FLOTANDO por defecto, en vez de mosaico.
hl.window_rule({
    name  = "float-everything-macos-style",
    match = { class = ".*" },
    float = true,
    size = "1164 601",
    move = "192 71",
    rounding = 12,
})


-- Ignora peticiones de "maximizar" nativas de las apps (usamos
-- nuestro propio botón verde para eso, no el comportamiento por defecto)
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Quitar sombras y bordes al control center de Eww para que la transparencia fluya limpia
hl.window_rule({
    name  = "control-center",
    match = { class = "control-center" }, -- O ajusta el class según lo que detecte hyprctl clients
    border_size = 0,
    no_shadow = true,
    opacity = 1.0,
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class = "^$", title = "^$", xwayland = true,
        float = true, fullscreen = false, pin = false,
    },
    no_focus = true,
})

-- Blur/glass para tus paneles (Waybar, Wofi, Quickshell Control Center)
hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0.6 })
hl.layer_rule({ match = { namespace = "wofi" },   blur = true, ignore_alpha = 0.6 })
hl.layer_rule({ match = { namespace = "quickshell:controlcenter" }, blur = true, ignore_alpha = 0.5 })

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})