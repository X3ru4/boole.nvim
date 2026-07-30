boole.nvim 🔛
=============

Boole is a simple Neovim plugin that extends the default increment and
decrement functionality of CTRL-A and CTRL-X to allow for toggling
boolean values like `on`, `yes`, and `true` as well as cycling through:

* Days of the week and their abbreviations (e.g., `Monday` → `Tuesday`)
* Months of the year and their abbreviations (e.g., `Jan` → `Feb`)
* X11 / Web color names (e.g., `Orange` → `OrangeRed`)

This plugin ships one command:

* `:Boole {increment|decrement}`

This command can be safely mapped to CTRL-A and CTRL-X. See the
configuration section below for an example.

Installation
------------

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  "X3ru4/boole.nvim",
  keys = { "<C-a>", "<C-x>" },
  opts = {},
}
```

Configuration
-------------

Boole can be mapped to a key by passing a configuration table to the 
`setup` function. You can also use the presets or add your own cycles.

```lua
require('boole').setup({
  -- Use these presets if you don't need much configuration.
  -- Valid presets: "boolean", "colors", "months", "weekdays"
  presets = {
    "boolean",
    "colors",
  -- ...
  },
  -- Default mappings.
  mappings = {
    increment = "<C-a>",
    decrement = "<C-x>",
  },
  -- Define cycles
  additions = {
    { "Foo", "Bar" },
    { "tic", "tac", "toe" },
  },
  allow_caps_additions = {
    { "enable", "disable" },
    -- enable → disable
    -- Enable → Disable
    -- ENABLE → DISABLE
  },
})
```
