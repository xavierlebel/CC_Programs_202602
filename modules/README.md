# ComputerCraft Enhanced Menu System

A powerful, flexible, and feature-rich menu system for ComputerCraft: Tweaked.

## Features

- **Simple & Advanced Menus**: From quick string lists to complex interactive dashboards.
- **Immediate Execution**: Execute actions instantly on selection (no Enter key required).
- **Monitor & Touch Support**: Display menus on external monitors with full touch interaction.
- **Mouse Support**: Navigate and click items using the mouse in the terminal.
- **Automatic Pagination**: Handles large lists effortlessly.
- **Deep Nesting**: Support for submenus to organize complex UIs.
- **Customizable**: Full control over colors, titles, and item behavior.

---

## 🚀 Quick Start Patterns

### 1. Simplest - Quick String Menu
```lua
local utils = require('modules/utils')
local choice = utils.quickMenu("Title", {"Option 1", "Option 2", "Option 3"})
-- Returns index (1, 2, 3...) or nil if quit ('q')
```

### 2. Multi-Action Menu
```lua
utils.actionMenu({
    title = "System Controls",
    items = {
        {
            name = "Check Fuel",
            action = function() print("Fuel: " .. turtle.getFuelLevel()) end
        },
        {
            name = "Exit",
            action = function() return false end -- Return false to exit
        }
    }
})
```

---

## 🛠 Core Functions

### `utils.menu(options)`
The base menu function. Returns the selected `item` object and its `index`.

### `utils.quickMenu(title, items)`
A wrapper for `utils.menu` with default settings for simple list selection.

### `utils.actionMenu(options)`
A persistent menu that executes functions defined in item `action` (traditional) or `onSelect` (immediate) properties.

---

## ✨ Enhanced Features

### 1. Immediate Execution
Execute functions as soon as an item is highlighted/selected, without waiting for the Enter key.

**Option:** `immediateExecute = true`

```lua
utils.actionMenu({
    title = "Quick Toggle",
    immediateExecute = true,
    items = {
        {
            name = "Lights: OFF",
            onSelect = function(item)
                -- Toggle logic
                item.name = "Lights: ON"
            end
        }
    }
})
```

### 2. Monitor & Touch Support
Run your menu on any connected monitor. Touch support is auto-enabled for monitors.

**Option:** `display = monitor_object`

```lua
local mon = peripheral.find("monitor")
utils.menu({
    title = "Wall Panel",
    display = mon,
    enableTouch = true, -- Default for monitors
    items = {"Start", "Stop", "Reset"}
})
```

### 3. Mouse Click Support
Enable mouse interaction in the terminal (or monitor).

**Option:** `enableMouse = true`

```lua
utils.menu({
    title = "Clickable Menu",
    enableMouse = true,
    items = {"A", "B", "C"}
})
```

---

## 📋 Full Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | string | "Menu" | Menu title text |
| `items` | table | **Required** | Array of items (strings or objects) |
| `message` | string | "Use arrow keys..." | Bottom instruction text |
| `titleColor` | color | `colors.blue` | Title bar color |
| `selectedColor` | color | `colors.lime` | Selected item background |
| `selectedTextColor`| color | `colors.black` | Selected item text color |
| `display` | device | `term` | Target display (terminal or monitor) |
| `immediateExecute` | boolean | `false` | Execute `onSelect` instantly |
| `enableTouch` | boolean | `true` | Enable touch (monitors) |
| `enableMouse` | boolean | `true` | Enable mouse clicks (terminal) |
| `allowQuit` | boolean | `true` | Allow 'q' to quit |
| `numbered` | boolean | `true` | Show item numbers (1, 2, 3...) |
| `returnIndex` | boolean | `false` | Return index instead of item object |
| `waitAfterAction` | boolean | `true` | Pause after a traditional action |

---

## 📦 Item Object Format

```lua
{
    name = "Display Name",           -- Shown in menu
    
    -- For traditional menus (require Enter):
    action = function() 
        return false -- Return false to exit menu
    end,
    
    -- For immediate menus (immediateExecute = true):
    onSelect = function(item, index)
        -- Update item.name here to refresh display
    end,
    
    -- For nested menus:
    submenu = {
        title = "Submenu",
        items = { ... }
    }
}
```

---

## ⌨️ Controls

- **UP / DOWN ARROW**: Navigate items (wraps around).
- **ENTER**: Select/Execute item.
- **Q**: Quit menu.
- **MOUSE CLICK / MONITOR TOUCH**: Select or execute items directly.

---

## 💡 Tips & Best Practices

1. **Self-Updating Items**: In `immediateExecute` mode, modify `item.name` inside `onSelect` to create dynamic toggles.
2. **Modular Menus**: Use `submenu` properties to keep your configuration clean and organized.
3. **Hybrid Input**: Keep `enableMouse` and keyboard controls active to give users choice.
4. **Error Handling**: Use `titleColor = colors.red` for warning menus to make them stand out.

---

## 🔄 Migration Guide

If you are coming from the basic menu system, update your `utils.menu` calls:

**BASIC:**
```lua
local choice = utils.menu({ items = {"A", "B"} })
```

**ENHANCED:**
```lua
-- All your old calls still work! 
-- To add mouse support, just add:
local choice = utils.menu({ 
    items = {"A", "B"},
    enableMouse = true 
})
```
