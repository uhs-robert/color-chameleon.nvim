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

color-chameleon.nvim lets you set rules for when a colorscheme should be applied.

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
  priority = 1000,
  config = function()
    require("color-chameleon").setup({
      camouflage = {
        enabled = true,
        rules = {
          { path = "~/mnt/", colorscheme = "gruvbox" },
        },
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
      camouflage = {
        enabled = true,
        rules = {
          { path = "~/mnt/", colorscheme = "gruvbox" },
        },
      },
    })
  end
}
```

## 🚀 Usage

### Basic Configuration

Enable automatic colorscheme switching for mounted filesystems:

```lua
require("color-chameleon").setup({
  camouflage = {
    enabled = true,
    rules = {
      { path = "~/mnt/", colorscheme = "oasis-mirage" }, -- check out oasis.nvim for a cool colorscheme pack!
    },
    fallback = "oasis", -- Optional: colorscheme when no rules match
  },
})
```

### Advanced Examples

<details>
<summary>🖌️ Multiple Directories</summary>
<br>
<!-- multiple-directories:start -->
Switch to different themes for different project directories:

```lua
require("color-chameleon").setup({
  camouflage = {
    enabled = true,
    rules = {
      { path = "~/work/", colorscheme = "tokyonight" },
      { path = "~/personal/", colorscheme = "catppuccin" },
      { path = "~/mnt/", colorscheme = "oasis" },
    },
  },
})
```

<!-- multiple-directories:end -->
</details>

<details>
<summary>🖌️ Environment-Based Switching</summary>
<br>
<!-- environment-switching:start -->

Change themes based on any `vim.env` variables. These are ENV variables from your OS. Use `:ChameleonEnv` to see the ones being used in your current environment:

```lua
require("color-chameleon").setup({
  camouflage = {
    enabled = true,
    rules = {
      -- Use gruvbox when in an SSH session
      { colorscheme = "gruvbox", env = { SSH_CONNECTION = true } },
      -- Use tokyonight when in TMUX
      { colorscheme = "tokyonight", env = { TMUX = true } },
      -- Combine path and environment
      { path = "~/work/", colorscheme = "catppuccin", env = { WORK_ENV = "production" } },
    },
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
<summary>🖌️ Custom Conditions</summary>
<br>
<!-- custom-conditions:start -->
Use custom functions for complex logic:

```lua
require("color-chameleon").setup({
  camouflage = {
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
      -- Use different theme during day/night hours
      {
        colorscheme = "gruvbox",
        condition = function()
          local hour = tonumber(os.date("%H"))
          return hour >= 20 or hour < 6
        end
      },
      -- TODO: Add example for sudo
    },
  },
})
```

<!-- custom-conditions:end -->
</details>

<details>
<summary>🖌️ Combine Multiple Contexts</summary>
<br>
<!-- multiple-contexts:start -->
 Switch themes based on whether you're root, remote, or doing a sudoedit with your own custom logic:

```lua
local is_remote = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil
local uid = (vim.uv or vim.loop).getuid()
local is_sudoedit = vim.env.SUDOEDIT == "1" -- This requires your shell's config to export a flag like: SUDO_EDITOR="env SUDOEDIT=1 /usr/bin/nvim"
local is_root = is_sudoedit or uid == 0

require("color-chameleon").setup({
  camouflage = {
    enabled = true,
    rules = {
      -- Red theme for root/elevated contexts
      { colorscheme = "oasis-sol", condition = function() return is_root end },
      -- Different theme for remote sessions
      { colorscheme = "oasis-dune", condition = function() return is_remote end },
      -- Mounted filesystems
      { path = "~/mnt/", colorscheme = "oasis-mirage" },
    },
    fallback = "oasis", -- Default theme for normal contexts
  },
})
```

<!-- multiple-contexts:end -->
</details>

### API Commands

Color Chameleon provides the following commands:

- `:ChameleonStatus` - Show current status and configuration
- `:ChameleonEnable` - Enable camouflage mode
- `:ChameleonDisable` - Disable camouflage mode
- `:ChameleonEnv` - Show your current `vim.env` variables

<details>
<summary>Lua API</summary>
<br>
<!-- lua-api:start -->

```lua
local chameleon = require("color-chameleon")

-- Enable/disable programmatically
chameleon.enable()
chameleon.disable()

-- Check status
chameleon.status()

-- List environment variables
chameleon.env()
```

<!-- lua-api:end -->
</details>

## ⚙️ Configuration

### Default Options

```lua
require("color-chameleon").setup({
  camouflage = {
    enabled = false,  -- Set to true to enable automatic switching
    rules = {},       -- Array of rule tables (see examples above)
    fallback = nil,   -- Colorscheme when no rules match (nil = restore previous)
  },
})
```

### Rule Structure

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

## 🎨 Use Cases

You might already have an idea from the examples above but here are some use cases that I like to use personally:

### Distinguish Local vs Remote Work

Instantly know when you're working on remote or mounted filesystems:

```lua
rules = {
  { path = "~/mnt/", colorscheme = "gruvbox" },
  { path = "/mnt/", colorscheme = "gruvbox" },
}
```

### Different Themes for Different Projects

Visually separate work, personal, and client projects:

```lua
rules = {
  { path = "~/work/client-a/", colorscheme = "tokyonight" },
  { path = "~/work/client-b/", colorscheme = "nord" },
  { path = "~/personal/", colorscheme = "catppuccin" },
}
```

### Warning Theme for Elevated Privileges

Use a high-visibility theme when editing as root:

```lua
local uid = (vim.uv or vim.loop).getuid()
local is_sudoedit = vim.env.SUDOEDIT == "1" -- This requires your shell's config to export a flag like: SUDO_EDITOR="env SUDOEDIT=1 /usr/bin/nvim"
local is_root = is_sudoedit or uid == 0

rules = {
  { colorscheme = "gruvbox", condition = function() return is_root end },
}
```

### Time-Based Themes

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

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🙏 Acknowledgments

Inspired by my other plugin [oasis.nvim](https://github.com/uhs-robert/oasis.nvim) which has... a lot of themes to pick from!

With so much variety, why not visually distinguish between your different working contexts in NeoVim?
