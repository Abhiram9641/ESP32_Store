-- I2C Bus Scanner Tool
-- Scans I2C bus and identifies devices by address

function run()
    sys.print("=== I2C Bus Scanner ===")
    sys.print("Scanning I2C bus...")
    sys.delay(200)

    local found = 0
    for addr = 0x03, 0x77 do
        local ok = i2c.probe(addr)
        if ok then
            local name = "Unknown"
            -- Common device names
            if addr == 0x27 or addr == 0x3F then name = "LCD"
            elseif addr == 0x48 or addr == 0x49 then name = "ADC/Temp"
            elseif addr == 0x50 then name = "EEPROM"
            elseif addr == 0x57 then name = "AT24 EEPROM"
            elseif addr == 0x68 then name = "RTC/MPU"
            elseif addr == 0x76 or addr == 0x77 then name = "BME/BMP"
            end
            sys.print(string.format("  0x%02X  (%3d)  %s", addr, addr, name))
            found = found + 1
        end
        sys.delay(5)
    end

    sys.print("")
    if found == 0 then
        sys.print("No I2C devices found")
    else
        sys.print(string.format("Found %d device(s)", found))
    end
end

run()
