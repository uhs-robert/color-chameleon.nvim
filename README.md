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
  Dynamically <strong>adapt your skin</strong> to the environment you're in, <strong>like a chameleon</strong>.
</p>

> [!WARNING]
> Still under construction. Almost done though. Ready to release on December 19th 2025.

## 🦎 Overview

**color-chameleon.nvim** lets you set conditional rules for when a colorscheme should be applied.

These rules are evaluated in order from top-to-bottom on `VimEnter`, `DirectoryChange`, and `BufEnter`; the first matching rule wins.

This allows you to dynamically apply colorschemes based on any condition, the only limit is your imagination.

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
  - Buffer properties (filetype, buffer type)
  - Custom functions/conditions (any logic you can write)
- **Flexible Logic**: Combine conditions with AND logic, use arrays for OR logic
- **Smart Switching**: Preserves your previous colorscheme when leaving special contexts
- **Buffer-Aware**: Considers both global working directory and individual buffer paths
- **Zero Configuration**: Works out of the box, but highly customizable
- **Lightweight**: Minimal performance impact

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

### 👨‍⚖️ Rule Structure

Each rule can have the following fields:

- `path` (string or array, optional): Directory path(s) to match. Paths are expanded and symlinks are resolved. Use an array to match any of multiple paths.
- `colorscheme` (string, required): The colorscheme to apply when this rule matches.
- `env` (table, optional): Environment variable conditions to check.
  - Key: environment variable name
  - Value:
    - `true` = check if variable exists
    - `false` = check if variable doesn't exist
    - string = check if variable equals this exact value
- `filetype` (string or array, optional): Buffer filetype(s) to match (e.g., `"markdown"`, `"python"`, or `{"lua", "vim"}`). Use an array to match any of multiple filetypes.
- `buftype` (string or array, optional): Buffer type(s) to match (e.g., `"terminal"`, `"help"`, or `{"quickfix", "nofile"}`). Use an array to match any of multiple buffer types.
- `condition` (function, optional): Custom function that receives the current working directory and returns a boolean.

> [!IMPORTANT]
>
> Rules are evaluated in order. The first matching rule wins.
>
> **All conditions in a rule must match** (AND logic). For example, a rule with both `path` and `filetype` will only match if the current directory matches the path AND the buffer filetype matches.
>
> **Arrays within a field use OR logic**. For example, `filetype = {"json", "yaml"}` matches if the filetype is `"json"` OR `"yaml"`.

