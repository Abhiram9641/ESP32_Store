-- WiFi Scanner Tool v2.0
-- Scans nearby WiFi networks and displays results on screen
-- Uses: wifi.*, disp.*, sys.*

function run()
    sys.print("=== WiFi Scanner ===")

    disp.init()
    local W = disp.width()
    local H = disp.height()

    local BG     = disp.rgb(8, 10, 20)
    local TEXT   = disp.rgb(220, 230, 240)
    local DIM    = disp.rgb(80, 100, 130)
    local GREEN  = disp.rgb(0, 220, 100)
    local YELLOW = disp.rgb(255, 200, 0)
    local RED    = disp.rgb(255, 80, 80)
    local ACCENT = disp.rgb(0, 180, 255)

    -- Header
    disp.fill(0, 0, W, 16, disp.rgb(12, 16, 30))
    disp.text(4, 4, "WIFI SCANNER", ACCENT)

    -- Scanning animation
    disp.fill(0, 17, W, H - 17, BG)
    disp.text(10, 40, "Scanning...", DIM)
    sys.delay(300)

    local nets = wifi.scan()

    if not nets or #nets == 0 then
        disp.fill(0, 17, W, H - 17, BG)
        disp.text(10, 40, "No networks found", RED)
        disp.text(10, 56, "Check WiFi is enabled", DIM)
        sys.print("No networks found")
        sys.delay(5000)
        return
    end

    sys.print(string.format("Found %d networks", #nets))

    local total = #nets
    local item_h = 18
    local header_h = 18
    local footer_y = H - 14
    local visible = math.floor((footer_y - header_h) / item_h)
    if visible < 1 then visible = 1 end

    -- Auto-scroll animation: scroll through all results over time
    local max_scroll = total - visible
    if max_scroll < 0 then max_scroll = 0 end

    for frame = 1, 60 do
        -- Calculate scroll position (auto-scroll down then back up)
        local cycle = frame / 60
        local scroll
        if cycle < 0.5 then
            scroll = math.floor(max_scroll * (cycle * 2))
        else
            scroll = math.floor(max_scroll * (1 - (cycle - 0.5) * 2))
        end

        disp.fill(0, header_h, W, footer_y - header_h, BG)

        -- Draw network list
        for i = scroll + 1, math.min(scroll + visible, total) do
            local net = nets[i]
            local y = header_h + (i - scroll - 1) * item_h

            -- SSID
            local ssid = net.ssid or "?"
            if #ssid > 16 then ssid = string.sub(ssid, 1, 16) end
            local enc = net.auth ~= 0 and "Sec" or "Open"

            -- Signal color
            local sig_color = GREEN
            if net.rssi < -70 then sig_color = RED
            elseif net.rssi < -50 then sig_color = YELLOW end

            disp.text(4, y + 2, ssid, TEXT)
            disp.text(W - 28, y + 2, string.format("%d", net.rssi), sig_color)

            -- Channel + encryption
            disp.text(4, y + 10, string.format("Ch%d %s", net.channel, enc), DIM)

            -- Signal bar
            local bar_w = math.floor(20 * math.min((-net.rssi - 20) / 70, 1.0))
            if bar_w < 1 then bar_w = 1 end
            disp.fill(W - 36, y + 11, bar_w, 3, sig_color)
        end

        -- Footer
        disp.fill(0, footer_y, W, H - footer_y, disp.rgb(12, 16, 30))
        disp.text(4, footer_y + 3, string.format("%d networks found", total), DIM)

        -- Scrolling indicator dots
        local dot_x = W - 20
        local dot_page = math.floor(scroll / visible)
        local dot_pages = math.floor(max_scroll / visible) + 1
        for d = 0, math.min(dot_pages - 1, 4) do
            local col = d == dot_page and ACCENT or DIM
            disp.fill(dot_x + d * 4, footer_y + 5, 2, 2, col)
        end

        sys.delay(500)
    end

    sys.print("Scan complete.")
end

run()
