-- GPIO Monitor Tool v2.0
-- Monitors GPIO pin states in real-time on screen
-- Uses: gpio.*, disp.*, sys.*

function run()
    sys.print("=== GPIO Monitor ===")

    disp.init()
    local W = disp.width()
    local H = disp.height()

    local BG     = disp.rgb(8, 10, 20)
    local TEXT   = disp.rgb(220, 230, 240)
    local DIM    = disp.rgb(80, 100, 130)
    local GREEN  = disp.rgb(0, 220, 100)
    local RED    = disp.rgb(255, 80, 80)
    local ACCENT = disp.rgb(0, 180, 255)
    local PANEL  = disp.rgb(15, 20, 35)

    -- Monitor common GPIO pins
    local pins = {3, 4, 5, 15, 16, 17, 18}
    local pin_names = {
        [3] = "UP", [4] = "BL", [5] = "GPIO5",
        [15] = "RIGHT", [16] = "SELECT", [17] = "DOWN", [18] = "LEFT"
    }

    local header_h = 18
    local item_h = 14
    local footer_y = H - 14

    for frame = 1, 20 do
        -- Header
        disp.fill(0, 0, W, header_h, disp.rgb(12, 16, 30))
        disp.text(4, 4, "GPIO MONITOR", ACCENT)

        -- Content area
        disp.fill(0, header_h, W, footer_y - header_h, BG)

        -- Draw each pin
        for i, pin in ipairs(pins) do
            local y = header_h + (i - 1) * item_h
            local val = gpio.read(pin)
            local label = pin_names[pin] or string.format("P%d", pin)
            local is_high = (val == 1)
            local state_color = is_high and GREEN or RED
            local state_text = is_high and "HIGH" or "LOW"

            -- Pin background
            disp.fill(2, y, W - 4, item_h - 2, PANEL)

            -- Pin name
            disp.text(4, y + 3, label, TEXT)

            -- State dot (visual indicator)
            local dot_x = 60
            disp.fill(dot_x, y + 4, 6, 6, state_color)

            -- State text
            disp.text(70, y + 3, state_text, state_color)

            -- Pin number
            disp.text(W - 20, y + 3, string.format("%d", pin), DIM)
        end

        -- Footer
        disp.fill(0, footer_y, W, H - footer_y, disp.rgb(12, 16, 30))
        disp.text(4, footer_y + 3, string.format("Sample: %d/20", frame), DIM)

        -- Activity indicator (blinking dot)
        if frame % 2 == 0 then
            disp.fill(W - 10, footer_y + 5, 4, 4, GREEN)
        else
            disp.fill(W - 10, footer_y + 5, 4, 4, DIM)
        end

        sys.delay(500)
    end

    sys.print("Monitor complete.")
end

run()
