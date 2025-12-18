<p align="center">
  <img
    src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f98e.svg"
    width="auto" height="128" alt="logo" />
</p>
<h1 align="center">color-chameleon.nvim</h1>
<p align="center">
  <a href="https://github.com/uhs-robert/color-chameleon.nvim/stargazers"><img src="https://img.shields.io/github/stars/uhs-robert/color-chameleon.nvim?colorA=192330&colorB=khaki&style=for-the-badge&cacheSeconds=4300"></a>
  <a href="https://github.com/uhs-robert/color-chameleon.nvim/issues"><img src="https://img.shields.io/github/issues/uhs-robert/color-chameleon.nvim?colorA=192330&colorB=skyblue&style=for-the-badge&cacheSeconds=4300"></a>
  <a href="https://github.com/uhs-robert/color-chameleon.nvim/contributors"><img src="https://img.shields.io/github/contributors/uhs-robert/color-chameleon.nvim?colorA=192330&colorB=8FD1C7&style=for-the-badge&cacheSeconds=4300"></a>
  <a href="https://github.com/uhs-robert/color-chameleon.nvim/network/members"><img src="https://img.shields.io/github/forks/uhs-robert/color-chameleon.nvim?colorA=192330&colorB=C799FF&style=for-the-badge&cacheSeconds=4300"></a>
</p>
<p align="center">
Automatically <strong>adapt your colorscheme</strong> to your environment, just <strong>like a chameleon</strong>.
</p>

## 🦎 Overview

**color-chameleon.nvim** lets you set rules for when a colorscheme should be applied. First matching rule wins!

Set colorschemes for projects, environment variables, custom conditions, and/or combinations of each.

Dynamically adapt your skin to the environment you're in and switch back automatically too.

<details>
<summary>✨ What's New / 🚨 Breaking Changes</summary>
<br/>
<!-- whats-new:start -->

  <details>
    <summary>🚨 v0.1: Launch Party</summary>
    <!-- v0:start -->
    <h3>✨ FEATURES: New features go here</h3>
    This is the initial launch. New features will go here in subsequent releases. Feel free to continue onto the next section.
    <br/>
    <h3>🚨 BREAKING CHANGE: Breaking changes go here</h3>
    Nothing broken yet! Check back later.
    <br/>
    <!-- v0:end -->
  </details>
<!-- whats-new:end -->
</details>

## ✨ Features

- **Context-Aware Colorschemes**: Automatically switch colorschemes based on:
  - Working directory (local vs remote/mounted filesystems)
  - Environment variables (SSH sessions, sudo, TMUX, custom vars)
  - Custom conditions (any logic you can write)
- **Smart Switching**: Preserves your previous colorscheme when leaving special contexts
- **Buffer-Aware**: Considers both global working directory and individual buffer paths
- **Zero Configuration**: Works out of the box, but highly customizable
- **Lightweight**: Minimal performance impact with smart caching

## 📦 Installation

Install the theme with your preferred package manager, such as
[folke/lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "uhs-robert/color-chameleon.nvim",
  lazy = false,
  priority = 900,
  config = function()
    require("color-chameleon").setup({
      enabled = true,
      rules = {
        { path = "~/mnt/", colorscheme = "gruvbox" },
      },
    })
  end
}
```

Or via [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "uhs-robert/color-chameleon.nvim",
  config = function()
    require("color-chameleon").setup({
      enabled = true,
      rules = {
        { path = "~/mnt/", colorscheme = "gruvbox" },
      },
    })
  end
}
```

## 🚀 Usage

### 🖌️ Basic Configuration

Enable automatic colorscheme switching for mounted filesystems:

```lua
require("color-chameleon").setup({
  enabled = true,
  rules = {
    { path = "~/mnt/", colorscheme = "oasis-mirage" }, -- check out oasis.nvim for a cool colorscheme pack!
  },
  fallback = "oasis", -- Optional: colorscheme when no rules match
})
```

### 🎨 Advanced Examples

<details>
<summary>🗃️ Multiple Directories</summary>
<br>
<!-- multiple-directories:start -->
Switch to different themes for different project directories:

```lua
require("color-chameleon").setup({
  enabled = true,
  rules = {
    { path = "~/work/", colorscheme = "tokyonight" },
    { path = "~/personal/", colorscheme = "catppuccin" },
    { path = "~/mnt/", colorscheme = "oasis" },
  },
})
```

<!-- multiple-directories:end -->
</details>

<details>
<summary>🌦️ Environment-Based Switching</summary>
<br>
<!-- environment-switching:start -->

Change themes based on any `vim.env` variables. These are ENV variables from your OS. Use `:ChameleonEnv` to see the ones being used in your current environment:

```lua
require("color-chameleon").setup({
  enabled = true,
  rules = {
    -- Use gruvbox when in an SSH session
    { colorscheme = "gruvbox", env = { SSH_CONNECTION = true } },
    -- Use tokyonight when in TMUX
    { colorscheme = "tokyonight", env = { TMUX = true } },
    -- Combine path and environment
    { path = "~/work/", colorscheme = "catppuccin", env = { WORK_ENV = "production" } },
  },
})
```

