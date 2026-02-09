# Enhanced Menu System - Feature Reference

## New Features Overview

### 1. Immediate Execution
Execute functions on item selection without requiring Enter key press.

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
                -- Item automatically updates in menu
            end
        }
    }
})
```

### 2. Monitor Support
Display menus on external monitors instead of terminal.

**Option:** `display = monitor`

```lua
local monitor = peripheral.find("monitor")

utils.menu({
    title = "Monitor Menu",
    display = monitor,  -- Show on monitor instead of terminal
    items = {"Option 1", "Option 2", "Option 3"}
})
```

### 3. Touch Support (Monitors)
Enable touch interaction on monitors.

**Option:** `enableTouch = true` (default for monitors)

```lua
utils.actionMenu({
    title = "Touch Menu",
    display = monitor,
    enableTouch = true,  -- Touch items to select
    immediateExecute = true,  -- Touch to execute
    items = {
        {name = "Touch Me!", onSelect = function() print("Touched!") end}
    }
})
```

### 4. Mouse Click Support (Terminal)
Enable mouse click selection in terminal.

**Option:** `enableMouse = true` (default for terminal)

```lua
utils.menu({
    title = "Clickable Menu",
    enableMouse = true,  -- Click items with mouse
    items = {"Option 1", "Option 2", "Option 3"}
})
```

---

## Complete Option Reference

### utils.menu(options)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | string | "Menu" | Menu title text |
| `items` | table | required | Array of menu items |
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

### Menu Item Structure

```lua
{
    name = "Display Name",           -- Required: shown in menu
    
    -- For immediate execution:
    onSelect = function(item, index) -- Callback for immediate mode
        -- Do something
        -- Optionally modify item.name to update display
    end,
    
    -- For traditional action menus:
    action = function()              -- Callback for normal mode
        -- Do something
        return false  -- Return false to exit menu
    end,
    
    -- For submenus:
    submenu = {
        title = "Submenu Title",
        items = { ... }
    }
}
```

---

## Usage Examples

### Example 1: Simple Immediate Execution
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
            onSelect = function()
                mon.clear()
            end
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
        },
        {
            name = "Blue",
            onSelect = function()
                term.setBackgroundColor(colors.blue)
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
    -- Run menu on each monitor in parallel
    parallel.waitForAny(
        function()
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
        end
    )
end
```

### Example 5: Hybrid Input (Keyboard + Mouse)
```lua
-- Users can navigate with arrows OR click with mouse
utils.menu({
    title = "Flexible Input",
    enableMouse = true,      -- Mouse clicks work
    -- Arrow keys work automatically
    items = {
        "Option 1",
        "Option 2",
        "Option 3"
    }
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

## Feature Combinations

| Display | Touch/Mouse | Immediate | Result |
|---------|-------------|-----------|--------|
| Terminal | Mouse | Yes | Click to execute instantly |
| Terminal | Mouse | No | Click to select, Enter to execute |
| Monitor | Touch | Yes | Touch to execute instantly |
| Monitor | Touch | No | Touch to select, external Enter needed |
| Either | Either | No | Traditional menu with Enter key |

---

## Best Practices

1. **Immediate Execution:**
   - Use for toggles, counters, quick actions
   - Update `item.name` to show current state
   - Keep actions fast (<1 second)

2. **Monitor Menus:**
   - Use larger font sizes for better visibility
   - Consider touch target sizes (full width items)
   - Good for public kiosks, control panels

3. **Mouse Support:**
   - Combine with keyboard for accessibility
   - Great for GUIs and dashboards
   - Users can choose their preferred input

4. **Touch Support:**
   - Perfect for wall-mounted monitors
   - Intuitive for non-technical users
   - Consider item spacing for larger fingers

---

## Migration Guide

### From Old Menu System

**Old way:**
```lua
local choice = utils.menu({
    title = "Menu",
    items = {"A", "B", "C"}
})
```

**New way (same behavior):**
```lua
local choice = utils.menu({
    title = "Menu",
    items = {"A", "B", "C"},
    display = term,           -- Explicit (optional)
    immediateExecute = false, -- Traditional (optional)
    enableMouse = true        -- Mouse support (optional)
})
```

### Adding New Features

**Add immediate execution:**
```lua
-- Change items from strings to objects
items = {
    {name = "Option 1", onSelect = function() ... end},
    {name = "Option 2", onSelect = function() ... end}
}
immediateExecute = true
```

**Add monitor support:**
```lua
local mon = peripheral.find("monitor")
display = mon  -- Add this option
```

**Add touch support:**
```lua
enableTouch = true  -- Auto-enabled for monitors
```

---

## Troubleshooting

**Menu not appearing on monitor:**
- Check `peripheral.find("monitor")` returns a device
- Verify monitor is connected
- Try `monitor.clear()` before menu

**Touch not working:**
- Ensure monitor is advanced (gold border)
- Check `enableTouch = true` is set
- Verify `peripheral.getName(monitor)` matches

**Mouse not working:**
- Confirm using terminal (not monitor)
- Check `enableMouse = true`
- Try clicking directly on item text

**Immediate execution not working:**
- Use `onSelect` not `action` callback
- Set `immediateExecute = true`
- Check function is being called (add debug print)

---

## Performance Notes

- Immediate execution redraws menu after each action
- Monitor rendering is slightly slower than terminal
- Touch events are instant (no debouncing needed)
- Mouse clicks work even while menu is updating
- Large item lists auto-paginate (no performance impact)
