-- menu_examples.lua
-- Demonstrates different ways to use the unified menu system

local utils = require('modules/utils')

----------------------------------------------------------------------------
-- EXAMPLE 1: Simple String Menu (Quickest approach)
----------------------------------------------------------------------------
function example1_simpleMenu()
    print("Example 1: Simple String Menu")
    print("------------------------------\n")
    
    local choice = utils.quickMenu("Main Menu", {
        "Start Game",
        "Load Save",
        "Options",
        "Exit"
    })
    
    if choice then
        print("You selected option " .. choice)
    else
        print("Menu cancelled")
    end
end

----------------------------------------------------------------------------
-- EXAMPLE 2: Basic Menu with Item Objects
----------------------------------------------------------------------------
function example2_objectMenu()
    print("Example 2: Menu with Named Items")
    print("---------------------------------\n")
    
    local selection, index = utils.menu({
        title = "Server Management",
        items = {
            {name = "View Server Status"},
            {name = "Start Server"},
            {name = "Stop Server"},
            {name = "Restart Server"},
            {name = "Configure Settings"}
        },
        message = "Select a server action"
    })
    
    if selection then
        print("Selected: " .. selection.name)
        print("Index: " .. index)
    end
end

----------------------------------------------------------------------------
-- EXAMPLE 3: Menu with Actions (Auto-executing)
----------------------------------------------------------------------------
function example3_actionMenu()
    print("Example 3: Menu with Automatic Actions")
    print("---------------------------------------\n")
    
    local inventory = {
        wood = 100,
        stone = 50,
        iron = 25
    }
    
    utils.actionMenu({
        title = "Inventory Manager",
        items = {
            {
                name = "View Inventory",
                action = function()
                    print("=== Current Inventory ===")
                    for item, count in pairs(inventory) do
                        print(item .. ": " .. count)
                    end
                end
            },
            {
                name = "Add Items",
                action = function()
                    print("Enter item name:")
                    local item = read()
                    print("Enter quantity:")
                    local qty = tonumber(read())
                    inventory[item] = (inventory[item] or 0) + qty
                    print("Added " .. qty .. " " .. item)
                end
            },
            {
                name = "Remove Items",
                action = function()
                    print("Enter item name:")
                    local item = read()
                    if inventory[item] then
                        print("Enter quantity:")
                        local qty = tonumber(read())
                        inventory[item] = math.max(0, inventory[item] - qty)
                        print("Removed " .. qty .. " " .. item)
                    else
                        print("Item not found!")
                    end
                end
            },
            {
                name = "Exit",
                action = function()
                    print("Exiting inventory manager...")
                    return false  -- returning false exits the menu
                end
            }
        },
        allowQuit = true,
        waitAfterAction = true
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 4: Nested Submenus
----------------------------------------------------------------------------
function example4_submenus()
    print("Example 4: Nested Submenus")
    print("---------------------------\n")
    
    utils.actionMenu({
        title = "Settings",
        items = {
            {
                name = "Display Settings",
                submenu = {
                    title = "Display Options",
                    items = {
                        {
                            name = "Brightness",
                            action = function()
                                print("Adjusting brightness...")
                                print("Current: 80%")
                            end
                        },
                        {
                            name = "Resolution",
                            action = function()
                                local res = utils.quickMenu("Select Resolution", {
                                    "1920x1080",
                                    "1280x720",
                                    "800x600"
                                })
                                if res == 1 then print("Set to 1920x1080")
                                elseif res == 2 then print("Set to 1280x720")
                                elseif res == 3 then print("Set to 800x600")
                                end
                            end
                        },
                        {
                            name = "Back",
                            action = function() return false end
                        }
                    }
                }
            },
            {
                name = "Audio Settings",
                submenu = {
                    title = "Audio Options",
                    items = {
                        {name = "Master Volume", action = function() print("Volume: 100%") end},
                        {name = "Music Volume", action = function() print("Music: 80%") end},
                        {name = "SFX Volume", action = function() print("SFX: 90%") end},
                        {name = "Back", action = function() return false end}
                    }
                }
            },
            {
                name = "Controls",
                submenu = {
                    title = "Control Settings",
                    items = {
                        {name = "Keyboard Bindings", action = function() print("Configure keyboard...") end},
                        {name = "Mouse Sensitivity", action = function() print("Sensitivity: Medium") end},
                        {name = "Back", action = function() return false end}
                    }
                }
            },
            {
                name = "Exit Settings",
                action = function() return false end
            }
        }
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 5: Customized Appearance
----------------------------------------------------------------------------
function example5_customStyle()
    print("Example 5: Custom Styled Menu")
    print("------------------------------\n")
    
    local choice = utils.menu({
        title = "!!! DANGER ZONE !!!",
        titleColor = colors.red,
        selectedColor = colors.orange,
        selectedTextColor = colors.white,
        items = {
            "Delete All Files",
            "Format Disk",
            "Self Destruct",
            "Cancel (probably a good idea)"
        },
        message = "Are you REALLY sure?",
        numbered = true,
        allowQuit = true,
        returnIndex = true
    })
    
    if choice == 4 or choice == nil then
        print("Phew! Crisis averted.")
    else
        print("Just kidding, nothing happened!")
    end
end

----------------------------------------------------------------------------
-- EXAMPLE 6: Large Menu with Pagination
----------------------------------------------------------------------------
function example6_largeMenu()
    print("Example 6: Large Menu with Auto-Pagination")
    print("-------------------------------------------\n")
    
    -- Generate a large list of items
    local items = {}
    for i = 1, 50 do
        table.insert(items, {
            name = "Item " .. i .. ": Resource " .. string.char(64 + (i % 26) + 1),
            action = function()
                print("You selected item " .. i)
            end
        })
    end
    
    table.insert(items, {
        name = "Exit",
        action = function() return false end
    })
    
    utils.actionMenu({
        title = "Resource Browser (50 items)",
        items = items,
        message = "Navigate with arrow keys (auto-scrolls)"
    })
end

----------------------------------------------------------------------------
-- EXAMPLE 7: Return Item vs Index
----------------------------------------------------------------------------
function example7_returnTypes()
    print("Example 7: Different Return Types")
    print("----------------------------------\n")
    
    -- Return the full item object
    local item, index = utils.menu({
        title = "Choose a Character",
        items = {
            {name = "Warrior", hp = 100, damage = 15},
            {name = "Mage", hp = 60, damage = 30},
            {name = "Rogue", hp = 80, damage = 20}
        },
        returnIndex = false  -- default
    })
    
    if item then
        print("Selected: " .. item.name)
        print("HP: " .. item.hp)
        print("Damage: " .. item.damage)
        print("Index: " .. index)
    end
    
    print("\n--- OR ---\n")
    
    -- Return just the index
    local selectedIndex = utils.menu({
        title = "Choose a Character",
        items = {"Warrior", "Mage", "Rogue"},
        returnIndex = true
    })
    
    if selectedIndex then
        print("Selected index: " .. selectedIndex)
    end
end

----------------------------------------------------------------------------
-- EXAMPLE 8: Real-world Turtle Control Menu
----------------------------------------------------------------------------
function example8_turtleControl()
    print("Example 8: Turtle Control Menu")
    print("-------------------------------\n")
    
    utils.actionMenu({
        title = "Turtle Control Panel",
        items = {
            {
                name = "Movement",
                submenu = {
                    title = "Movement Controls",
                    items = {
                        {name = "Forward", action = function() 
                            if turtle then turtle.forward() end
                            print("Moved forward") 
                        end},
                        {name = "Back", action = function() 
                            if turtle then turtle.back() end
                            print("Moved back") 
                        end},
                        {name = "Turn Left", action = function() 
                            if turtle then turtle.turnLeft() end
                            print("Turned left") 
                        end},
                        {name = "Turn Right", action = function() 
                            if turtle then turtle.turnRight() end
                            print("Turned right") 
                        end},
                        {name = "Back to Menu", action = function() return false end}
                    }
                }
            },
            {
                name = "Mining",
                submenu = {
                    title = "Mining Operations",
                    items = {
                        {name = "Dig Forward", action = function() print("Mining...") end},
                        {name = "Dig Up", action = function() print("Mining up...") end},
                        {name = "Dig Down", action = function() print("Mining down...") end},
                        {name = "Strip Mine", action = function() print("Starting strip mine...") end},
                        {name = "Back to Menu", action = function() return false end}
                    }
                }
            },
            {
                name = "Inventory",
                action = function()
                    print("=== Turtle Inventory ===")
                    if turtle then
                        for i = 1, 16 do
                            local item = turtle.getItemDetail(i)
                            if item then
                                print("Slot " .. i .. ": " .. item.name .. " x" .. item.count)
                            end
                        end
                    else
                        print("Not a turtle!")
                    end
                end
            },
            {
                name = "Refuel",
                action = function()
                    if turtle then
                        print("Current fuel: " .. turtle.getFuelLevel())
                        print("Select slot to use for fuel (1-16):")
                        local slot = tonumber(read())
                        if slot and slot >= 1 and slot <= 16 then
                            turtle.select(slot)
                            if turtle.refuel(1) then
                                print("Refueled! New level: " .. turtle.getFuelLevel())
                            else
                                print("Not a valid fuel!")
                            end
                        end
                    end
                end
            },
            {
                name = "Shutdown",
                action = function()
                    local confirm = utils.quickMenu("Are you sure?", {"Yes", "No"})
                    if confirm == 1 then
                        print("Shutting down...")
                        return false
                    end
                end
            }
        },
        titleColor = colors.green,
        selectedColor = colors.lime,
        waitAfterAction = true
    })
end

----------------------------------------------------------------------------
-- RUN EXAMPLES
----------------------------------------------------------------------------
print("===================================")
print("   MENU SYSTEM EXAMPLES")
print("===================================\n")

local examples = {
    {name = "Simple String Menu", func = example1_simpleMenu},
    {name = "Object Menu", func = example2_objectMenu},
    {name = "Action Menu", func = example3_actionMenu},
    {name = "Nested Submenus", func = example4_submenus},
    {name = "Custom Styling", func = example5_customStyle},
    {name = "Large Menu (50 items)", func = example6_largeMenu},
    {name = "Return Types", func = example7_returnTypes},
    {name = "Turtle Control Panel", func = example8_turtleControl},
}

while true do
    -- Build menu items from examples
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
    else
        break
    end
end

term.clear()
term.setCursorPos(1, 1)
print("Thanks for exploring the menu system!")
