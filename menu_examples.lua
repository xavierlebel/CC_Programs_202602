-- menu_examples_enhanced.lua
-- Demonstrates enhanced menu features: immediate execution, monitor support, touch/mouse

local utils = require('modules/utils')

----------------------------------------------------------------------------
-- EXAMPLE 1: Immediate Execution (No Enter Key)
----------------------------------------------------------------------------
function example1_immediateExecution()
    print("Example 1: Immediate Execution")
    print("-------------------------------\n")
    print("Click or arrow to an item - it executes immediately!")
    print("No need to press Enter.\n")
    
    local counter = 0
    local display = "Counter: 0"
    
    utils.actionMenu({
        title = "Immediate Execution Demo",
        immediateExecute = true,  -- KEY FEATURE: Execute on select
        items = {
            {
                name = "Increment Counter",
                onSelect = function(item)
                    counter = counter + 1
                    display = "Counter: " .. counter
                    print("Counter increased to " .. counter)
                end
            },
            {
                name = "Decrement Counter",
                onSelect = function(item)
                    counter = counter - 1
                    display = "Counter: " .. counter
                    print("Counter decreased to " .. counter)
                end
            },
            {
                name = "Reset Counter",
                onSelect = function(item)
                    counter = 0
                    display = "Counter: 0"
                    print("Counter reset!")
                end
            },
            {
                name = "Show Current Value",
                onSelect = function(item)
                    print("\n=== Current State ===")
                    print(display)
                    print("====================\n")
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
                display = monitor,  -- KEY FEATURE: Display on monitor
                enableTouch = true,  -- KEY FEATURE: Touch support
                immediateExecute = true,
                items = {
                    {
                        name = "Light Mode",
                        onSelect = function()
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
                        onSelect = function()
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
                        onSelect = function()
                            monitor.clear()
                            monitor.setCursorPos(1, 1)
                            monitor.write("Current time: " .. textutils.formatTime(os.time(), false))
                            sleep(2)
                        end
                    },
                    {
                        name = "Clear Monitor",
                        onSelect = function()
                            monitor.setBackgroundColor(colors.black)
                            monitor.clear()
                            sleep(0.5)
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
    
    local selectedColor = colors.white
    
    utils.actionMenu({
        title = "Color Picker (Click or Keys)",
        enableMouse = true,  -- KEY FEATURE: Mouse click support
        immediateExecute = true,
        items = {
            {
                name = "Red",
                onSelect = function()
                    selectedColor = colors.red
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
                onSelect = function()
                    selectedColor = colors.green
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
                onSelect = function()
                    selectedColor = colors.blue
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
                onSelect = function()
                    selectedColor = colors.yellow
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
                onSelect = function()
                    return false  -- Exit menu
                end
            }
        }
    })
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

----------------------------------------------------------------------------
-- EXAMPLE 4: Interactive Dashboard (Immediate + Mouse)
----------------------------------------------------------------------------
function example4_interactiveDashboard()
    print("Example 4: Interactive Dashboard")
    print("---------------------------------\n")
    
    local stats = {
        visitors = 0,
        sales = 0,
        alerts = 0
    }
    
    utils.actionMenu({
        title = "Dashboard Control",
        immediateExecute = true,
        enableMouse = true,
        items = {
            {
                name = "View Stats",
                onSelect = function()
                    term.clear()
                    term.setCursorPos(1, 1)
                    print("=== Current Statistics ===")
                    print("Visitors: " .. stats.visitors)
                    print("Sales: $" .. stats.sales)
                    print("Alerts: " .. stats.alerts)
                    print("========================\n")
                    sleep(2)
                end
            },
            {
                name = "+ Add Visitor",
                onSelect = function()
                    stats.visitors = stats.visitors + 1
                    print("Visitor added! Total: " .. stats.visitors)
                end
            },
            {
                name = "+ Add Sale ($10)",
                onSelect = function()
                    stats.sales = stats.sales + 10
                    print("Sale recorded! Total: $" .. stats.sales)
                end
            },
            {
                name = "+ Trigger Alert",
                onSelect = function()
                    stats.alerts = stats.alerts + 1
                    print("Alert logged! Total: " .. stats.alerts)
                end
            },
            {
                name = "Reset All",
                onSelect = function()
                    stats.visitors = 0
                    stats.sales = 0
                    stats.alerts = 0
                    print("All stats reset!")
                end
            }
        },
        titleColor = colors.cyan,
        selectedColor = colors.lightBlue
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 5: Multi-Monitor Setup
----------------------------------------------------------------------------
function example5_multiMonitor()
    print("Example 5: Multi-Monitor Menu")
    print("------------------------------\n")
    
    local monitors = {peripheral.find("monitor")}
    
    if #monitors == 0 then
        print("No monitors found! Please attach at least one monitor.")
        print("Press any key to skip...")
        os.pullEvent("key")
        return
    end
    
    print("Found " .. #monitors .. " monitor(s)")
    print("Select which monitor to use:\n")
    
    -- Build monitor selection menu
    local monitorItems = {}
    for i, mon in ipairs(monitors) do
        table.insert(monitorItems, {
            name = "Monitor " .. i .. " (" .. peripheral.getName(mon) .. ")",
            monitor = mon
        })
    end
    table.insert(monitorItems, "Use Terminal Instead")
    
    local choice = utils.quickMenu("Select Display", monitorItems)
    
    if not choice or choice > #monitors then
        print("Using terminal...")
        return
    end
    
    local selectedMonitor = monitors[choice]
    
    print("Menu will appear on Monitor " .. choice)
    print("Touch the monitor to interact!")
    print("Press any key here to stop...\n")
    
    parallel.waitForAny(
        function()
            utils.actionMenu({
                title = "Monitor " .. choice .. " Menu",
                display = selectedMonitor,
                enableTouch = true,
                immediateExecute = true,
                items = {
                    {
                        name = "Display Test Pattern",
                        onSelect = function()
                            selectedMonitor.clear()
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
                        onSelect = function()
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
                        onSelect = function()
                            selectedMonitor.setBackgroundColor(colors.black)
                            selectedMonitor.clear()
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
    
    local mode = utils.quickMenu("Choose Mode", {
        "Traditional (Select then Enter)",
        "Immediate (Click to Execute)"
    })
    
    if not mode then return end
    
    local settings = {
        volume = 50,
        brightness = 75,
        notifications = true
    }
    
    local menuConfig = {
        title = mode == 1 and "Settings (Traditional)" or "Settings (Immediate)",
        immediateExecute = (mode == 2),
        enableMouse = true,
        items = {
            {
                name = "Volume: " .. settings.volume .. "%",
                onSelect = function(item)
                    settings.volume = (settings.volume + 10) % 110
                    item.name = "Volume: " .. settings.volume .. "%"
                    print("Volume set to " .. settings.volume .. "%")
                end
            },
            {
                name = "Brightness: " .. settings.brightness .. "%",
                onSelect = function(item)
                    settings.brightness = (settings.brightness + 25) % 125
                    item.name = "Brightness: " .. settings.brightness .. "%"
                    print("Brightness set to " .. settings.brightness .. "%")
                end
            },
            {
                name = "Notifications: " .. (settings.notifications and "ON" or "OFF"),
                onSelect = function(item)
                    settings.notifications = not settings.notifications
                    item.name = "Notifications: " .. (settings.notifications and "ON" or "OFF")
                    print("Notifications " .. (settings.notifications and "enabled" or "disabled"))
                end
            }
        }
    }
    
    if mode == 1 then
        -- Traditional mode: requires Enter key
        menuConfig.waitAfterAction = true
    end
    
    utils.actionMenu(menuConfig)
end

----------------------------------------------------------------------------
-- EXAMPLE 7: Real-time Monitor (Immediate + Touch)
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
                onSelect = function()
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
                onSelect = function()
                    print("Time: " .. textutils.formatTime(os.time(), false))
                    print("Day: " .. os.day())
                end
            },
            {
                name = "Check Disk Space",
                onSelect = function()
                    local free = fs.getFreeSpace("/")
                    print("Free space: " .. math.floor(free / 1024) .. " KB")
                end
            },
            {
                name = "List Peripherals",
                onSelect = function()
                    local periphs = peripheral.getNames()
                    print("Connected peripherals:")
                    for _, p in ipairs(periphs) do
                        print("- " .. p .. " (" .. peripheral.getType(p) .. ")")
                    end
                end
            },
            {
                name = "Refresh All",
                onSelect = function()
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
            }
        },
        titleColor = colors.green,
        selectedColor = colors.lime
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
print("\nNew Features:")
print("- Immediate execution (no Enter key needed)")
print("- Monitor display support")
print("- Touch support for monitors")
print("- Mouse click support for terminals")
