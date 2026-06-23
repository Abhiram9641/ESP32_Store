-- LED Patterns Tool v2.0
-- Runs rainbow, breathing, and strobe patterns on NeoPixel with display status
-- Uses: led.*, disp.*, sys.*

-- Helper: HSV to RGB conversion
function hsv_to_rgb(h, s, v)
    h = h / 255.0 * 6.0
    local i = math.floor(h)
    local f = h - i
    local p = v * (1 - s / 255.0)
    local q = v * (1 - s / 255.0 * f)
    local t = v * (1 - s / 255.0 * (1 - f))
    if i == 0 then return v, t, p
    elseif i == 1 then return q, v, p
    elseif i == 2 then return p, v, t
    elseif i == 3 then return p, q, v
    elseif i == 4 then return t, p, v
    else return v, p, q end
end

function run()
    sys.print("=== LED Patterns ===")

    disp.init()
    local W = disp.width()
    local H = disp.height()

    local BG     = disp.rgb(8, 10, 20)
    local TEXT   = disp.rgb(220, 230, 240)
    local DIM    = disp.rgb(80, 100, 130)
    local GREEN  = disp.rgb(0, 220, 100)
    local ACCENT = disp.rgb(0, 180, 255)
    local PANEL  = disp.rgb(15, 20, 35)

    local header_h = 18
    local footer_y = H - 14

    -- Helper: update display with pattern status
    local function draw_status(pattern_name, progress, r, g, b, info)
        disp.fill(0, header_h, W, footer_y - header_h, BG)

        -- Pattern name
        disp.fill(2, header_h + 2, W - 4, 14, PANEL)
        disp.text(4, header_h + 5, pattern_name, ACCENT)

        -- Current LED color preview (large box)
        local box_size = 30
        local box_x = (W - box_size) / 2
        local box_y = header_h + 22
        disp.fill(box_x, box_y, box_size, box_size, disp.rgb(r, g, b))
        disp.rect(box_x, box_y, box_size, box_size, DIM)

        -- RGB values
        disp.text(4, box_y + box_size + 6, string.format("R:%3d G:%3d B:%3d", r, g, b), TEXT)

        -- Progress bar
        local bar_y = box_y + box_size + 20
        local bar_w = W - 8
        local bar_h = 4
        disp.fill(4, bar_y, bar_w, bar_h, disp.rgb(30, 30, 40))
        disp.fill(4, bar_y, math.floor(bar_w * progress), bar_h, ACCENT)

        -- Info text
        if info then
            disp.text(4, bar_y + 8, info, DIM)
        end

        -- Footer
        disp.fill(0, footer_y, W, H - footer_y, disp.rgb(12, 16, 30))
        disp.text(4, footer_y + 3, "LED Patterns", DIM)
    end

    -- Pattern 1: Rainbow cycle
    local total_rainbow = 3 * 51  -- 3 cycles x 51 steps
    local rainbow_step = 0
    for cycle = 1, 3 do
        for hue = 0, 255, 5 do
            local r, g, b = hsv_to_rgb(hue, 255, 128)
            led.set_rgb(r, g, b)
            rainbow_step = rainbow_step + 1
            draw_status("RAINBOW", rainbow_step / total_rainbow, r, g, b,
                string.format("Cycle %d/3", cycle))
            sys.delay(20)
        end
    end

    -- Pattern 2: Breathing
    local total_breathe = 40
    for i = 1, total_breathe do
        local brightness = math.floor(128 + 127 * math.sin(i * 0.15))
        local r = brightness
        local g = 0
        local b = math.floor(brightness / 2)
        led.set_rgb(r, g, b)
        draw_status("BREATHING", i / total_breathe, r, g, b,
            string.format("Intensity: %d%%", math.floor(brightness / 2.55)))
        sys.delay(50)
    end

    -- Pattern 3: Strobe
    local total_strobe = 10
    for i = 1, total_strobe do
        led.set_rgb(255, 255, 255)
        draw_status("STROBE", i / total_strobe, 255, 255, 255,
            string.format("Flash %d/%d", i, total_strobe))
        sys.delay(50)
        led.set_rgb(0, 0, 0)
        draw_status("STROBE", i / total_strobe, 0, 0, 0, "")
        sys.delay(50)
    end

    -- Cleanup
    led.set_rgb(0, 0, 0)

    -- Final screen
    disp.fill(0, header_h, W, footer_y - header_h, BG)
    disp.text(4, header_h + 20, "All patterns", TEXT)
    disp.text(4, header_h + 34, "complete!", GREEN)

    -- Show final color (off)
    local box_size = 20
    local box_x = (W - box_size) / 2
    local box_y = header_h + 52
    disp.fill(box_x, box_y, box_size, box_size, disp.rgb(0, 0, 0))
    disp.rect(box_x, box_y, box_size, box_size, DIM)

    sys.print("LED patterns complete.")
    sys.delay(5000)
end

run()
