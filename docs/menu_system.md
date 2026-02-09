# Menu System Documentation

This document combines the feature reference and quick guide for the CC Programs menu system.

---

# Quick Reference Guide

## 1. Quick Menu Patterns

### Simple String Menu
```lua
local choice = utils.quickMenu("Title", {"Option 1", "Option 2", "Option 3"})
-- Returns: index (1, 2, 3...) or nil if quit
```

### Basic - Return Full Item
```lua
local item, index = utils.menu({
    title = "My Menu",
    items = {
        {name = "First", data = 123},
        {name = "Second", data = 456}
    }
})
-- Returns: item object and index, or nil if quit
```

### Actions - Auto-Executing Menu
```lua
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
```

### Submenus - Nested Menus
```lua
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
```

---

## 2. Full Options Reference

### utils.menu(options)
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | string | "Menu" | Menu title text |
| `items` | table | required | Array of menu items (strings or objects) |
| `message` | string | "Use arrow keys..." | Bottom instruction text |
| `titleColor` | color | colors.blue | Title bar color |
| `selectedColor` | color | colors.lime | Selected item background |
| `selectedTextColor` | color | colors.black | Selected item text color |
| `allowQuit` | boolean | true | Allow 'q' to quit |
| `numbered` | boolean | true | Show item numbers |
| `returnIndex` | boolean | false | Return index vs item object |
| **`display`** | **device** | **term** | **Terminal or monitor object** |
| **`immediateExecute`** | **boolean** | **false** | **Execute on select (no Enter)** |
| **`enableTouch`** | **boolean** | **true** | **Enable touch on monitors** |
| **`enableMouse`** | **boolean** | **true** | **Enable mouse clicks on terminal** |

### utils.actionMenu(options)
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | string | "Menu" | Menu title |
| `items` | table | required | Items with action/submenu |
| `message` | string | "Help text" | Bottom instruction text |
| `titleColor` | color | colors.blue | Title bar color |
| `selectedColor` | color | colors.lime | Selection highlight |
| `allowQuit` | boolean | true | Allow 'q' to quit |
| `waitAfterAction` | boolean | true | Pause after action |

---

## 3. Item Object Formats

### Simple String Item
`items = {"Option 1", "Option 2", "Option 3"}`

### Named Item (for display)
```lua
items = {
    {name = "Start Game"},
    {name = "Load Game"},
    {name = "Exit"}
}
```

### Item with Action
```lua
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
```

### Item with Submenu
```lua
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
```

### Item with Custom Data
```lua
items = {
    {name = "Warrior", hp = 100, damage = 15},
    {name = "Mage", hp = 60, damage = 30}
}
```

---

## 4. Features & Functionality

### Pagination
Pagination is **AUTOMATIC**!
- Works with any number of items.
- Automatically scrolls as you navigate.
- Shows only items that fit on screen.
- No special configuration needed.

### Keyboard Controls
- **UP ARROW**: Move selection up (wraps to bottom)
- **DOWN ARROW**: Move selection down (wraps to top)
- **ENTER**: Select current item
- **Q**: Quit menu (if `allowQuit = true`)

---

# Common Patterns

### YES/NO Confirmation
```lua
local choice = utils.quickMenu("Are you sure?", {"Yes", "No"})
if choice == 1 then
    -- Yes selected
else
    -- No selected or quit
end
```

### Select From List
```lua
local players = {"Alice", "Bob", "Charlie"}
local selected = utils.quickMenu("Choose Player", players)
if selected then
    print("Selected: " .. players[selected])
end
```

### Main Game Loop
```lua
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
```

### Persistent Menu with Actions
```lua
utils.actionMenu({
    title = "Admin Panel",
    items = {
        {name = "View Logs", action = function() viewLogs() end},
        {name = "Restart Server", action = function() restart() end},
        {name = "Exit", action = function() return false end}
    }
})
```

---

# Style Customization

### Available Colors
`colors.white`, `colors.orange`, `colors.magenta`, `colors.lightBlue`, `colors.yellow`, `colors.lime`, `colors.pink`, `colors.gray`, `colors.lightGray`, `colors.cyan`, `colors.purple`, `colors.blue`, `colors.brown`, `colors.green`, `colors.red`, `colors.black`

### Error/Warning Menu
```lua
utils.menu({
    title = "ERROR!",
    titleColor = colors.red,
    selectedColor = colors.orange,
    items = {"Retry", "Cancel"}
})
```

### Success Menu
```lua
utils.menu({
    title = "Success!",
    titleColor = colors.green,
    selectedColor = colors.lime,
    items = {"Continue", "View Details"}
})
```

