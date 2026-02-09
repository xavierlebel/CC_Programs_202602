--- installer/installer.lua
--- version 1.1.1
--- Simple Program Installer for ComputerCraft
--- Fetches programs from a GitHub repository

local PROGRAMS_URL = "https://raw.githubusercontent.com/xavierlebel/CC_Programs_202602/main/installer/programs.txt"
local args = {...}

-- Extract filename/path from URL
local function getFilenameFromURL(url)
    -- Handle GitHub blob URLs
    url = url:gsub("/blob/", "/")
    
    -- For GitHub raw URLs, extract the path after the branch name
    if url:match("raw%.githubusercontent%.com") then
        -- Pattern: https://raw.githubusercontent.com/user/repo/branch/path/to/file.lua
        local path = url:match("/[^/]+/[^/]+/[^/]+/(.+)$")
        if path then
            return path
        end
    end
    
    -- For regular GitHub URLs, extract path after branch
    if url:match("github%.com") then
        -- Pattern: https://github.com/user/repo/blob/branch/path/to/file.lua
        local path = url:match("/[^/]+/[^/]+/[^/]+/[^/]+/(.+)$")
        if path then
            return path
        end
    end
    
    -- Fallback: Get the last part of the path
    local filename = url:match("([^/]+)$")
    return filename
end

-- Convert GitHub blob URL to raw URL
local function getRawURL(url)
    if url:match("github.com") and url:match("/blob/") then
        url = url:gsub("github.com", "raw.githubusercontent.com")
        url = url:gsub("/blob/", "/")
    end
    return url
end

-- Add cache-busting parameter to URL
local function addCacheBuster(url)
    local separator = url:match("%?") and "&" or "?"
    return url .. separator .. "cb=" .. os.epoch("utc")
end

-- Create directory structure for a file path
local function ensureDirectory(filepath)
    local dir = filepath:match("(.+)/[^/]+$")
    if dir and not fs.exists(dir) then
        fs.makeDir(dir)
    end
end

-- Get just the filename from a path (for display purposes)
local function getBasename(path)
    return path:match("([^/]+)$") or path
end

-- Load programs list from GitHub
local function loadPrograms()
    print("Loading programs list...")
    local response, err = http.get(addCacheBuster(PROGRAMS_URL))
    
    if not response then
        print("ERROR: Failed to download programs list: " .. tostring(err))
        return nil
    end
    
    local content = response.readAll()
    response.close()
    
    local programs = {}
    for line in content:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$") -- trim whitespace
        if line ~= "" and not line:match("^#") then -- skip empty lines and comments
            table.insert(programs, line)
        end
    end
    
    return programs
end

-- Install a program
local function install(programURL)
    if not programURL then
        print("ERROR: Please specify a program URL or name!")
        return false
    end
    
    -- If it's just a name, search for it in the programs list
    local programs = loadPrograms()
    if not programs then
        return false
    end
    
    local targetURL = nil
    if not programURL:match("^https?://") then
        -- Search for program by name
        for _, url in ipairs(programs) do
            local filepath = getFilenameFromURL(url)
            local basename = getBasename(filepath)
            
            if filepath == programURL or filepath == programURL .. ".lua" or
               basename == programURL or basename == programURL .. ".lua" then
                targetURL = url
                break
            end
        end
        
        if not targetURL then
            print("ERROR: Program '" .. programURL .. "' not found!")
            print("Use 'installer list' to see available programs")
            return false
        end
    else
        targetURL = programURL
    end
    
    local filename = getFilenameFromURL(targetURL)
    
    -- Ensure filename has .lua extension
    if not filename:match("%.lua$") then
        filename = filename .. ".lua"
    end
    
    local rawURL = getRawURL(targetURL)
    
    -- Create directory structure if needed
    ensureDirectory(filename)
    
    if fs.exists(filename) then
        print("'" .. filename .. "' already exists!")
        write("Overwrite? (y/n): ")
        local response = read()
        if response:lower() ~= "y" then
            print("Installation cancelled")
            return false
        end
        fs.delete(filename)
    end
    
    print("Downloading '" .. filename .. "'...")
    print("From: " .. rawURL)
    
    local response, err = http.get(addCacheBuster(rawURL))
    if not response then
        print("ERROR: Failed to download: " .. tostring(err))
        return false
    end
    
    local content = response.readAll()
    response.close()
    
    local file = fs.open(filename, "w")
    file.write(content)
    file.close()
    
    print("Successfully installed '" .. filename .. "'!")
    return true
