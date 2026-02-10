-- modules/utils.lua
-- version 4.0.0
-- Refactored: Improved modularity, fixed sorting, cleaner structure

local utils = {}

----------------------------------------------------------------------------
-- UTILITY FUNCTIONS
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
-- TABLE RENDERING - CORE HELPERS
----------------------------------------------------------------------------
local TableRenderer = {}

-- Extract value from cell (handles color tables)
function TableRenderer.extractValue(cell)
    if type(cell) == "table" and cell.value ~= nil then
        return cell.value
    end
    return cell or ""
end

-- Auto-detect headers from data
function TableRenderer.detectHeaders(data)
    if not data[1] then return {} end
    
    local headers = {}
    for k in pairs(data[1]) do
        table.insert(headers, k)
    end
    table.sort(headers)
    return headers
end

-- Calculate column widths with smart truncation
function TableRenderer.calculateColumnWidths(headers, data, maxWidth, spacing)
    local colWidths = {}
    local totalSpacing = (#headers - 1) * spacing
    local maxColWidth = math.floor((maxWidth - totalSpacing) / #headers)
    
    for _, h in ipairs(headers) do
        colWidths[h] = #h
        for _, row in ipairs(data) do
            local value = TableRenderer.extractValue(row[h])
            colWidths[h] = math.max(colWidths[h], #tostring(value))
        end
        colWidths[h] = math.min(colWidths[h], maxColWidth)
    end
    
    return colWidths
end

-- Sort data by column
function TableRenderer.sortData(data, column, ascending)
    local firstValue = TableRenderer.extractValue(data[1][column])
    local isNumeric = type(firstValue) == "number"
    
    table.sort(data, function(a, b)
        local aVal = TableRenderer.extractValue(a[column])
        local bVal = TableRenderer.extractValue(b[column])
        
        if isNumeric then
            return ascending and (aVal < bVal) or (aVal > bVal)
        else
            return ascending and (tostring(aVal) < tostring(bVal)) or (tostring(aVal) > tostring(bVal))
        end
    end)
end

-- Render column headers
function TableRenderer.renderHeaders(disp, headers, colWidths, x, y, spacing, sortColumn, enableSort, clickableHeaders)
    local cx = x
    
    for _, h in ipairs(headers) do
        disp.setCursorPos(cx, y)
        
        -- Highlight sorted column
        if sortColumn == h then
            disp.setTextColor(colors.yellow)
        else
            disp.setTextColor(colors.lightGray)
        end
        
        local padded = h .. string.rep(" ", math.max(0, colWidths[h] - #h))
        disp.write(string.sub(padded, 1, colWidths[h]))
        
        -- Store clickable region for header
        if enableSort then
            table.insert(clickableHeaders, {
                header = h,
                x = cx,
                y = y,
                width = colWidths[h],
                height = 1
            })
        end
        
        cx = cx + colWidths[h] + spacing
    end
    
    disp.setTextColor(colors.white)
end

-- Render table rows
function TableRenderer.renderRows(disp, headers, data, colWidths, x, y, spacing, startIdx, endIdx, enableRowClick, clickableRows, maxWidth)
    for i = startIdx, endIdx do
        local cx = x
        local cy = y + (i - startIdx) + 1
        
        -- Store clickable region for entire row
        if enableRowClick then
            table.insert(clickableRows, {
                rowIndex = i,
                rowData = data[i],
                x = x,
                y = cy,
                width = maxWidth,
                height = 1
            })
        end
        
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

----------------------------------------------------------------------------
-- TABLE RENDERING - CLICK HANDLERS
----------------------------------------------------------------------------
local ClickHandler = {}

-- Check if click is within header regions and handle sorting
function ClickHandler.processHeaderClick(clickX, clickY, clickableHeaders, sortColumn, sortAscending, data, onSort, onHeaderClick)
    for _, region in ipairs(clickableHeaders) do
        if clickX >= region.x and clickX < region.x + region.width and clickY == region.y then
            -- Toggle sort or change column
            local newSortColumn = region.header
            local newSortAscending = true
            
            if sortColumn == region.header then
                newSortAscending = not sortAscending
            end
            
            -- Sort the data
            TableRenderer.sortData(data, newSortColumn, newSortAscending)
            
            -- Call custom callback if provided
            if onHeaderClick then
                onHeaderClick(region.header, data, newSortAscending)
            end
            
            return true, newSortColumn, newSortAscending
        end
    end
    
    return false, sortColumn, sortAscending
end

-- Check if click is within row regions
function ClickHandler.processRowClick(clickX, clickY, clickableRows, onRowClick)
    for _, region in ipairs(clickableRows) do
        if clickX >= region.x and clickX < region.x + region.width and clickY == region.y then
            if onRowClick then
                onRowClick(region.rowData, region.rowIndex)
            end
            return true
        end
    end
    
    return false
end

----------------------------------------------------------------------------
-- TABLE RENDERING - MAIN FUNCTION
----------------------------------------------------------------------------
function utils.renderTable(options)
    local disp = options.display or term
    local data = options.data
    local x = options.x or 1
    local y = options.y or 1
    local maxWidth = options.maxWidth or disp.getSize()
    local maxHeight = options.maxHeight
    local headers = options.headers or TableRenderer.detectHeaders(data)
    local interactive = options.interactive or false
    local spacing = options.spacing or 1
    local autoClear = options.autoClear ~= false
    
    -- Interactive options
    local enableSort = options.enableSort or false
    local enableRowClick = options.enableRowClick or false
    local onRowClick = options.onRowClick
    local onHeaderClick = options.onHeaderClick
    
    -- Device detection
    local isMonitor = disp ~= term
    local monitorSide = isMonitor and peripheral.getName(disp) or nil
    
    -- Sort state
    local sortColumn = nil
    local sortAscending = true
    
    -- Auto-clear display
    if autoClear then
        disp.clear()
    end
    
    -- Calculate column widths
    local colWidths = TableRenderer.calculateColumnWidths(headers, data, maxWidth, spacing)
    
    -- Clickable regions
    local clickableHeaders = {}
    local clickableRows = {}
    
    -- Render function
    local function render()
        clickableHeaders = {}
        clickableRows = {}
        
        local rowsPerPage = maxHeight or #data
        local startIdx = 1
        local endIdx = math.min(rowsPerPage, #data)
        
        -- Draw headers
        TableRenderer.renderHeaders(disp, headers, colWidths, x, y, spacing, sortColumn, enableSort, clickableHeaders)
        
        -- Draw rows
        TableRenderer.renderRows(disp, headers, data, colWidths, x, y, spacing, startIdx, endIdx, enableRowClick, clickableRows, maxWidth)
    end
    
    -- Handle click events
    local function processClick(clickX, clickY)
        -- Check header clicks
        if enableSort then
            local handled, newSortColumn, newSortAscending = ClickHandler.processHeaderClick(
                clickX, clickY, clickableHeaders, sortColumn, sortAscending, data, nil, onHeaderClick
            )
            
            if handled then
                sortColumn = newSortColumn
                sortAscending = newSortAscending
                render()
                return true
            end
        end
        
        -- Check row clicks
        if enableRowClick then
            local handled = ClickHandler.processRowClick(clickX, clickY, clickableRows, onRowClick)
            if handled then
                render()
                return true
            end
        end
        
        return false
    end
    
    -- Initial render
    render()
    
    -- Interactive mode
    if not interactive then
        return
    end
    
    -- Event handling loop
    local enableTouch = options.enableTouch ~= false
    local enableMouse = options.enableMouse ~= false
    
    while true do
        local eventData = {os.pullEvent()}
        local event = eventData[1]
        
        -- Monitor touch
        if isMonitor and enableTouch and event == "monitor_touch" then
            local side = eventData[2]
            local touchX = eventData[3]
            local touchY = eventData[4]
            
            if side == monitorSide then
                processClick(touchX, touchY)
            end
        
        -- Terminal mouse click
        elseif not isMonitor and enableMouse and event == "mouse_click" then
            local button = eventData[2]
            local mouseX = eventData[3]
            local mouseY = eventData[4]
            
            processClick(mouseX, mouseY)
        
        -- Keyboard navigation (q to quit)
        elseif event == "key" then
            local key = eventData[2]
            if key == keys.q then
                return
            end
        end
    end
end

----------------------------------------------------------------------------
-- MENU SYSTEM - CORE HELPERS
----------------------------------------------------------------------------
local MenuRenderer = {}

function MenuRenderer.calculateDimensions(disp, items, title, message)
    local w, h = disp.getSize()
    local menuWidth = math.min(40, w - 4)
    local menuHeight = math.min(#items + 4, h - 2)
    local startX = math.floor((w - menuWidth) / 2) + 1
    local startY = math.floor((h - menuHeight) / 2) + 1
    
    return menuWidth, menuHeight, startX, startY
end

function MenuRenderer.drawBox(disp, x, y, width, height)
    -- Top border
    disp.setCursorPos(x, y)
    disp.write("+" .. string.rep("-", width - 2) .. "+")
    
    -- Sides
    for i = 1, height - 2 do
        disp.setCursorPos(x, y + i)
        disp.write("|" .. string.rep(" ", width - 2) .. "|")
    end
    
    -- Bottom border
    disp.setCursorPos(x, y + height - 1)
    disp.write("+" .. string.rep("-", width - 2) .. "+")
end

function MenuRenderer.drawTitle(disp, title, startX, startY, menuWidth, titleColor)
    if title then
        disp.setCursorPos(startX + 2, startY + 1)
        disp.setTextColor(titleColor)
        disp.write(string.sub(title, 1, menuWidth - 4))
        disp.setTextColor(colors.white)
    end
end

function MenuRenderer.drawMessage(disp, message, startX, startY, menuWidth)
    if message then
        disp.setCursorPos(startX + 2, startY + 2)
        disp.setTextColor(colors.lightGray)
        disp.write(string.sub(message, 1, menuWidth - 4))
        disp.setTextColor(colors.white)
    end
end

function MenuRenderer.drawItems(disp, items, selected, startX, startY, menuWidth, menuHeight, offset, selectedColor)
    local messageOffset = 0
    local maxVisible = menuHeight - 4
    
    for i = 1, math.min(#items, maxVisible) do
        local idx = i + offset
        if idx <= #items then
            local item = items[idx]
            local itemText = type(item) == "table" and item.name or tostring(item)
            local cy = startY + 2 + messageOffset + i
            
            disp.setCursorPos(startX + 2, cy)
            
            if idx == selected then
                disp.setTextColor(selectedColor)
                disp.write("> " .. string.sub(itemText, 1, menuWidth - 6))
            else
                disp.setTextColor(colors.white)
                disp.write("  " .. string.sub(itemText, 1, menuWidth - 6))
            end
        end
    end
    
    disp.setTextColor(colors.white)
end

----------------------------------------------------------------------------
-- MENU SYSTEM - MAIN FUNCTION
----------------------------------------------------------------------------
function utils.menu(options)
    local disp = options.display or term
    local items = options.items or {}
    local title = options.title
    local message = options.message
    local returnIndex = options.returnIndex or false
    local allowQuit = options.allowQuit or false
    local titleColor = options.titleColor or colors.yellow
    local selectedColor = options.selectedColor or colors.lime
    local immediateExecute = options.immediateExecute or false
    
    -- Interactive options
    local enableTouch = options.enableTouch or false
    local enableMouse = options.enableMouse or false
    
    -- Device detection
    local isMonitor = disp ~= term
    local monitorSide = isMonitor and peripheral.getName(disp) or nil
    
    -- Menu state
    local selected = 1
    local offset = 0
    
    -- Calculate menu dimensions
    local menuWidth, menuHeight, startX, startY = MenuRenderer.calculateDimensions(disp, items, title, message)
    local maxVisible = menuHeight - 4
    
    -- Store clickable regions
    local clickableItems = {}
    
    -- Render function
    local function render()
        disp.clear()
        clickableItems = {}
        
        MenuRenderer.drawBox(disp, startX, startY, menuWidth, menuHeight)
        MenuRenderer.drawTitle(disp, title, startX, startY, menuWidth, titleColor)
        MenuRenderer.drawMessage(disp, message, startX, startY, menuWidth)
        
        -- Draw items and store clickable regions
        local messageOffset = 0
        
        for i = 1, math.min(#items, maxVisible) do
            local idx = i + offset
            if idx <= #items then
                local item = items[idx]
                local itemText = type(item) == "table" and item.name or tostring(item)
                local cy = startY + 2 + messageOffset + i
                
                disp.setCursorPos(startX + 2, cy)
                
                if idx == selected then
                    disp.setTextColor(selectedColor)
                    disp.write("> " .. string.sub(itemText, 1, menuWidth - 6))
                else
                    disp.setTextColor(colors.white)
                    disp.write("  " .. string.sub(itemText, 1, menuWidth - 6))
                end
                
                -- Store clickable region
                if enableTouch or enableMouse then
                    table.insert(clickableItems, {
                        index = idx,
                        x = startX,
                        y = cy,
                        width = menuWidth,
                        height = 1
                    })
                end
            end
        end
        
        disp.setTextColor(colors.white)
    end
    
    -- Handle click events
    local function processClick(clickX, clickY)
        for _, region in ipairs(clickableItems) do
            if clickX >= region.x and clickX < region.x + region.width and clickY == region.y then
                selected = region.index
                
                if immediateExecute then
                    local item = items[selected]
                    if type(item) == "table" and item.action then
                        disp.clear()
                        disp.setCursorPos(1, 1)
                        item.action()
                    end
                end
                
                if returnIndex then
                    return items[selected], selected
                else
                    return items[selected]
                end
            end
        end
        return nil
    end
    
    -- Main event loop
    while true do
        render()
        
        local eventData = {os.pullEvent()}
        local event = eventData[1]
        
        -- Keyboard navigation
        if event == "key" then
            local key = eventData[2]
            
            if key == keys.up and selected > 1 then
                selected = selected - 1
                if selected < offset + 1 then
                    offset = math.max(0, offset - 1)
                end
            elseif key == keys.down and selected < #items then
                selected = selected + 1
                if selected > offset + maxVisible then
                    offset = offset + 1
                end
            elseif key == keys.enter then
                if immediateExecute then
                    local item = items[selected]
                    if type(item) == "table" and item.action then
                        disp.clear()
                        disp.setCursorPos(1, 1)
                        item.action()
                    end
                end
                
                if returnIndex then
                    return items[selected], selected
                else
                    return items[selected]
                end
            elseif key == keys.q and allowQuit then
                return nil
            end
        
        -- Monitor touch
        elseif isMonitor and enableTouch and event == "monitor_touch" then
            local side = eventData[2]
            local touchX = eventData[3]
            local touchY = eventData[4]
            
            if side == monitorSide then
                local result, index = processClick(touchX, touchY)
                if result then
                    return result, index
                end
            end
        
        -- Terminal mouse click
        elseif not isMonitor and enableMouse and event == "mouse_click" then
            local button = eventData[2]
            local mouseX = eventData[3]
            local mouseY = eventData[4]
            
            local result, index = processClick(mouseX, mouseY)
            if result then
                return result, index
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
            break
        end
        
        -- Handle actions (only if not immediate execute)
        if not options.immediateExecute then
            if type(selected) == "table" then
                if selected.submenu then
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
                    local disp = options.display or term
                    disp.clear()
                    disp.setCursorPos(1, 1)
                    local result = selected.action()
                    
                    if result == false then
                        break
                    end
                    
                    if options.waitAfterAction ~= false then
                        print("\nPress R to return...")
                        while true do
                            local event, key = os.pullEvent("key")
                            if key == keys.r then
                                break
                            end
                        end
                    end
                else
                    break
                end
            else
                break
            end
        end
    end
end

----------------------------------------------------------------------------
-- TABLE UTILITIES
----------------------------------------------------------------------------
function utils.sortTable(dataToSort, column, ascending)
    if not dataToSort or #dataToSort == 0 then return dataToSort end
    TableRenderer.sortData(dataToSort, column, ascending ~= false)
    return dataToSort
end

function utils.searchTable(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

----------------------------------------------------------------------------
-- MODULE RETURN
----------------------------------------------------------------------------
return utils
