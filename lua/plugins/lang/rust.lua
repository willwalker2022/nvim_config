local enable_lsp = require("config.lsp_servers").enable

local function rust_analyzer_cmd(dispatchers, config)
  local cwd = config.root_dir or vim.uv.cwd()
  local result = vim.system({ "rustup", "which", "rust-analyzer" }, { cwd = cwd, text = true }):wait()
  local executable = result.code == 0 and vim.trim(result.stdout)
    or (vim.fn.stdpath("data") .. "/mason/bin/rust-analyzer")

  return vim.lsp.rpc.start({ executable }, dispatchers, { cwd = cwd })
end

enable_lsp("rust_analyzer", {
  -- Prefer the rust-analyzer shipped with a project's pinned toolchain. This
  -- keeps its Cargo metadata protocol compatible; Mason remains the fallback.
  cmd = rust_analyzer_cmd,
  settings = {
    ["rust-analyzer"] = {
      -- Avoid resolving dependencies for unrelated Windows/Linux/Android
      -- targets while editing on this Apple Silicon Mac.
      cargo = { target = "aarch64-apple-darwin" },
      -- Neovim's client-side watcher can exhaust macOS file descriptors in
      -- large workspaces such as clash-verge-rev.
      files = { watcher = "server" },
    },
  },
})

return {
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "rust-analyzer",
      },
    },
    opts_extend = { "ensure_installed" },
  },
}