end

-- Update a program (reinstall)
local function update(programName)
    if not programName then
        print("ERROR: Please specify a program to update!")
        return false
    end
    
    print("Updating '" .. programName .. "'...")
    return install(programName)
end

-- Delete a program
local function delete(programName)
    if not programName then
        print("ERROR: Please specify a program to delete!")
        return false
    end
    
    -- Add .lua extension if not present
    if not programName:match("%.lua$") then
        programName = programName .. ".lua"
    end
    
    if not fs.exists(programName) then
        print("ERROR: Program '" .. programName .. "' not found!")
        return false
    end
    
    print("Deleting '" .. programName .. "'...")
    fs.delete(programName)
    print("Successfully deleted '" .. programName .. "'!")
    return true
end

-- Install all programs
local function installAll()
    local programs = loadPrograms()
    if not programs then
        return false
    end
    
    print("Installing all programs (" .. #programs .. ")...")
    print("----------------------------")
    
    local successCount = 0
    local failCount = 0
    
    for i, url in ipairs(programs) do
        local filename = getFilenameFromURL(url)
        print("\n[" .. i .. "/" .. #programs .. "] " .. filename)
        
        if install(url) then
            successCount = successCount + 1
        else
            failCount = failCount + 1
        end
    end
    
    print("\n----------------------------")
    print("Installation complete!")
    print("Success: " .. successCount .. " | Failed: " .. failCount)
    print("----------------------------")
    
    return failCount == 0
end

-- Update all programs
local function updateAll()
    local programs = loadPrograms()
    if not programs then
        return false
    end
    
    print("Updating all programs (" .. #programs .. ")...")
    print("----------------------------")
    
    local successCount = 0
    local failCount = 0
    local skippedCount = 0
    
    for i, url in ipairs(programs) do
        local filename = getFilenameFromURL(url)
        print("\n[" .. i .. "/" .. #programs .. "] " .. filename)
        
        -- Check if file exists (with or without .lua extension)
        local filepath = filename:match("%.lua$") and filename or filename .. ".lua"
        if not fs.exists(filepath) then
            print("Skipped (not installed)")
            skippedCount = skippedCount + 1
        elseif install(url) then
            successCount = successCount + 1
        else
            failCount = failCount + 1
        end
    end
    
    print("\n----------------------------")
    print("Update complete!")
    print("Updated: " .. successCount .. " | Failed: " .. failCount .. " | Skipped: " .. skippedCount)
    print("----------------------------")
    
    return failCount == 0
end

-- List all available programs
local function list()
    local programs = loadPrograms()
    if not programs then
        return
    end

    print("----------------------------")
    print("Available Programs (" .. #programs .. ")")
    print("----------------------------")
    for i, url in ipairs(programs) do
        local filepath = getFilenameFromURL(url)
        print(filepath)
    end
end

-- Show help menu
local function showHelp()
    print("----------------------------")
    print("Program Installer v1.1.1")
    print("----------------------------")
    print("Usage:")
    print("installer list")
    print("installer install <program>")
    print("installer install all")
    print("installer update <program>")
    print("installer update all")
    print("installer delete <program>")
    print("installer help")
    print("")
    print("Examples:")
    print("installer install allmethods.lua")
    print("installer install allmethods")
    print("installer install all")
    print("installer update allmethods")
    print("installer update all")
end

-- Main execution
local function main()
    if #args == 0 then
        showHelp()
        return
    end
    
    local command = args[1]:lower()
    
    if command == "help" then
        showHelp()
    elseif command == "list" then
        list()
    elseif command == "install" then
        if args[2] and args[2]:lower() == "all" then
            installAll()
        else
            install(args[2])
        end
    elseif command == "update" then
        if args[2] and args[2]:lower() == "all" then
            updateAll()
        else
            update(args[2])
        end
    elseif command == "delete" or command == "remove" then
        delete(args[2])
    else
        print("ERROR: Unknown command: " .. command)
        print("Use 'installer help' for usage information")
    end
end

main()
