# boole.nvim 🔛

Boole is a simple Neovim plugin that extends the default increment and
decrement functionality of CTRL-A and CTRL-X to allow for toggling
boolean values like `on`, `yes`, and `true` as well as cycling through:

- Days of the week and their abbreviations (e.g., `Monday` → `Tuesday`)
- Months of the year and their abbreviations (e.g., `Jan` → `Feb`)
- X11 / Web color names (e.g., `Orange` → `OrangeRed`)

- Changes compared to the original
  - [x] Refactor the code using modern APIs and simple logic.
  - [x] Optimize performance.
  - [x] Several issues have been fixed.
  - [x] Supports special characters.
  - [x] Supports Visual modes.
  - [-] Supports progressive increases and decreases.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  'X3ru4/boole.nvim',
  keys = {
    { mode = { 'n', 'x' }, '<C-a>' },
    { mode = { 'n', 'x' }, '<C-x>' },
    { mode = { 'n', 'x' }, 'g<C-a>' },
    { mode = { 'n', 'x' }, 'g<C-x>' },
  },
  opts = {},
}
```

## Configuration

Boole can be mapped to a key by passing a configuration table to the
`setup` function. You can also use the presets or add your own cycles.

```lua
require('boole').setup({
  -- Use these presets if you don't need much configuration.
  -- Valid presets: 'boolean', 'colors', 'months', 'weekdays'
  presets = {
    'boolean',
    'colors',
  -- ...
  },
  -- The default mappings are `g?<C-a>` and `g?<C-x>`
  use_default_mappings = true,
  -- Define cycles
  additions = {
    { 'Foo', 'Bar' },
    { 'tic', 'tac', 'toe' },
    -- Supports special characters
    { '😭', '🤫' },
    { '₹', '₫', '¶', 'Ω' },
  },
  allow_caps_additions = {
    { 'enable', 'disable' },
    -- enable → disable
    -- Enable → Disable
    -- ENABLE → DISABLE
  },
})
```
