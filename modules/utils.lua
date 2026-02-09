-- modules/utils.lua
-- version 3.0.0
-- Enhanced: Added immediate execution, monitor support, touch/mouse capabilities

local utils = {}

----------------------------------------------------------------------------
-- UTILITY
----------------------------------------------------------------------------
function utils.writeTableToFile(data)
    local file = fs.open("output.log", "w")
    file.write(textutils.serialize(data, { allow_repetitions = true }))
    file.close()
end

function utils.wrapPeripheral(peripheralType)
    local sides = {"top", "bottom", "left", "right", "front", "back"}
    for _, side in ipairs(sides) do
        if peripheral.isPresent(side) and peripheral.getType(side) == peripheralType then
            local device = peripheral.wrap(side)
            print(peripheralType .. " found on side: " .. side)
            return device, side
        end
    end
    print(peripheralType .. " not found")
    error("", 0)    
end

----------------------------------------------------------------------------
-- TABLE RENDERING
----------------------------------------------------------------------------
function utils.renderTable(options)
    local disp = options.display or term
    local data = options.data
    local x = options.x or 1
    local y = options.y or 1
    local maxWidth = options.maxWidth or disp.getSize()
    local maxHeight = options.maxHeight
    local headers = options.headers -- if nil, auto-detect
    local interactive = options.interactive or false
    local spacing = options.spacing or 1  -- Configurable spacing between columns
    
    -- Auto-detect headers if needed
    if not headers and data[1] then
        headers = {}
        for k in pairs(data[1]) do
            table.insert(headers, k)
        end
        table.sort(headers)
    end
    
    -- Calculate column widths with smart truncation
    local colWidths = {}
    local totalSpacing = (#headers - 1) * spacing  -- Total space used by gaps
    local maxColWidth = math.floor((maxWidth - totalSpacing) / #headers)
    
    for _, h in ipairs(headers) do
        colWidths[h] = #h
        for _, row in ipairs(data) do
            local value = type(row[h]) == "table" and row[h].value or row[h]
            colWidths[h] = math.max(colWidths[h], #tostring(value or ""))
        end
        colWidths[h] = math.min(colWidths[h], maxColWidth)
    end
    
    -- Render function
    local function render(page, startRow)
        page = page or 1
        startRow = startRow or 0
        
        local rowsPerPage = maxHeight or (#data - startRow)
        local startIdx = startRow + 1
        local endIdx = math.min(startIdx + rowsPerPage - 1, #data)
        
        -- Draw headers
        local cx = x
        for _, h in ipairs(headers) do
            disp.setCursorPos(cx, y)
            disp.setTextColor(colors.lightGray)
            disp.write(string.sub(h, 1, colWidths[h]))
            cx = cx + colWidths[h] + spacing
        end
        
        -- Draw rows
        for i = startIdx, endIdx do
            cx = x
            local cy = y + (i - startIdx) + 1
            for _, h in ipairs(headers) do
                disp.setCursorPos(cx, cy)
                local cell = data[i][h]
                
                if type(cell) == "table" and cell.value then
                    disp.setTextColor(colors[cell.color] or colors.white)
                    disp.write(string.sub(tostring(cell.value), 1, colWidths[h]))
                else
                    disp.setTextColor(colors.white)
                    disp.write(string.sub(tostring(cell or ""), 1, colWidths[h]))
                end
                cx = cx + colWidths[h] + spacing
            end
        end
        
        disp.setTextColor(colors.white)
    end
    
    render(1, 0)
    
    -- Optional interactivity
    if interactive then
        local page = 1
        local totalPages = math.ceil(#data / (maxHeight or 10))
        while true do
            local _, key = os.pullEvent("key")
            if key == keys.q or key == keys.enter then break
            elseif key == keys.right and page < totalPages then
                page = page + 1
                render(page, (page-1) * maxHeight)
            elseif key == keys.left and page > 1 then
                page = page - 1
                render(page, (page-1) * maxHeight)
            end
        end
    end
end

----------------------------------------------------------------------------
-- UNIFIED MENU SYSTEM (ENHANCED)
----------------------------------------------------------------------------

-- Main menu function with all features
function utils.menu(options)
    -- Parse options
    local title = options.title or "Menu"
    local items = options.items or options
    local message = options.message or "Use arrow keys to navigate"
    local titleColor = options.titleColor or colors.blue
    local selectedColor = options.selectedColor or colors.lime
    local selectedTextColor = options.selectedTextColor or colors.black
    local allowQuit = options.allowQuit ~= false  -- default true
    local numbered = options.numbered ~= false    -- default true
    local returnIndex = options.returnIndex or false
    
    -- NEW OPTIONS
    local display = options.display or term  -- Support for monitors
    local immediateExecute = options.immediateExecute or false  -- Execute on select (no enter)
    local enableTouch = options.enableTouch ~= false  -- default true for monitors
    local enableMouse = options.enableMouse ~= false  -- default true for terminals
    
    -- Determine if we're using a monitor or terminal
    local isMonitor = display ~= term
    local monitorSide = isMonitor and peripheral.getName(display) or nil
    
    local selected = 1
    local termWidth, termHeight = display.getSize()
    local headerLines = 1  -- title only
    local footerLines = 1  -- separator
    local instructionLines = allowQuit and 2 or 1
    local availableLines = termHeight - headerLines - footerLines - instructionLines
    local firstVisible = 1
    
    -- Store clickable regions for touch/mouse support
    local clickableRegions = {}
    
    local function drawMenu()
        display.setBackgroundColor(colors.black)
        display.clear()
        display.setCursorPos(1, 1)
        clickableRegions = {}
        
        -- Title bar
        display.setBackgroundColor(titleColor)
        display.setTextColor(colors.white)
        display.clearLine()
        display.write(title)
        display.setBackgroundColor(colors.black)
        
        -- Calculate visible range
        if selected < firstVisible then
            firstVisible = selected
        elseif selected > firstVisible + availableLines - 1 then
            firstVisible = selected - availableLines + 1
        end
        
        -- Draw menu items
        local currentLine = headerLines + 1
        for i = firstVisible, math.min(firstVisible + availableLines - 1, #items) do
            display.setCursorPos(1, currentLine)
            
            local item = items[i]
            local displayText = ""
            
            -- Handle both string items and table items
            if type(item) == "table" then
                displayText = item.name or item.text or item[1] or tostring(item)
            else
                displayText = tostring(item)
            end
            
            -- Add numbering if enabled
            if numbered then
                displayText = i .. ". " .. displayText
            end
            
            -- Store clickable region
            table.insert(clickableRegions, {
                index = i,
                y = currentLine,
                x = 1,
                width = termWidth,
                height = 1
            })
            
            -- Highlight selected item
            if i == selected then
                display.setBackgroundColor(selectedColor)
                display.setTextColor(selectedTextColor)
                display.clearLine()
                display.write("> " .. displayText)
                display.setBackgroundColor(colors.black)
                display.setTextColor(colors.white)
            else
                display.setTextColor(colors.white)
                display.write("  " .. displayText)
            end
            
            currentLine = currentLine + 1
        end
        
        -- Footer separator
        display.setCursorPos(1, termHeight - instructionLines)
        display.setTextColor(colors.gray)
        display.write(string.rep("-", termWidth))
        
        -- Instructions
        display.setCursorPos(1, termHeight - instructionLines + 1)
        display.setTextColor(colors.lightGray)
        local inputMethod = ""
        if isMonitor and enableTouch then
            inputMethod = "Touch to select"
        elseif not isMonitor and enableMouse then
            inputMethod = "Click or arrow keys"
        else
            inputMethod = message
        end
        display.write(inputMethod)
        
        if allowQuit then
            display.setCursorPos(1, termHeight)
            display.write("Press 'q' to quit")
        end
        
        display.setTextColor(colors.white)
        display.setBackgroundColor(colors.black)
    end
    
    local function handleSelection()
        if immediateExecute then
            -- Execute immediately without clearing screen
            local item = items[selected]
            if type(item) == "table" then
                if item.onSelect then
                    item.onSelect(item, selected)
                    drawMenu()  -- Redraw after execution
                    return "continue"
                elseif item.action then
                    item.action(item, selected)
                    drawMenu()  -- Redraw after execution
                    return "continue"
                end
            end
        end
        
        -- Normal selection return
        display.clear()
        display.setCursorPos(1, 1)
        
        if returnIndex then
            return "return", selected
        else
            return "return", items[selected], selected
        end
    end
    
    local function processClick(x, y)
        -- Check if click is on a menu item
        for _, region in ipairs(clickableRegions) do
            if y == region.y and x >= region.x and x < region.x + region.width then
                selected = region.index
                drawMenu()
                
                -- If immediate execute is enabled, execute now
                if immediateExecute then
                    return handleSelection()
                end
                
                return "selected"
            end
        end
        return "continue"
    end
    
    drawMenu()
    
    -- Event loop with touch/mouse support
    while true do
        local eventData = {os.pullEvent()}
        local event = eventData[1]
        
        -- Keyboard navigation
        if event == "key" then
            local key = eventData[2]
            
            if key == keys.up then
                selected = selected > 1 and selected - 1 or #items
                drawMenu()
                
            elseif key == keys.down then
                selected = selected < #items and selected + 1 or 1
                drawMenu()
                
            elseif key == keys.enter then
                local status, result1, result2 = handleSelection()
                if status == "return" then
                    return result1, result2
                end
                
            elseif allowQuit and key == keys.q then
                display.clear()
                display.setCursorPos(1, 1)
                return nil, nil
            end
        
        -- Monitor touch support
        elseif isMonitor and enableTouch and event == "monitor_touch" then
            local side = eventData[2]
            local x = eventData[3]
            local y = eventData[4]
            
            if side == monitorSide then
                local status, result1, result2 = processClick(x, y)
                if status == "return" then
                    return result1, result2
                end
            end
        
        -- Terminal mouse click support
        elseif not isMonitor and enableMouse and event == "mouse_click" then
            local button = eventData[2]
            local x = eventData[3]
            local y = eventData[4]
            
            local status, result1, result2 = processClick(x, y)
            if status == "return" then
                return result1, result2
            end
        end
    end
end

-- Quick simple menu for string arrays
function utils.quickMenu(title, items, options)
    options = options or {}
    options.title = title
    options.items = items
    options.returnIndex = true
    return utils.menu(options)
end

-- Menu with automatic action execution
function utils.actionMenu(options)
    local title = options.title or "Menu"
    local items = options.items
    
    while true do
        local selected, index = utils.menu({
            title = title,
            items = items,
            message = options.message,
            titleColor = options.titleColor,
            selectedColor = options.selectedColor,
            allowQuit = options.allowQuit,
            display = options.display,
            immediateExecute = options.immediateExecute,
            enableTouch = options.enableTouch,
            enableMouse = options.enableMouse
        })
        
        if not selected then
            -- User pressed 'q' to quit
            break
        end
        
        -- Handle actions (only if not immediate execute, since that's handled in menu())
        if not options.immediateExecute then
            if type(selected) == "table" then
                if selected.submenu then
                    -- Recursive submenu
                    utils.actionMenu({
                        title = selected.submenu.title or selected.name or "Submenu",
                        items = selected.submenu.items or selected.submenu,
                        allowQuit = true,
                        display = options.display,
                        immediateExecute = options.immediateExecute,
                        enableTouch = options.enableTouch,
                        enableMouse = options.enableMouse
                    })
                elseif selected.action then
                    -- Execute action
                    local disp = options.display or term
                    disp.clear()
                    disp.setCursorPos(1, 1)
                    local result = selected.action()
                    
                    -- If action returns false, exit menu
                    if result == false then
                        break
                    end
                    
                    -- Wait for user to continue
                    if options.waitAfterAction ~= false then
                        print("\nPress any key to continue...")
                        os.pullEvent("key")
                    end
                else
                    -- No action defined, just return the selection
                    break
                end
            else
                -- Simple string selection, exit menu
                break
            end
        end
    end
end

----------------------------------------------------------------------------
-- EVENT HANDLING - TOUCH HANDLER
----------------------------------------------------------------------------
function utils.createTouchHandler(disp, elements)
    elements = elements or {}
    local isTerminal = (disp == term)
    
    local handler = {
        elements = elements,
        disp = disp
    }
    
    function handler.register(id, x, y, width, height, callback)
        table.insert(handler.elements, {
            id = id,
            x = x,
            y = y,
            width = width,
            height = height,
            callback = callback
        })
        return handler
    end
    
    function handler.processEvent(x, y)
        for _, element in ipairs(handler.elements) do
            if x >= element.x and x < element.x + element.width and
               y >= element.y and y < element.y + element.height then
                if element.callback then
                    return element.callback(element, x, y)
                end
                return element.id
            end
        end
        return nil
    end
    
    function handler.listen()
        while true do
            if isTerminal then
                local event, button, x, y = os.pullEvent("mouse_click")
                handler.processEvent(x, y)
            else
                local event, side, x, y = os.pullEvent("monitor_touch")
                if side == peripheral.getName(disp) then
                    handler.processEvent(x, y)
                end
            end
        end
    end
    
    function handler.listenAsync()
        parallel.waitForAny(
            function() handler.listen() end,
            function() while true do sleep(600) end end
        )
    end
    
    function handler.clear()
        handler.elements = {}
        return handler
    end
    
    function handler.remove(id)
        for i = #handler.elements, 1, -1 do
            if handler.elements[i].id == id then
                table.remove(handler.elements, i)
            end
        end
        return handler
    end
    
    return handler
end

----------------------------------------------------------------------------
-- MODULE RETURN
----------------------------------------------------------------------------
return utils
