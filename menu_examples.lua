-- menu_examples.lua
-- Demonstrates enhanced menu features: immediate execution, monitor support, touch/mouse

local utils = require('modules/utils')

----------------------------------------------------------------------------
-- EXAMPLE 1: Immediate Execution (No Enter Key)
----------------------------------------------------------------------------
function example1_immediateExecution()
    print("Example 1: Immediate Execution")
    print("-------------------------------\n")
    print("Select an item - it executes immediately!")
    print("No need to press Enter.\n")
    
    local counter = 0
    
    utils.actionMenu({
        title = "Immediate Execution Demo",
        immediateExecute = true,  -- KEY FEATURE: Execute on select
        items = {
            {
                name = "Increment Counter",
                action = function()
                    counter = counter + 1
                    print("Counter increased to " .. counter)
                end
            },
            {
                name = "Decrement Counter",
                action = function()
                    counter = counter - 1
                    print("Counter decreased to " .. counter)
                end
            },
            {
                name = "Reset Counter",
                action = function()
                    counter = 0
                    print("Counter reset!")
                end
            },
            {
                name = "Show Current Value",
                action = function()
                    print("\n=== Current State ===")
                    print("Counter: " .. counter)
                    print("====================\n")
                end
            },
            {
                name = "Exit",
                action = function()
                    return false  -- Exit menu
                end
            }
        },
        allowQuit = true
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 2: Monitor Menu with Touch Support
----------------------------------------------------------------------------
function example2_monitorMenu()
    print("Example 2: Monitor Menu with Touch")
    print("-----------------------------------\n")
    
    -- Try to find a monitor
    local monitor = peripheral.find("monitor")
    
    if not monitor then
        print("No monitor found! Please attach a monitor to continue.")
        print("Press any key to skip this example...")
        os.pullEvent("key")
        return
    end
    
    print("Monitor found! The menu will display on the monitor.")
    print("Touch the monitor to interact with the menu.\n")
    print("Press any key here to exit the monitor menu...")
    
    -- Run menu on monitor in parallel with terminal listener
    parallel.waitForAny(
        function()
            utils.actionMenu({
                title = "Monitor Control Panel",
                display = monitor,      -- KEY FEATURE: Display on monitor
                enableTouch = true,     -- KEY FEATURE: Touch support
                immediateExecute = true,
                items = {
                    {
                        name = "Light Mode",
                        action = function()
                            monitor.setBackgroundColor(colors.white)
                            monitor.setTextColor(colors.black)
                            monitor.clear()
                            monitor.setCursorPos(1, 1)
                            monitor.write("Light mode activated!")
                            sleep(1)
                        end
                    },
                    {
                        name = "Dark Mode",
                        action = function()
                            monitor.setBackgroundColor(colors.black)
                            monitor.setTextColor(colors.white)
                            monitor.clear()
                            monitor.setCursorPos(1, 1)
                            monitor.write("Dark mode activated!")
                            sleep(1)
                        end
                    },
                    {
                        name = "Show Time",
                        action = function()
                            monitor.clear()
                            monitor.setCursorPos(1, 1)
                            monitor.write("Current time: " .. textutils.formatTime(os.time(), false))
                            sleep(2)
                        end
                    },
                    {
                        name = "Clear Monitor",
                        action = function()
                            monitor.setBackgroundColor(colors.black)
                            monitor.clear()
                            sleep(0.5)
                        end
                    },
                    {
                        name = "Exit",
                        action = function()
                            return false
                        end
                    }
                },
                titleColor = colors.purple,
                selectedColor = colors.pink
            })
        end,
        function()
            os.pullEvent("key")
        end
    )
    
    monitor.clear()
    monitor.setCursorPos(1, 1)
    print("\nMonitor menu closed.")
end

----------------------------------------------------------------------------
-- EXAMPLE 3: Terminal with Mouse Click Support
----------------------------------------------------------------------------
function example3_mouseClickMenu()
    print("Example 3: Mouse Click Support")
    print("-------------------------------\n")
    print("You can click on items with your mouse!")
    print("Or use arrow keys - both work!\n")
    
    utils.actionMenu({
        title = "Color Picker (Click or Keys)",
        enableMouse = true,  -- KEY FEATURE: Mouse click support
        immediateExecute = true,
        items = {
            {
                name = "Red",
                action = function()
                    term.setBackgroundColor(colors.red)
                    term.clear()
                    term.setCursorPos(1, 1)
                    term.setTextColor(colors.white)
                    print("Selected: RED")
                    sleep(1)
                    term.setBackgroundColor(colors.black)
                end
            },
            {
                name = "Green",
                action = function()
                    term.setBackgroundColor(colors.green)
                    term.clear()
                    term.setCursorPos(1, 1)
                    term.setTextColor(colors.white)
                    print("Selected: GREEN")
                    sleep(1)
                    term.setBackgroundColor(colors.black)
                end
            },
            {
                name = "Blue",
                action = function()
                    term.setBackgroundColor(colors.blue)
                    term.clear()
                    term.setCursorPos(1, 1)
                    term.setTextColor(colors.white)
                    print("Selected: BLUE")
                    sleep(1)
                    term.setBackgroundColor(colors.black)
                end
            },
            {
                name = "Yellow",
                action = function()
                    term.setBackgroundColor(colors.yellow)
                    term.clear()
                    term.setCursorPos(1, 1)
                    term.setTextColor(colors.black)
                    print("Selected: YELLOW")
                    sleep(1)
                    term.setBackgroundColor(colors.black)
                    term.setTextColor(colors.white)
                end
            },
            {
                name = "Exit",
                action = function()
                    return false  -- Exit menu
                end
            }
        },
        titleColor = colors.cyan,
        selectedColor = colors.lightBlue
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 4: Interactive Dashboard
----------------------------------------------------------------------------
function example4_interactiveDashboard()
    print("Example 4: Interactive Dashboard")
    print("---------------------------------\n")
    
    local stats = {
        energy = 5000,
        items = 124,
        activeDevices = 3
    }
    
    utils.actionMenu({
        title = "Control Dashboard",
        immediateExecute = true,
        enableMouse = true,
        items = {
            {
                name = "View Energy: " .. stats.energy .. " RF",
                action = function()
                    print("Energy Status: " .. stats.energy .. " RF")
                    print("Capacity: 10000 RF")
                    print("Usage: " .. string.format("%.1f%%", (stats.energy / 10000) * 100))
                end
            },
            {
                name = "View Inventory: " .. stats.items .. " items",
                action = function()
                    print("Total Items: " .. stats.items)
                    print("Storage Slots: 256")
                    print("Free Slots: " .. (256 - stats.items))
                end
            },
            {
                name = "Device Status: " .. stats.activeDevices .. " active",
                action = function()
                    print("Active Devices: " .. stats.activeDevices)
                    print("Connected Peripherals:")
                    local periphs = peripheral.getNames()
                    for _, p in ipairs(periphs) do
                        print("- " .. p .. " (" .. peripheral.getType(p) .. ")")
                    end
                end
            },
            {
                name = "Refresh Stats",
                action = function()
                    -- Simulate stats update
                    stats.energy = math.random(3000, 8000)
                    stats.items = math.random(80, 200)
                    stats.activeDevices = #peripheral.getNames()
                    print("Stats refreshed!")
                end
            },
            {
                name = "Exit",
                action = function()
                    return false
                end
            }
        }
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 5: Multi-Monitor Setup
----------------------------------------------------------------------------
function example5_multiMonitor()
    print("Example 5: Multi-Monitor Setup")
    print("-------------------------------\n")
    
    local monitors = {peripheral.find("monitor")}
    
    if #monitors == 0 then
        print("No monitors found! Please attach at least one monitor.")
        print("Press any key to skip this example...")
        os.pullEvent("key")
        return
    end
    
    print("Found " .. #monitors .. " monitor(s)")
    print("Select a monitor to test:\n")
    
    local monitorItems = {}
    for i, mon in ipairs(monitors) do
        table.insert(monitorItems, {
            name = "Monitor " .. i .. " (" .. peripheral.getName(mon) .. ")",
            action = function()
                return mon
            end
        })
    end
    
    local selectedMonitor = utils.quickMenu("Choose Monitor", monitorItems)
    
    if not selectedMonitor then return end
    
    print("\nRunning test menu on selected monitor...")
    print("Press any key here to exit...")
    
    parallel.waitForAny(
        function()
            utils.actionMenu({
                title = "Monitor Test Menu",
                display = selectedMonitor,
                enableTouch = true,
                immediateExecute = true,
                items = {
                    {
                        name = "Rainbow Test",
                        action = function()
                            local w, h = selectedMonitor.getSize()
                            for y = 1, h do
                                selectedMonitor.setCursorPos(1, y)
                                selectedMonitor.setBackgroundColor(2^((y-1) % 16))
                                selectedMonitor.write(string.rep(" ", w))
                            end
                            sleep(2)
                            selectedMonitor.setBackgroundColor(colors.black)
                        end
                    },
                    {
                        name = "Show Monitor Info",
                        action = function()
                            local w, h = selectedMonitor.getSize()
                            selectedMonitor.clear()
                            selectedMonitor.setCursorPos(1, 1)
                            selectedMonitor.write("Monitor: " .. peripheral.getName(selectedMonitor))
                            selectedMonitor.setCursorPos(1, 2)
                            selectedMonitor.write("Size: " .. w .. "x" .. h)
                            sleep(2)
                        end
                    },
                    {
                        name = "Clear Screen",
                        action = function()
                            selectedMonitor.setBackgroundColor(colors.black)
                            selectedMonitor.clear()
                        end
                    },
                    {
                        name = "Exit",
                        action = function()
                            return false
                        end
                    }
                }
            })
        end,
        function()
            os.pullEvent("key")
        end
    )
    
    selectedMonitor.clear()
end

----------------------------------------------------------------------------
-- EXAMPLE 6: Settings Panel (Traditional vs Immediate)
----------------------------------------------------------------------------
function example6_comparisonDemo()
    print("Example 6: Traditional vs Immediate Execution")
    print("----------------------------------------------\n")
    
    local modeNames = {
        "Traditional (Select then Enter)",
        "Immediate (Select to Execute)"
    }
    
    local mode = utils.quickMenu("Choose Mode", modeNames)
    
    if not mode then return end
    
    local settings = {
        volume = 50,
        brightness = 75,
        notifications = true
    }
    
    local items = {
        {
            name = "Volume: " .. settings.volume .. "%",
            action = function(item)
                settings.volume = (settings.volume + 10) % 110
                item.name = "Volume: " .. settings.volume .. "%"
                print("Volume set to " .. settings.volume .. "%")
            end
        },
        {
            name = "Brightness: " .. settings.brightness .. "%",
            action = function(item)
                settings.brightness = (settings.brightness + 25) % 125
                item.name = "Brightness: " .. settings.brightness .. "%"
                print("Brightness set to " .. settings.brightness .. "%")
            end
        },
        {
            name = "Notifications: " .. (settings.notifications and "ON" or "OFF"),
            action = function(item)
                settings.notifications = not settings.notifications
                item.name = "Notifications: " .. (settings.notifications and "ON" or "OFF")
                print("Notifications " .. (settings.notifications and "enabled" or "disabled"))
            end
        },
        {
            name = "Exit",
            action = function()
                return false
            end
        }
    }
    
    local menuConfig = {
        title = mode == 1 and "Settings (Traditional)" or "Settings (Immediate)",
        immediateExecute = (mode == 2),
        enableMouse = true,
        items = items
    }
    
    if mode == 1 then
        menuConfig.waitAfterAction = true
    end
    
    utils.actionMenu(menuConfig)
end

----------------------------------------------------------------------------
-- EXAMPLE 7: Real-time System Monitor
----------------------------------------------------------------------------
function example7_realtimeMonitor()
    print("Example 7: Real-time System Monitor")
    print("------------------------------------\n")
    
    utils.actionMenu({
        title = "System Monitor",
        immediateExecute = true,
        enableMouse = true,
        items = {
            {
                name = "Check Fuel Level",
                action = function()
                    if turtle then
                        local fuel = turtle.getFuelLevel()
                        print("Fuel: " .. (fuel == "unlimited" and "Unlimited" or fuel))
                    else
                        print("Fuel: N/A (not a turtle)")
                    end
                end
            },
            {
                name = "Check Time",
                action = function()
                    print("Time: " .. textutils.formatTime(os.time(), false))
                    print("Day: " .. os.day())
                end
            },
            {
                name = "Check Disk Space",
                action = function()
                    local free = fs.getFreeSpace("/")
                    print("Free space: " .. math.floor(free / 1024) .. " KB")
                end
            },
            {
                name = "List Peripherals",
                action = function()
                    local periphs = peripheral.getNames()
                    print("Connected peripherals:")
                    for _, p in ipairs(periphs) do
                        print("- " .. p .. " (" .. peripheral.getType(p) .. ")")
                    end
                end
            },
            {
                name = "Refresh All",
                action = function()
                    print("=== System Status ===")
                    print("Time: " .. textutils.formatTime(os.time(), false))
                    print("Day: " .. os.day())
                    print("Free Space: " .. math.floor(fs.getFreeSpace("/") / 1024) .. " KB")
                    if turtle then
                        print("Fuel: " .. turtle.getFuelLevel())
                    end
                    print("====================")
                    sleep(2)
                end
            },
            {
                name = "Exit",
                action = function()
                    return false
                end
            }
        },
        titleColor = colors.green,
        selectedColor = colors.lime
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 8: Submenu Navigation
----------------------------------------------------------------------------
function example8_submenus()
    print("Example 8: Submenu Navigation")
    print("------------------------------\n")
    
    utils.actionMenu({
        title = "Main Menu",
        enableMouse = true,
        items = {
            {
                name = "File Operations",
                submenu = {
                    title = "File Menu",
                    items = {
                        {
                            name = "List Files",
                            action = function()
                                local files = fs.list("/")
                                print("Files in root:")
                                for _, f in ipairs(files) do
                                    print("- " .. f)
                                end
                            end
                        },
                        {
                            name = "Show Disk Space",
                            action = function()
                                print("Free: " .. math.floor(fs.getFreeSpace("/") / 1024) .. " KB")
                            end
                        }
                    }
                }
            },
            {
                name = "System Info",
                submenu = {
                    title = "System Menu",
                    items = {
                        {
                            name = "Computer ID",
                            action = function()
                                print("ID: " .. os.getComputerID())
                            end
                        },
                        {
                            name = "Computer Label",
                            action = function()
                                print("Label: " .. (os.getComputerLabel() or "None"))
                            end
                        }
                    }
                }
            },
            {
                name = "Exit",
                action = function()
                    return false
                end
            }
        }
    })
end

----------------------------------------------------------------------------
-- RUN EXAMPLES
----------------------------------------------------------------------------
term.clear()
term.setCursorPos(1, 1)

print("===================================")
print("  ENHANCED MENU SYSTEM EXAMPLES")
print("===================================\n")

local examples = {
    {name = "Immediate Execution", func = example1_immediateExecution},
    {name = "Monitor Menu (Touch)", func = example2_monitorMenu},
    {name = "Mouse Click Support", func = example3_mouseClickMenu},
    {name = "Interactive Dashboard", func = example4_interactiveDashboard},
    {name = "Multi-Monitor Setup", func = example5_multiMonitor},
    {name = "Traditional vs Immediate", func = example6_comparisonDemo},
    {name = "Real-time Monitor", func = example7_realtimeMonitor},
    {name = "Submenu Navigation", func = example8_submenus}
}

while true do
    local exampleNames = {}
    for i, ex in ipairs(examples) do
        exampleNames[i] = ex.name
    end
    
    local choice = utils.quickMenu("Choose an Example", exampleNames)
    
    if choice then
        term.clear()
        term.setCursorPos(1, 1)
        examples[choice].func()
        print("\n\nPress any key to return to examples menu...")
        os.pullEvent("key")
        term.clear()
        term.setCursorPos(1, 1)
    else
        break
    end
end

term.clear()
term.setCursorPos(1, 1)
print("Thanks for exploring the enhanced menu system!")
print("\nKey Features:")
print("- Immediate execution (no Enter key needed)")
print("- Monitor display support")
print("- Touch support for monitors")
print("- Mouse click support for terminals")
print("- Submenu navigation")
