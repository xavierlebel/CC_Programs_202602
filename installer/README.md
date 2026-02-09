# Simple ComputerCraft Installer

A lightweight, easy-to-use installer for ComputerCraft programs that makes managing your Lua scripts effortless.

## Features

- **Simple programs list** - Just a text file with URLs, one per line
- **Batch operations** - Install or update all programs at once
- **Auto-filename extraction** - Automatically extracts filenames from URLs
- **GitHub URL support** - Works with both blob and raw GitHub URLs
- **Easy commands** - Install, update, delete, and list programs
- **No dependencies** - Pure Lua, no external libraries needed
- **Smart caching** - Cache-busting ensures you always get the latest version

## Installation

Download the installer to your ComputerCraft computer:
```lua
wget https://raw.githubusercontent.com/xavierlebel/CC_Programs/main/installer/installer.lua installer
```

The installer automatically fetches the programs list from `installer/programs.txt` in the repository.

## Commands

### List available programs
```
installer list
```
Shows all programs available for installation with their filenames.

### Install programs

Install a single program by name:
```
installer install allmethods.lua
-- or without extension
installer install allmethods
```

Install a program by URL:
```
installer install https://github.com/user/repo/blob/main/program.lua
```

Install all programs from the list:
```
installer install all
```

### Update programs

Update a single program:
```
installer update allmethods
```

Update all installed programs:
```
installer update all
```
*Note: Only updates programs that are already installed. Skips programs not yet installed.*

### Delete a program
```
installer delete allmethods
```

### Show help
```
installer help
```

## Programs.txt Format

Create a `programs.txt` file in the `installer/` directory of your repository with one URL per line:

```
# Comments start with #
# Both formats work:
https://github.com/xavierlebel/CC_Programs/blob/main/allmethods.lua
https://raw.githubusercontent.com/xavierlebel/CC_Programs/main/exampleprogram.lua

# Empty lines are ignored
https://github.com/xavierlebel/CC_Programs/blob/main/anotherprogram.lua
```

The installer will automatically:
- Convert blob URLs to raw URLs
- Extract the filename from the URL
- Skip comments and empty lines
- Create directory structures if your URLs contain paths

## Customization

To use with your own repository, update the `PROGRAMS_URL` constant at the top of `installer.lua`:

```lua
local PROGRAMS_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/installer/programs.txt"
```

## Example Workflow

1. Add your Lua programs to your GitHub repository
2. Add their URLs to `installer/programs.txt`
3. Users download the installer with the `wget` command
4. Users run `installer list` to see available programs
5. Users run `installer install all` to install everything at once
6. Users can update all programs later with `installer update all`

## Advanced Features

### Directory Support
The installer supports programs in subdirectories. For example:
```
https://github.com/user/repo/blob/main/tools/mytool.lua
```
This will create a `tools/` directory and install `mytool.lua` inside it.

### Cache Busting
The installer automatically adds cache-busting parameters to all HTTP requests, ensuring you always download the latest version of files.

### Smart Updates
When running `installer update all`, the installer:
- Only updates programs that are already installed
- Skips programs that haven't been installed yet
- Shows a summary of updated, failed, and skipped programs

## Version

Current version: 1.1.0

## License

Free to use and modify for your ComputerCraft projects!