Boolean values like `true|false` simply check for existence while `string` values check exact matches like so:

```lua
rules = {
  -- Check if variable exists
  { colorscheme = "gruvbox", env = { SSH_CONNECTION = true } },
  -- Check if variable doesn't exist
  { colorscheme = "tokyonight", env = { TMUX = false } },
  -- Check for exact value
  { colorscheme = "nord", env = { NODE_ENV = "production" } },
  -- Multiple conditions (all must match)
  { colorscheme = "catppuccin", env = { SSH_CONNECTION = true, TMUX = true } },
}
```

<!-- environment-switching:end -->
</details>

<details>
<summary>🧩 Custom Conditions</summary>
<br>
<!-- custom-conditions:start -->
Use custom functions for any logic you can imagine. The `condition` function receives the current working directory and should return a boolean:

```lua
require("color-chameleon").setup({
  enabled = true,
  rules = {
    -- Check for a specific file in the directory
    {
      path = "~/projects/",
      colorscheme = "nord",
      condition = function(cwd)
        return vim.fn.filereadable(cwd .. "/.use-nord-theme") == 1
      end
    },
    -- Use different theme during night hours
    {
      colorscheme = "gruvbox",
      condition = function()
        local hour = tonumber(os.date("%H"))
        return hour >= 20 or hour < 6
      end
    },
  },
})
```

