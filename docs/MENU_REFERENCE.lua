-- MENU SYSTEM QUICK REFERENCE
-- ============================

local utils = require('modules/utils')

--[[
╔══════════════════════════════════════════════════════════════════════╗
║                    QUICK MENU PATTERNS                               ║
╚══════════════════════════════════════════════════════════════════════╝

1. SIMPLEST - Quick String Menu
   --------------------------------
   local choice = utils.quickMenu("Title", {"Option 1", "Option 2", "Option 3"})
   -- Returns: index (1, 2, 3...) or nil if quit
   

2. BASIC - Return Full Item
   ---------------------------
   local item, index = utils.menu({
       title = "My Menu",
       items = {
           {name = "First", data = 123},
           {name = "Second", data = 456}
       }
   })
   -- Returns: item object and index, or nil if quit
   

3. ACTIONS - Auto-Executing Menu
   ---------------------------------
   utils.actionMenu({
       title = "Actions",
       items = {
           {
               name = "Do Something",
               action = function()
                   print("Doing something!")
                   -- return false to exit menu
               end
           },
           {
               name = "Exit",
               action = function() return false end
           }
       }
   })
   

4. SUBMENUS - Nested Menus
   --------------------------
   utils.actionMenu({
       title = "Main",
       items = {
           {
               name = "Settings",
               submenu = {
                   title = "Settings Menu",
                   items = {
                       {name = "Option 1", action = function() print("1") end},
                       {name = "Back", action = function() return false end}
                   }
               }
           }
       }
   })
   

╔══════════════════════════════════════════════════════════════════════╗
║                    FULL OPTIONS REFERENCE                             ║
╚══════════════════════════════════════════════════════════════════════╝

utils.menu({
    -- Required
    items = {},                    -- Array of items (strings or objects)
    
    -- Optional
    title = "Menu Title",          -- Menu title (default: "Menu")
    message = "Help text",         -- Bottom instruction text
    titleColor = colors.blue,      -- Title bar color (default: blue)
    selectedColor = colors.lime,   -- Selection highlight (default: lime)
    selectedTextColor = colors.black, -- Selected text color (default: black)
    allowQuit = true,              -- Allow 'q' to quit (default: true)
    numbered = true,               -- Show numbers (default: true)
    returnIndex = false,           -- Return index only (default: false)
})


utils.actionMenu({
    -- Required
    title = "Title",
    items = {},                    -- Items with action/submenu
    
    -- Optional
    message = "Help text",
    titleColor = colors.blue,
    selectedColor = colors.lime,
    allowQuit = true,
    waitAfterAction = true,        -- Pause after action (default: true)
})


╔══════════════════════════════════════════════════════════════════════╗
║                    ITEM OBJECT FORMATS                                ║
╚══════════════════════════════════════════════════════════════════════╝

-- Simple string item
items = {"Option 1", "Option 2", "Option 3"}


-- Named item (for display)
items = {
    {name = "Start Game"},
    {name = "Load Game"},
    {name = "Exit"}
}


-- Item with action
items = {
    {
        name = "Click Me",
        action = function()
            print("Clicked!")
            -- return false to exit menu
            -- return nothing/true to stay in menu
        end
    }
}


-- Item with submenu
items = {
    {
        name = "Settings",
        submenu = {
            title = "Settings",
            items = {
                {name = "Option 1", action = function() end},
                {name = "Back", action = function() return false end}
            }
        }
    }
}


-- Item with custom data
items = {
    {name = "Warrior", hp = 100, damage = 15},
    {name = "Mage", hp = 60, damage = 30}
}


╔══════════════════════════════════════════════════════════════════════╗
║                    PAGINATION                                         ║
╚══════════════════════════════════════════════════════════════════════╝

Pagination is AUTOMATIC!
- Works with any number of items
- Automatically scrolls as you navigate
- Shows only items that fit on screen
- No special configuration needed

Example:
local items = {}
for i = 1, 100 do
    items[i] = "Item " .. i
end

utils.quickMenu("Big List", items)  -- Just works!


╔══════════════════════════════════════════════════════════════════════╗
║                    KEYBOARD CONTROLS                                  ║
╚══════════════════════════════════════════════════════════════════════╝

UP ARROW    - Move selection up (wraps to bottom)
DOWN ARROW  - Move selection down (wraps to top)
ENTER       - Select current item
Q           - Quit menu (if allowQuit = true)


╔══════════════════════════════════════════════════════════════════════╗
║                    COMMON PATTERNS                                    ║
╚══════════════════════════════════════════════════════════════════════╝

-- YES/NO CONFIRMATION
local choice = utils.quickMenu("Are you sure?", {"Yes", "No"})
if choice == 1 then
    -- Yes selected
else
    -- No selected or quit
end


-- SELECT FROM LIST
local players = {"Alice", "Bob", "Charlie"}
local selected = utils.quickMenu("Choose Player", players)
if selected then
    print("Selected: " .. players[selected])
end


-- MAIN GAME LOOP
while true do
    local choice = utils.quickMenu("Main Menu", {
        "Start Game",
        "Options", 
        "Exit"
    })
    
    if choice == 1 then
        -- start game
    elseif choice == 2 then
        -- show options
    elseif choice == 3 or choice == nil then
        break
    end
end


-- PERSISTENT MENU WITH ACTIONS
utils.actionMenu({
    title = "Admin Panel",
    items = {
        {name = "View Logs", action = function() viewLogs() end},
        {name = "Restart Server", action = function() restart() end},
        {name = "Exit", action = function() return false end}
    }
})


╔══════════════════════════════════════════════════════════════════════╗
║                    STYLE CUSTOMIZATION                                ║
╚══════════════════════════════════════════════════════════════════════╝

-- Available colors:
colors.white, colors.orange, colors.magenta, colors.lightBlue,
colors.yellow, colors.lime, colors.pink, colors.gray,
colors.lightGray, colors.cyan, colors.purple, colors.blue,
colors.brown, colors.green, colors.red, colors.black

-- Error/Warning Menu
utils.menu({
    title = "ERROR!",
    titleColor = colors.red,
    selectedColor = colors.orange,
    items = {"Retry", "Cancel"}
})

-- Success Menu
utils.menu({
    title = "Success!",
    titleColor = colors.green,
    selectedColor = colors.lime,
    items = {"Continue", "View Details"}
})

-- Info Menu
utils.menu({
    title = "Information",
    titleColor = colors.lightBlue,
    selectedColor = colors.cyan,
    items = {"OK"}
})


╔══════════════════════════════════════════════════════════════════════╗
║                    TIPS & TRICKS                                      ║
╚══════════════════════════════════════════════════════════════════════╝

1. Use returnIndex = true for simple selections
   local idx = utils.menu({items = myItems, returnIndex = true})

2. Return false from action to exit menu
   {name = "Exit", action = function() return false end}

3. Chain menus for workflows
   local step1 = utils.quickMenu("Step 1", options1)
   if step1 then
       local step2 = utils.quickMenu("Step 2", options2)
   end

4. Store complex data in items
   local character = utils.menu({
       items = {
           {name = "Warrior", hp = 100, class = "tank"},
           {name = "Mage", hp = 60, class = "dps"}
       }
   })
   print(character.hp)  -- Access custom data

5. Use submenus to organize complex UIs
   Keeps code modular and easy to navigate

6. Disable quit for forced selections
   utils.menu({items = items, allowQuit = false})

7. Disable numbering for cleaner look
   utils.menu({items = items, numbered = false})

]]--
