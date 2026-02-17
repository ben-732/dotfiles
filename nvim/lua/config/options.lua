local opt = vim.opt

opt.number = true           -- Show line numbers
opt.relativenumber = true   -- Relative line numbers for jumping
opt.splitbelow = true       -- Horizontal splits open below
opt.splitright = true      -- Vertical splits open to the right
opt.ignorecase = true       -- Ignore case in search patterns
opt.smartcase = true        -- ...unless \C or capital in search
opt.termguicolors = true    -- True color support
opt.scrolloff = 8           -- Keep 8 lines above/below cursor
opt.signcolumn = "yes"      -- Always show sign column to avoid flicker
opt.cursorline = true       -- Highlight the current line
opt.updatetime = 250        -- Faster completion/hover response

-- Tabs & Indentation
opt.expandtab = true        -- Use spaces instead of tabs
opt.shiftwidth = 2          -- Size of an indent
opt.tabstop = 2             -- Number of spaces tabs count for
opt.smartindent = true      -- Insert indents automatically
