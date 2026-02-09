-- table_examples.lua

local utils = require('modules/utils')

local monitor = utils.wrapPeripheral("monitor")

----------------------------------------------------------------------------
-- EXAMPLE 1: Simple static table with auto-detected headers
----------------------------------------------------------------------------
local function example1_simple()
    local data = {
        {name = "Iron", count = 64, price = 5},
        {name = "Gold", count = 32, price = 20},
        {name = "Diamond", count = 8, price = 100},
        {name = "Coal", count = 128, price = 1}
    }
    
    utils.renderTable({
        display = monitor,
        data = data,
        x = 1,
        y = 1
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 2: Table with custom headers and color support
----------------------------------------------------------------------------
local function example2_colors()
    local data = {
        {
            item = "Reactor 1",
            status = {value = "ONLINE", color = "lime"},
            temp = {value = "850C", color = "yellow"},
            output = "2000 RF/t"
        },
        {
            item = "Reactor 2",
            status = {value = "OFFLINE", color = "red"},
            temp = {value = "25C", color = "white"},
            output = "0 RF/t"
        },
        {
            item = "Reactor 3",
            status = {value = "ONLINE", color = "lime"},
            temp = {value = "920C", color = "orange"},
            output = "2500 RF/t"
        }
    }
    
    utils.renderTable({
        display = monitor,
        data = data,
        headers = {"item", "status", "temp", "output"},
        x = 1,
        y = 1
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 3: Interactive table with pagination on terminal
----------------------------------------------------------------------------
local function example3_interactive()
    local data = {}
    -- Generate sample data
    for i = 1, 25 do
        table.insert(data, {
            id = i,
            task = "Task " .. i,
            progress = math.random(0, 100) .. "%",
            eta = math.random(1, 60) .. "min"
        })
    end
    
    utils.renderTable({
        display = term,
        data = data,
        headers = {"id", "task", "progress", "eta"},
        x = 1,
        y = 2,
        maxHeight = 10,
        interactive = true  -- Enable keyboard navigation
    })
    
    print("Table closed!")
end

----------------------------------------------------------------------------
-- EXAMPLE 4: Constrained width table (useful for monitors)
----------------------------------------------------------------------------
local function example4_constrained()
    local data = {
        {slot = 1, item = "minecraft:diamond_pickaxe", qty = 1},
        {slot = 2, item = "minecraft:cobblestone", qty = 64},
        {slot = 3, item = "minecraft:iron_ingot", qty = 32}
    }
    
    utils.renderTable({
        display = monitor,
        data = data,
        headers = {"slot", "item", "qty"},
        x = 1,
        y = 1,
        maxWidth = 30  -- Limit total width
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 5: Live updating inventory display
----------------------------------------------------------------------------
local function example5_live_update()
    local chest = peripheral.find("minecraft:chest")
    
    if not chest then
        print("No chest found!")
        return
    end
    
    while true do
        local items = chest.list()
        local data = {}
        
        for slot, item in pairs(items) do
            table.insert(data, {
                slot = slot,
                name = item.name:gsub("minecraft:", ""),
                count = item.count
            })
        end
        
        -- Sort by slot number
        table.sort(data, function(a, b) return a.slot < b.slot end)
        
        monitor.clear()
        utils.renderTable({
            display = monitor,
            data = data,
            headers = {"slot", "name", "count"},
            x = 1,
            y = 1
        })
        
        sleep(2)  -- Update every 2 seconds
    end
end

----------------------------------------------------------------------------
-- EXAMPLE 6: Multi-monitor dashboard
----------------------------------------------------------------------------
local function example6_dashboard()
    local w, h = monitor.getSize()
    
    -- Storage status
    local storage = {
        {resource = "Iron", amount = 5420, capacity = 10000},
        {resource = "Copper", amount = 8100, capacity = 10000},
        {resource = "Gold", amount = 1200, capacity = 5000}
    }
    
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.setTextColor(colors.yellow)
    monitor.write("=== STORAGE STATUS ===")
    
    utils.renderTable({
        display = monitor,
        data = storage,
        headers = {"resource", "amount", "capacity"},
        x = 1,
        y = 3,
        maxHeight = 5
    })
    
    -- Power status below
    local power = {
        {source = "Solar", output = {value = "1200 RF/t", color = "lime"}},
        {source = "Wind", output = {value = "800 RF/t", color = "lime"}},
        {source = "Battery", output = {value = "Discharging", color = "orange"}}
    }
    
    monitor.setCursorPos(1, 10)
    monitor.setTextColor(colors.yellow)
    monitor.write("=== POWER STATUS ===")
    
    utils.renderTable({
        display = monitor,
        data = power,
        headers = {"source", "output"},
        x = 1,
        y = 12
    })
end

----------------------------------------------------------------------------
-- RUN EXAMPLES
----------------------------------------------------------------------------

-- Uncomment the example you want to run:

-- example1_simple()
-- example2_colors()
-- example3_interactive()
-- example4_constrained()
-- example5_live_update()
example6_dashboard()