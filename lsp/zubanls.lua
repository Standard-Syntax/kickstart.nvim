-- ~/.config/nvim/lsp/zubanls.lua
return {
  cmd = { 'zubanls' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
}
