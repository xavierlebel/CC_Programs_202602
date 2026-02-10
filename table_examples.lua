-- table_examples.lua
-- Demonstrates the interactive features of renderTable

local utils = require('modules/utils')

local monitor = utils.wrapPeripheral("monitor")

----------------------------------------------------------------------------
-- EXAMPLE 1: Auto-clear demonstration (solves overlay problem)
----------------------------------------------------------------------------
local function example1_auto_clear()
    print("Testing auto-clear feature...")
    print("You should NOT see data overlap!")
    
    -- First render
    local data1 = {
        {name = "Iron", count = 64},
        {name = "Gold", count = 32}
    }
    
    utils.renderTable({
        display = monitor,
        data = data1,
        x = 1,
        y = 1,
        autoClear = true  -- Default behavior, clears before rendering
    })
    
    sleep(2)
    
    -- Second render - will clear first!
    local data2 = {
        {name = "Diamond", count = 8},
        {name = "Emerald", count = 4},
        {name = "Coal", count = 128}
    }
    
    utils.renderTable({
        display = monitor,
        data = data2,
        x = 1,
        y = 1,
        autoClear = true  -- Clears the Iron/Gold data
    })
    
    print("Notice: Old data was cleared before new data appeared!")
    sleep(2)
end

----------------------------------------------------------------------------
-- EXAMPLE 2: Sortable table - Click headers to sort
----------------------------------------------------------------------------
local function example2_sortable_headers()
    local data = {
        {name = "Iron Ore", price = 5, stock = 640},
        {name = "Gold Ore", price = 20, stock = 320},
        {name = "Diamond", price = 100, stock = 45},
        {name = "Coal", price = 1, stock = 1280},
        {name = "Emerald", price = 150, stock = 12},
        {name = "Redstone", price = 3, stock = 800}
    }
    
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.setTextColor(colors.yellow)
    monitor.write("=== SORTABLE INVENTORY ===")
    monitor.setTextColor(colors.gray)
    monitor.setCursorPos(1, 2)
    monitor.write("Touch headers to sort!")
    monitor.setCursorPos(1, 3)
    monitor.write("Press 'Q' to quit")
    
    utils.renderTable({
        display = monitor,
        data = data,
        headers = {"name", "price", "stock"},
        x = 1,
        y = 5,
        autoClear = false,     -- Don't clear our title
        enableSort = true,     -- Enable click-to-sort
        interactive = true,    -- Enable event loop
        enableTouch = true     -- Enable monitor touch
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 3: Clickable rows with detail view
----------------------------------------------------------------------------
local function example3_clickable_rows()
    local data = {
        {
            id = 1,
            reactor = "Reactor Alpha",
            status = {value = "ONLINE", color = "lime"},
            temp = 850,
            fuel = 75
        },
        {
            id = 2,
            reactor = "Reactor Beta",
            status = {value = "OFFLINE", color = "red"},
            temp = 25,
            fuel = 0
        },
        {
            id = 3,
            reactor = "Reactor Gamma",
            status = {value = "ONLINE", color = "lime"},
            temp = 920,
            fuel = 45
        },
        {
            id = 4,
            reactor = "Reactor Delta",
            status = {value = "WARNING", color = "orange"},
            temp = 1050,
            fuel = 90
        }
    }
    
    -- Callback when a row is clicked
    local function showDetails(rowData, rowIndex)
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.yellow)
        print("=== REACTOR DETAILS ===")
        term.setTextColor(colors.white)
        print("")
        print("Reactor: " .. rowData.reactor)
        print("ID: " .. rowData.id)
        
        -- Handle color table for status
        if type(rowData.status) == "table" then
            term.setTextColor(colors[rowData.status.color] or colors.white)
            print("Status: " .. rowData.status.value)
            term.setTextColor(colors.white)
        else
            print("Status: " .. tostring(rowData.status))
        end
        
        print("Temperature: " .. rowData.temp .. "C")
        print("Fuel Level: " .. rowData.fuel .. "%")
        print("")
        print("(Touch another reactor or press Q to quit)")
    end
    
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.setTextColor(colors.yellow)
    monitor.write("=== REACTOR MONITOR ===")
    monitor.setTextColor(colors.gray)
    monitor.setCursorPos(1, 2)
    monitor.write("Touch reactors for details")
    monitor.setCursorPos(1, 3)
    monitor.write("Press 'Q' to quit")
    
    utils.renderTable({
        display = monitor,
        data = data,
        headers = {"id", "reactor", "status", "temp", "fuel"},
        x = 1,
        y = 5,
        autoClear = false,
        enableRowClick = true,
        onRowClick = showDetails,
        interactive = true,
        enableTouch = true
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 4: Combined - Sortable AND clickable
----------------------------------------------------------------------------
local function example4_full_interactive()
    local data = {
        {item = "Diamond Pickaxe", durability = 1561, enchanted = "Yes"},
        {item = "Iron Sword", durability = 250, enchanted = "No"},
        {item = "Diamond Sword", durability = 1561, enchanted = "Yes"},
        {item = "Bow", durability = 384, enchanted = "Yes"},
        {item = "Iron Pickaxe", durability = 250, enchanted = "No"},
        {item = "Shield", durability = 336, enchanted = "No"}
    }
    
    local function showItemDetails(rowData, rowIndex)
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.cyan)
        print("=== ITEM DETAILS ===")
        term.setTextColor(colors.white)
        print("")
        print("Item: " .. rowData.item)
        print("Durability: " .. rowData.durability)
        print("Enchanted: " .. rowData.enchanted)
        print("")
        print("--- Actions Available ---")
        print("1. Repair item")
        print("2. Enchant item")
        print("3. Store in chest")
        print("")
        print("(Touch another item or press Q to quit)")
    end
    
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.setTextColor(colors.cyan)
    monitor.write("=== EQUIPMENT INVENTORY ===")
    monitor.setTextColor(colors.gray)
    monitor.setCursorPos(1, 2)
    monitor.write("Touch headers to sort | Touch items for details")
    
    utils.renderTable({
        display = monitor,
        data = data,
        headers = {"item", "durability", "enchanted"},
        x = 1,
        y = 4,
        autoClear = false,
        enableSort = true,
        enableRowClick = true,
        onRowClick = showItemDetails,
        interactive = true,
        enableTouch = true
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 5: Terminal with mouse clicks
----------------------------------------------------------------------------
local function example5_terminal_mouse()
    local data = {
        {player = "Steve", score = 1500, kills = 45, deaths = 12},
        {player = "Alex", score = 2300, kills = 67, deaths = 8},
        {player = "Herobrine", score = 9999, kills = 200, deaths = 0},
        {player = "Notch", score = 3400, kills = 89, deaths = 15}
    }
    
    -- Custom callback when row is clicked
    local function onPlayerClick(rowData, rowIndex)
        print("\n=== PLAYER STATS ===")
        print("Player: " .. rowData.player)
        print("Score: " .. rowData.score)
        print("K/D Ratio: " .. string.format("%.2f", rowData.kills / math.max(rowData.deaths, 1)))
        print("\n(Click another player or press Q to quit)")
    end
    
    term.clear()
    term.setCursorPos(1, 1)
    print("=== LEADERBOARD ===")
    print("Click headers to sort")
    print("Click players for stats")
    print("")
    
    utils.renderTable({
        display = term,  -- Using terminal instead of monitor
        data = data,
        headers = {"player", "score", "kills", "deaths"},
        x = 1,
        y = 5,
        autoClear = false,
        enableSort = true,
        enableRowClick = true,
        onRowClick = onPlayerClick,
        interactive = true,
        enableMouse = true  -- Enable terminal mouse clicks
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 6: Custom header click callback
----------------------------------------------------------------------------
local function example6_custom_callbacks()
    local data = {
        {player = "Steve", score = 1500, kills = 45, deaths = 12},
        {player = "Alex", score = 2300, kills = 67, deaths = 8},
        {player = "Herobrine", score = 9999, kills = 200, deaths = 0},
        {player = "Notch", score = 3400, kills = 89, deaths = 15}
    }
    
    -- Custom callback when header is clicked
    local function onHeaderSort(header, sortedData, isAscending)
        print("\nSorted by: " .. header)
        print("Direction: " .. (isAscending and "Ascending" or "Descending"))
        print("Top player: " .. sortedData[1].player)
    end
    
    -- Custom callback when row is clicked
    local function onPlayerClick(rowData, rowIndex)
        print("\n=== PLAYER STATS ===")
        print("Player: " .. rowData.player)
        print("Score: " .. rowData.score)
        print("K/D Ratio: " .. string.format("%.2f", rowData.kills / math.max(rowData.deaths, 1)))
        print("\n(Click another player or press Q to quit)")
    end
    
    term.clear()
    term.setCursorPos(1, 1)
    print("=== LEADERBOARD ===")
    print("Click headers to sort")
    print("Click players for stats")
    print("")
    
    utils.renderTable({
        display = term,
        data = data,
        headers = {"player", "score", "kills", "deaths"},
        x = 1,
        y = 5,
        autoClear = false,
        enableSort = true,
        enableRowClick = true,
        onHeaderClick = onHeaderSort,
        onRowClick = onPlayerClick,
        interactive = true,
        enableMouse = true
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 7: Disable auto-clear for custom layouts
----------------------------------------------------------------------------
local function example7_custom_layout()
    local w, h = monitor.getSize()
    
    -- Create custom header that stays
    monitor.clear()
    monitor.setBackgroundColor(colors.blue)
    monitor.setCursorPos(1, 1)
    monitor.clearLine()
    monitor.setTextColor(colors.white)
    local title = "MY CUSTOM DASHBOARD"
    monitor.setCursorPos(math.floor((w - #title) / 2), 1)
    monitor.write(title)
    monitor.setBackgroundColor(colors.black)
    
    -- Draw multiple tables without clearing the header
    local resources = {
        {type = "Iron", amount = 5000},
        {type = "Gold", amount = 2000}
    }
    
    monitor.setCursorPos(1, 3)
    monitor.setTextColor(colors.yellow)
    monitor.write("Resources:")
    
    utils.renderTable({
        display = monitor,
        data = resources,
        x = 1,
        y = 4,
        autoClear = false  -- Don't clear our custom header!
    })
    
    local power = {
        {source = "Solar", output = 1200},
        {source = "Wind", output = 800}
    }
    
    monitor.setCursorPos(1, 8)
    monitor.setTextColor(colors.yellow)
    monitor.write("Power:")
    
    utils.renderTable({
        display = monitor,
        data = power,
        x = 1,
        y = 9,
        autoClear = false  -- Don't clear anything!
    })
    
    print("Dashboard created! Press any key to continue...")
    os.pullEvent("key")
end

----------------------------------------------------------------------------
-- EXAMPLE 8: Non-interactive table (just display)
----------------------------------------------------------------------------
local function example8_static_display()
    local data = {
        {item = "Cobblestone", count = 9999},
        {item = "Dirt", count = 5432},
        {item = "Wood", count = 876}
    }
    
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.setTextColor(colors.lime)
    monitor.write("=== STATIC INVENTORY ===")
    monitor.setTextColor(colors.gray)
    monitor.setCursorPos(1, 2)
    monitor.write("Read-only display")
    
    -- No interactive flag - just render and exit
    utils.renderTable({
        display = monitor,
        data = data,
        headers = {"item", "count"},
        x = 1,
        y = 4,
        autoClear = false
    })
    
    print("Static table displayed! Press any key to continue...")
    os.pullEvent("key")
end

----------------------------------------------------------------------------
-- RUN EXAMPLES
----------------------------------------------------------------------------
term.clear()
term.setCursorPos(1, 1)

print("Interactive Table Examples")
print("===========================")
print("1. Auto-clear demo")
print("2. Sortable headers (touch to sort)")
print("3. Clickable rows (touch for details)")
print("4. Full interactive (sort + click)")
print("5. Terminal with mouse support")
print("6. Custom callbacks")
print("7. Custom layout (no auto-clear)")
print("8. Static display (non-interactive)")
print("")
print("Choose an example (1-8):")

local choice = tonumber(read())

if choice == 1 then
    example1_auto_clear()
elseif choice == 2 then
    example2_sortable_headers()
elseif choice == 3 then
    example3_clickable_rows()
elseif choice == 4 then
    example4_full_interactive()
elseif choice == 5 then
    example5_terminal_mouse()
elseif choice == 6 then
    example6_custom_callbacks()
elseif choice == 7 then
    example7_custom_layout()
elseif choice == 8 then
    example8_static_display()
else
    print("Invalid choice!")
end