---

# Enhanced Features Reference

## New Features Overview

### 1. Immediate Execution
Execute functions on item selection without requiring Enter key press. Useful for toggles, counters, and quick actions.

**Option:** `immediateExecute = true`
**Use with:** `onSelect` callback in menu items

```lua
utils.actionMenu({
    title = "Quick Actions",
    immediateExecute = true,  -- Execute on hover/click
    items = {
        {
            name = "Action 1",
            onSelect = function(item, index)
                print("Executed immediately!")
            end
        }
    }
})
```

### 2. Monitor Support
Display menus on external monitors instead of the terminal.

**Option:** `display = monitor`

```lua
local monitor = peripheral.find("monitor")
utils.menu({
    title = "Monitor Menu",
    display = monitor,
    items = {"Option 1", "Option 2", "Option 3"}
})
```

### 3. Touch Support (Monitors)
Enable touch interaction on monitors.

**Option:** `enableTouch = true` (default for monitors)

### 4. Mouse Click Support (Terminal)
Enable mouse click selection in the terminal.

**Option:** `enableMouse = true` (default for terminal)

---

## Detailed Usage Examples

### Example 1: Simple Immediate Execution (Counter)
```lua
local counter = 0
utils.actionMenu({
    title = "Counter",
    immediateExecute = true,
    items = {
        {
            name = "Count: " .. counter,
            onSelect = function(item)
                counter = counter + 1
                item.name = "Count: " .. counter
            end
        }
    }
})
```

### Example 2: Monitor with Touch
```lua
local mon = peripheral.find("monitor")
utils.actionMenu({
    title = "Monitor Control",
    display = mon,
    enableTouch = true,
    immediateExecute = true,
    items = {
        {
            name = "Clear Screen",
            onSelect = function() mon.clear() end
        },
        {
            name = "Show Time",
            onSelect = function()
                mon.clear()
                mon.setCursorPos(1, 1)
                mon.write(textutils.formatTime(os.time()))
                sleep(2)
            end
        }
    }
})
```

### Example 3: Terminal with Mouse
```lua
utils.actionMenu({
    title = "Click Me!",
    enableMouse = true,
    immediateExecute = true,
    items = {
        {
            name = "Red",
            onSelect = function()
                term.setBackgroundColor(colors.red)
                term.clear()
                sleep(1)
                term.setBackgroundColor(colors.black)
            end
        }
    }
})
```

### Example 4: Multi-Monitor Dashboard
```lua
local monitors = {peripheral.find("monitor")}
for i, mon in ipairs(monitors) do
    parallel.waitForAny(function()
        utils.actionMenu({
            title = "Monitor " .. i,
            display = mon,
            enableTouch = true,
            immediateExecute = true,
            items = {
                {name = "Action 1", onSelect = function() print("M" .. i .. ": A1") end},
                {name = "Action 2", onSelect = function() print("M" .. i .. ": A2") end}
            }
        })
    end)
end
```

### Example 5: Hybrid Input (Keyboard + Mouse)
```lua
-- Users can navigate with arrows OR click with mouse
utils.menu({
    title = "Flexible Input",
    enableMouse = true,
    items = {"Option 1", "Option 2", "Option 3"}
})
```

---

## Callback Function Signatures

### onSelect (for immediateExecute)
```lua
function(item, index)
    -- item: The menu item object
    -- index: The position in the items array
    -- Can modify item.name to update display
    -- Return value ignored (stays in menu)
end
```

### action (for traditional menus)
```lua
function()
    -- No parameters
    -- Return false to exit menu
    -- Return anything else to stay in menu
end
```

---

## Best Practices

1. **Immediate Execution:**
   - Use for toggles, counters, and quick actions.
   - Update `item.name` to show current state.
   - Keep actions fast (<1 second).

2. **Monitor Menus:**
   - Use larger font sizes for better visibility.
   - Consider touch target sizes (full width items).

3. **Input Support:**
   - Combine mouse/touch with keyboard for accessibility.
   - Great for GUIs and dashboards.

---

## Troubleshooting

- **Menu not appearing on monitor:** Check `peripheral.find("monitor")` returns a device and verify connection.
- **Touch not working:** Ensure monitor is advanced (gold border) and `enableTouch = true`.
- **Mouse not working:** Confirm using terminal and `enableMouse = true`.
- **Immediate execution not working:** Use `onSelect` not `action` callback, and set `immediateExecute = true`.

---

## Performance Notes
- Immediate execution redraws the menu after each action.
- Monitor rendering is slightly slower than the terminal.
- Large item lists auto-paginate with no performance impact.
