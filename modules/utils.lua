-- modules/utils.lua
-- version 2.0.1
-- Changed: Unified menu system with better styling and pagination

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
-- UNIFIED MENU SYSTEM
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
    
    local selected = 1
    local termWidth, termHeight = term.getSize()
    local headerLines = 1  -- title only
    local footerLines = 1  -- separator
    local instructionLines = allowQuit and 2 or 1
    local availableLines = termHeight - headerLines - footerLines - instructionLines
    local firstVisible = 1
    
    local function drawMenu()
        term.clear()
        term.setCursorPos(1, 1)
        
        -- Title bar
        term.setBackgroundColor(titleColor)
        term.setTextColor(colors.white)
        term.clearLine()
        term.write(title)
        term.setBackgroundColor(colors.black)
        
        -- Calculate visible range
        if selected < firstVisible then
            firstVisible = selected
        elseif selected > firstVisible + availableLines - 1 then
            firstVisible = selected - availableLines + 1
        end
        
        -- Draw menu items
        local currentLine = headerLines + 1
        for i = firstVisible, math.min(firstVisible + availableLines - 1, #items) do
            term.setCursorPos(1, currentLine)
            
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
            
            -- Highlight selected item
            if i == selected then
                term.setBackgroundColor(selectedColor)
                term.setTextColor(selectedTextColor)
                term.clearLine()
                term.write("> " .. displayText)
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
            else
                term.setTextColor(colors.white)
                term.write("  " .. displayText)
            end
            
            currentLine = currentLine + 1
        end
        
        -- Footer separator
        term.setCursorPos(1, termHeight - instructionLines)
        term.setTextColor(colors.gray)
        term.write(string.rep("-", termWidth))
        
        -- Instructions
        term.setCursorPos(1, termHeight - instructionLines + 1)
        term.setTextColor(colors.lightGray)
        term.write(message)
        
        if allowQuit then
            term.setCursorPos(1, termHeight)
            term.write("Press 'q' to quit")
        end
        
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
    end
    
    drawMenu()
    
    -- Event loop
    while true do
        local event, key = os.pullEvent("key")
        
        if key == keys.up then
            selected = selected > 1 and selected - 1 or #items
            drawMenu()
            
        elseif key == keys.down then
            selected = selected < #items and selected + 1 or 1
            drawMenu()
            
        elseif key == keys.enter then
            term.clear()
            term.setCursorPos(1, 1)
            
            if returnIndex then
                return selected
            else
                return items[selected], selected
            end
            
        elseif allowQuit and key == keys.q then
            term.clear()
            term.setCursorPos(1, 1)
            return nil, nil
        end
    end
end

-- Quick simple menu for string arrays
function utils.quickMenu(title, items)
    return utils.menu({
        title = title,
        items = items,
        returnIndex = true
    })
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
            allowQuit = options.allowQuit
        })
        
        if not selected then
            -- User pressed 'q' to quit
            break
        end
        
        -- Handle actions
        if type(selected) == "table" then
            if selected.submenu then
                -- Recursive submenu
                utils.actionMenu({
                    title = selected.submenu.title or selected.name or "Submenu",
                    items = selected.submenu.items or selected.submenu,
                    allowQuit = true
                })
            elseif selected.action then
                -- Execute action
                term.clear()
                term.setCursorPos(1, 1)
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
