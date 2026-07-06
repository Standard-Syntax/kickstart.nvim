-- ~/.config/nvim/after/ftplugin/rust.lua
-- Rust-specific keymaps powered by rustaceanvim.
-- This file is auto-loaded by Neovim whenever a Rust buffer is opened.
-- rustaceanvim uses :RustLsp subcommands rather than the old :Rust* namespace.

local bufnr = vim.api.nvim_get_current_buf()

local map = function(keys, func, desc)
  vim.keymap.set('n', keys, func, { silent = true, buffer = bufnr, desc = 'Rust: ' .. desc })
end

-- Hover actions (expanded rust-analyzer hover with macro expansion, doc links, etc.)
map('K', function() vim.cmd.RustLsp { 'hover', 'actions' } end, 'Hover Actions')

-- Code action (with rust-analyzer grouping)
map('<leader>a', function() vim.cmd.RustLsp 'codeAction' end, 'Code Action')

-- Runnables (cargo run / tests picker)
map('<leader>rr', function() vim.cmd.RustLsp 'runnables' end, 'Runnables')

-- Debuggables (DAP configurations picker)
map('<leader>rd', function() vim.cmd.RustLsp 'debuggables' end, 'Debuggables')

-- Expand macro under cursor
map('<leader>rm', function() vim.cmd.RustLsp 'expandMacro' end, 'Expand Macro')

-- View HIR / MIR (useful for compiler internals / debugging)
map('<leader>rh', function() vim.cmd.RustLsp { 'view', 'hir' } end, 'View HIR')

-- Fly-check: run clippy in the background and surface diagnostics via LSP
map('<leader>rc', function() vim.cmd.RustLsp 'flyCheck' end, 'Clippy (flyCheck)')

-- Open the current Rust file/expression in the Rust Playground
map('<leader>rp', function() vim.cmd.RustLsp 'openDocs' end, 'Open Docs (docs.rs)')