Refer to [Usage](#-usage) below for examples of each and [Use Cases](#-use-cases) for real world examples.

## 🚀 Usage

The power is in your hands; create rules that match your unique workflow.

Below are practical examples organized from simple to advanced. Start with the basics, then explore the combinations that fit your needs.

### 🖌️ Basic Configuration

Switch theme when in a specific directory:

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
Different themes for different directories:

```lua
require("color-chameleon").setup({
  enabled = true,
  rules = {
    { path = "~/work/", colorscheme = "tokyonight" },
    { path = "~/personal/", colorscheme = "catppuccin" },
    { path = "~/mnt/", colorscheme = "oasis-mirage" },
  },
})
```

<!-- multiple-directories:end -->
</details>

<details>
<summary>🌦️ Environment-Based Switching</summary>
<br>
<!-- environment-switching:start -->

Change themes based on any `vim.env` variable. These are ENV variables from your OS.

```lua
require("color-chameleon").setup({
  enabled = true,
  rules = {
    { colorscheme = "gruvbox", env = { SSH_CONNECTION = true } }, -- Applies when in an SSH session
    { colorscheme = "tokyonight", env = { TMUX = true } }, -- Applies when in TMUX
    { path = "~/work/", colorscheme = "catppuccin", env = { WORK_ENV = "production" } }, -- Applies when path AND env are both true
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

Use `:ChameleonEnv` to see the ENV variables being used in your current environment.

<!-- environment-switching:end -->
</details>

<details>
<summary>📄 Buffer Properties (Filetype & Buftype)</summary>
<br>
<!-- buffer-properties:start -->

Change theme based on buffer properties like filetype or buffer type:

```lua
require("color-chameleon").setup({
  enabled = true,
  rules = {
    -- Simple filetype matching
    { filetype = "markdown", colorscheme = "nord" },
    { filetype = "python", colorscheme = "gruvbox" },

    -- Buffer type matching
    { buftype = "terminal", colorscheme = "tokyonight" },
    { buftype = "help", colorscheme = "catppuccin" },

    -- Combine path + filetype (both must match)
    {
      path = "~/notes/",
      filetype = "markdown",
      colorscheme = "nord"
    },

    -- Combine path + buftype
    {
      path = "~/work/",
      buftype = "terminal",
      colorscheme = "gruvbox"
    },
  },
})
```

**Common filetypes**: `markdown`, `python`, `lua`, `javascript`, `typescript`, `rust`, `go`, etc.

**Common buftypes**:

- `""` (empty string) - Normal file buffers
- `"terminal"` - Terminal buffers
- `"help"` - Help documentation
- `"quickfix"` - Quickfix/location lists
- `"nofile"` - Scratch buffers

<!-- buffer-properties:end -->
</details>

<details>
<summary>🔀 OR Logic with Arrays</summary>
<br>
<!-- or-logic:start -->

You can use arrays to match **any of** multiple values (OR logic). This works for `path`, `filetype`, and `buftype`:

```lua
require("color-chameleon").setup({
  enabled = true,
  rules = {
    -- Match ANY of these filetypes
    { filetype = {"json", "yaml", "toml", "xml"}, colorscheme = "nord" },

    -- Match ANY of these paths
    { path = {"~/work/client-a/", "~/work/client-b/"}, colorscheme = "gruvbox" },

    -- Match ANY of these buffer types
    { buftype = {"help", "quickfix", "nofile"}, colorscheme = "catppuccin" },

    -- Combine: Match ANY filetype AND a specific path (both conditions must match)
    {
      path = "~/notes/",
      filetype = {"markdown", "text", "org"},
      colorscheme = "tokyonight"
    },

    -- Multiple arrays: Match ANY path AND ANY filetype
    {
      path = {"~/projects/rust/", "~/projects/go/"},
      filetype = {"rust", "go"},
      colorscheme = "gruvbox"
    },
  },
})
```

**How it works:**

- Arrays within a field use OR logic: match **any** value
- Multiple fields use AND logic: **all** must match

<!-- or-logic:end -->
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

<!-- custom-conditions:end -->
</details>

<details>
<summary>🤞 Combine It All</summary>
<br>
<!-- multiple-contexts:start -->
Combine multiple conditions for powerful context-aware theming. All conditions in a rule must match:

```lua
local is_remote = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil
local uid = (vim.uv or vim.loop).getuid()
local is_sudoedit = vim.env.SUDOEDIT == "1" -- This requires your shell's config to export a flag like: SUDO_EDITOR="env SUDOEDIT=1 /usr/bin/nvim"
local is_root = is_sudoedit or uid == 0

require("color-chameleon").setup({
  enabled = true,
  rules = {
     -- Custom conditions for root/remote contexts
    { colorscheme = "oasis-abyss", condition = function() return is_root and is_remote end },
    { colorscheme = "oasis-sol", condition = function() return is_root end },
    { colorscheme = "oasis-dune", condition = function() return is_remote end },
    { path = "~/mnt/", colorscheme = "oasis-mirage" },

    -- Combine path + environment
    { path = "~/work/", env = { NODE_ENV = "production" }, colorscheme = "tokyonight" },

    -- Combine path + filetype
    { path = "~/notes/", filetype = "markdown", colorscheme = "catppuccin" },

    -- ALL conditions combined: path + env + filetype + buftype + custom function
    -- This rule only matches when ALL of these are true:
    {
      path = "~/projects/sensitive/",           -- In sensitive projects directory
      env = { SSH_CONNECTION = true },          -- AND in an SSH session
      filetype = {"lua", "md"},                 -- AND editing a Lua or Md file
      buftype = "",                             -- AND it's a normal file (not terminal/help/etc)
      condition = function(cwd)                 -- AND a .secure marker file exists
        return vim.fn.filereadable(cwd .. "/.secure") == 1
      end,
      colorscheme = "gruvbox"
    },

  },
  fallback = "oasis", -- Default theme for normal contexts
})
```

<!-- multiple-contexts:end -->
</details>

> [!TIP]
> Now that you know how the plugin works, check out [Use Cases](#-use-cases) below for some real world examples.

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

-- Enable/disable programmatically
chameleon.toggle()
chameleon.enable()
chameleon.disable()

-- Check status
chameleon.status()

-- Run test to see what rules match in current context
chameleon.test()

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

## 💼 Use Cases

Real-world scenarios to inspire your workflow:

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
  -- Match multiple filetypes with an array (recommended)
  { filetype = {"json", "yaml", "toml", "xml"}, colorscheme = "onedark" },

  -- Or use individual rules
  { filetype = "json", colorscheme = "onedark" },
  { filetype = "yaml", colorscheme = "onedark" },
  { filetype = "toml", colorscheme = "onedark" },
  { filetype = "xml", colorscheme = "onedark" },

  -- Or use a condition for complex logic
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
  -- Simple buffer type matching
  { buftype = "terminal", colorscheme = "tokyonight" },

  -- Combine with path for project-specific terminal themes
  {
    path = "~/work/",
    buftype = "terminal",
    colorscheme = "gruvbox"
  },

  -- Help buffers
  { buftype = "help", colorscheme = "nord" },

  -- Normal file buffers only (exclude special buffers)
  { buftype = "", colorscheme = "catppuccin" },
}
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🙏 Acknowledgments

Inspired by my other plugin [oasis.nvim](https://github.com/uhs-robert/oasis.nvim) which has... a lot of themes to pick from!

With so much variety, why not visually distinguish between your different working contexts in NeoVim?
