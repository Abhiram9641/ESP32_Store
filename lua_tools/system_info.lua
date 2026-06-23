-- System Info Tool v2.0
-- Displays comprehensive system information on screen
-- Uses: sys.*, wifi.*, disp.*

function run()
    sys.print("=== System Info ===")

    disp.init()
    local W = disp.width()
    local H = disp.height()

    local BG     = disp.rgb(8, 10, 20)
    local TEXT   = disp.rgb(220, 230, 240)
    local DIM    = disp.rgb(80, 100, 130)
    local GREEN  = disp.rgb(0, 220, 100)
    local YELLOW = disp.rgb(255, 200, 0)
    local ACCENT = disp.rgb(0, 180, 255)
    local PANEL  = disp.rgb(15, 20, 35)

    -- Collect system data
    local heap = sys.free_heap()
    local ms = sys.millis()
    local sec = math.floor(ms / 1000)
    local mins = math.floor(sec / 60)
    local hrs = math.floor(mins / 60)
    local ip = wifi.get_ip()
    local rssi = wifi.get_rssi()

    -- Draw full screen
    disp.fill(0, 0, W, H, BG)

    -- Header
    disp.fill(0, 0, W, 16, disp.rgb(12, 16, 30))
    disp.text(4, 4, "SYSTEM INFO", ACCENT)

    local y = 20

    -- Platform
    disp.fill(2, y - 1, W - 4, 12, PANEL)
    disp.text(4, y, "Platform", DIM)
    disp.text(60, y, "ESP32-S3", TEXT)
    y = y + 14

    -- Uptime
    disp.fill(2, y - 1, W - 4, 12, PANEL)
    disp.text(4, y, "Uptime", DIM)
    disp.text(60, y, string.format("%dh %dm %ds", hrs, mins % 60, sec % 60), TEXT)
    y = y + 14

    -- Free Heap
    local heap_kb = math.floor(heap / 1024)
    local heap_color = heap_kb > 200 and GREEN or (heap_kb > 100 and YELLOW or disp.rgb(255, 80, 80))
    disp.fill(2, y - 1, W - 4, 12, PANEL)
    disp.text(4, y, "Heap", DIM)
    disp.text(60, y, string.format("%d KB", heap_kb), heap_color)
    y = y + 14

    -- Heap bar
    local bar_w = W - 8
    local bar_h = 3
    local heap_pct = math.min(heap_kb / 800, 1.0)
    disp.fill(4, y, bar_w, bar_h, disp.rgb(30, 30, 40))
    disp.fill(4, y, math.floor(bar_w * heap_pct), bar_h, heap_color)
    y = y + 7

    -- Separator
    disp.line(4, y, W - 4, y, DIM)
    y = y + 4

    -- WiFi Status
    disp.fill(2, y - 1, W - 4, 12, PANEL)
    disp.text(4, y, "WiFi", DIM)
    if ip and ip ~= "0.0.0.0" then
        disp.text(60, y, "Connected", GREEN)
    else
        disp.text(60, y, "Disconnected", disp.rgb(255, 80, 80))
    end
    y = y + 14

    -- IP Address
    disp.fill(2, y - 1, W - 4, 12, PANEL)
    disp.text(4, y, "IP", DIM)
    disp.text(60, y, ip or "N/A", TEXT)
    y = y + 14

    -- RSSI
    if ip and ip ~= "0.0.0.0" then
        local sig_color = GREEN
        if rssi < -70 then sig_color = disp.rgb(255, 80, 80)
        elseif rssi < -50 then sig_color = YELLOW end

        disp.fill(2, y - 1, W - 4, 12, PANEL)
        disp.text(4, y, "Signal", DIM)
        disp.text(60, y, string.format("%d dBm", rssi), sig_color)

        -- Signal bar
        local bar_pct = math.min((-rssi - 20) / 70, 1.0)
        if bar_pct < 0 then bar_pct = 0 end
        local sig_bar_w = math.floor((W - 70) * bar_pct)
        disp.fill(60, y + 10, sig_bar_w, 3, sig_color)
        y = y + 16
    else
        y = y + 4
    end

    -- Separator
    disp.line(4, y, W - 4, y, DIM)
    y = y + 4

    -- Lua Engine
    disp.fill(2, y - 1, W - 4, 12, PANEL)
    disp.text(4, y, "Lua", DIM)
    disp.text(60, y, "5.4.8 Active", GREEN)

    -- Footer
    disp.fill(0, H - 14, W, 14, disp.rgb(12, 16, 30))
    disp.text(4, H - 11, "System Info", DIM)

    sys.print(string.format("Heap: %d KB | Uptime: %dh%dm%ds", heap_kb, hrs, mins % 60, sec % 60))
    if ip and ip ~= "0.0.0.0" then
        sys.print(string.format("WiFi: %s | RSSI: %d dBm", ip, rssi))
    else
        sys.print("WiFi: Disconnected")
    end
    sys.print("System info complete.")
    sys.delay(10000)
end

run()