For more advanced examples, see the [Use Cases](#-use-cases) section below.

<!-- custom-conditions:end -->
</details>

<details>
<summary>🤞 Combine Multiple Contexts</summary>
<br>
<!-- multiple-contexts:start -->
 Switch themes based on whether you're root, remote, or doing a sudoedit with your own custom logic:

```lua
local is_remote = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil
local uid = (vim.uv or vim.loop).getuid()
local is_sudoedit = vim.env.SUDOEDIT == "1" -- This requires your shell's config to export a flag like: SUDO_EDITOR="env SUDOEDIT=1 /usr/bin/nvim"
local is_root = is_sudoedit or uid == 0

require("color-chameleon").setup({
  enabled = true,
  rules = {
    -- Theme for root/elevated AND working remote contexts
    { colorscheme = "oasis-abyss", condition = function() return is_root and is_remote end },
    -- Theme for root/elevated contexts
    { colorscheme = "oasis-sol", condition = function() return is_root end },
    -- Theme for remote sessions
    { colorscheme = "oasis-dune", condition = function() return is_remote end },
    -- Theme for mounted filesystems
    { path = "~/mnt/", colorscheme = "oasis-mirage" },
  },
  fallback = "oasis", -- Default theme for normal contexts
})
```

<!-- multiple-contexts:end -->
</details>

### 🔧 API Commands

Color Chameleon provides the following commands:

- `:ChameleonStatus` - Show current status and configuration
- `:ChameleonToggle` - Toggle camouflage mode on/off
- `:ChameleonEnable` - Enable camouflage mode
- `:ChameleonDisable` - Disable camouflage mode
- `:ChameleonEnv` - Show your current `vim.env` variables
- `:ChameleonTest` - Test which rule matches in current context
- `:ChameleonReload` - Reload configuration and reapply rules
- `:ChameleonDebug` - Toggle debug mode

<details>
<summary>Lua API</summary>
<br>
<!-- lua-api:start -->

```lua
local chameleon = require("color-chameleon")

-- Toggle camouflage mode
chameleon.toggle()

-- Enable/disable programmatically
chameleon.enable()
chameleon.disable()

-- Check status
chameleon.status()

-- List environment variables
chameleon.env()

-- Reload configuration
chameleon.reload()

-- Toggle debug mode
chameleon.debug()
```

<!-- lua-api:end -->
</details>

### 🎹 Keymapping

Default keybindings, when enabled, under `<leader>C` (fully customizable):

| Keymap       | Command            | Description                |
| ------------ | ------------------ | -------------------------- |
| `<leader>Cc` | `:ChameleonToggle` | Toggle camouflage mode     |
| `<leader>Cv` | `:ChameleonEnv`    | Show environment variables |
| `<leader>Cs` | `:ChameleonStatus` | Show chameleon status      |
| `<leader>Cd` | `:ChameleonDebug`  | Toggle debug mode          |
| `<leader>Cr` | `:ChameleonReload` | Reload configuration       |
| `<leader>Ct` | `:ChameleonTest`   | Test rule matching         |

Refer to [configuration](-configuration) below on how to disable or customize.

## ⚙️ Configuration

### 🍦 Default Options

```lua
require("color-chameleon").setup({
  enabled = false,  -- Set to true to enable automatic switching
  debug = false,    -- Set to true to enable debug logging
  rules = {},       -- Array of rule tables (see examples above)
  fallback = nil,   -- Colorscheme when no rules match (nil = restore previous)
  keymaps = true,   -- Set to false to disable, or pass a table to customize:
  -- keymaps = {
  --   lead_prefix = "<leader>C",  -- Default prefix (default: "<leader>C")
  --   keymaps = {                 -- Override individual keys
  --     toggle = "<leader>Cc",
  --     env = "<leader>Cv",
  --     status = "<leader>Cs",
  --     debug = "<leader>Cd",
  --     reload = "<leader>Cr",
  --     test = "<leader>Ct"
  --   },
  -- },
})
```

### 👨‍⚖️ Rule Structure

Each rule can have the following fields:

- `path` (string, optional): Directory path to match. Paths are expanded and symlinks are resolved.
- `colorscheme` (string, required): The colorscheme to apply when this rule matches.
- `env` (table, optional): Environment variable conditions to check.
  - Key: environment variable name
  - Value:
    - `true` = check if variable exists
    - `false` = check if variable doesn't exist
    - string = check if variable equals this exact value
- `condition` (function, optional): Custom function that receives the current working directory and returns a boolean.

> [!IMPORTANT]
>
> Rules are evaluated in order. The first matching rule wins.

## 💼 Use Cases

You might already have an idea from the examples above but here are some use cases that I like to use personally:

### 📡 Distinguish Local vs Remote Work

Instantly know when you're working on remote or mounted filesystems:

```lua
rules = {
  { path = "~/mnt/", colorscheme = "gruvbox" },
  { path = "/mnt/", colorscheme = "gruvbox" },
}
```

### 📁 Different Themes for Different Projects

Visually separate work, personal, and client projects:

```lua
rules = {
  { path = "~/work/client-a/", colorscheme = "tokyonight" },
  { path = "~/work/client-b/", colorscheme = "nord" },
  { path = "~/personal/", colorscheme = "catppuccin" },
}
```

### 🕵️‍♂️ Warning Theme for Elevated Privileges

Use a high-visibility theme when editing as root:

```lua
local uid = (vim.uv or vim.loop).getuid()
local is_sudoedit = vim.env.SUDOEDIT == "1" -- This requires your shell's config to export a flag like: SUDO_EDITOR="env SUDOEDIT=1 /usr/bin/nvim"
local is_root = is_sudoedit or uid == 0

rules = {
  { colorscheme = "gruvbox", condition = function() return is_root end },
}
```

### 🕑️ Time-Based Themes

Automatically switch between light and dark themes based on time of day.

```lua
rules = {
  {
    colorscheme = "catppuccin-latte",
    condition = function()
      local hour = tonumber(os.date("%H"))
      return hour >= 6 and hour < 18  -- 6 AM to 6 PM
    end
  },
  { colorscheme = "catppuccin-mocha" },  -- Fallback for night
}
```

> [!NOTE]
>
> This is just a simple time of day example. You could sync it to your local sunrise/sunset time too.
> This would involve passing your latitude and longitude to a weather API like OpenMeteo or using `sunwait` on Linux.

### 🦀 Project Type Detection

Automatically apply themes based on the type of project you're working on:

```lua
rules = {
  -- Rust projects
  {
    colorscheme = "nord",
    condition = function(cwd)
      return vim.fn.filereadable(cwd .. "/Cargo.toml") == 1
    end
  },
  -- Node.js/JavaScript projects
  {
    colorscheme = "catppuccin",
    condition = function(cwd)
      return vim.fn.filereadable(cwd .. "/package.json") == 1
    end
  },
  -- Python projects
  {
    colorscheme = "tokyonight",
    condition = function(cwd)
      return vim.fn.filereadable(cwd .. "/pyproject.toml") == 1
        or vim.fn.filereadable(cwd .. "/setup.py") == 1
    end
  },
}
```

### 🌿 Git Branch-Based Themes

Use different themes for production branches vs development:

```lua
rules = {
  {
    colorscheme = "gruvbox",  -- High-contrast theme for production
    condition = function()
      local handle = io.popen("git branch --show-current 2>/dev/null")
      if handle then
        local branch = handle:read("*a"):gsub("%s+", "")
        handle:close()
        return branch == "main" or branch == "master"
      end
      return false
    end
  },
}
```

### 📄 Filetype-Specific Themes

Apply specific themes for configuration files or special filetypes:

```lua
rules = {
  {
    colorscheme = "onedark",
    condition = function()
      local ft = vim.bo.filetype
      return ft == "json" or ft == "yaml" or ft == "toml" or ft == "conf"
    end
  },
}
```

### 🔍 Diff Mode & Read-Only Files

Use high-contrast themes when reviewing diffs or editing read-only files:

```lua
rules = {
  -- High contrast for diff mode
  {
    colorscheme = "gruvbox",
    condition = function()
      return vim.wo.diff
    end
  },
  -- Distinct theme for read-only files
  {
    colorscheme = "nord",
    condition = function()
      return vim.bo.readonly or not vim.bo.modifiable
    end
  },
}
```

### 💻 Terminal Buffer Detection

Switch themes when working with terminal buffers (or any buffer type):

```lua
rules = {
  {
    colorscheme = "tokyonight",
    condition = function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
          return true
        end
      end
      return false
    end
  },
}
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🙏 Acknowledgments

Inspired by my other plugin [oasis.nvim](https://github.com/uhs-robert/oasis.nvim) which has... a lot of themes to pick from!

With so much variety, why not visually distinguish between your different working contexts in NeoVim?
