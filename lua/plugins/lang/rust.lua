local enable_lsp = require("config.lsp_servers").enable

local function rust_analyzer_cmd(dispatchers, config)
  local cwd = config.root_dir or vim.uv.cwd()
  local executable

  if vim.fn.executable("rustup") == 1 then
    local result = vim.system({ "rustup", "which", "rust-analyzer" }, { cwd = cwd, text = true }):wait()
    if result.code == 0 then
      executable = vim.trim(result.stdout)
    end
  end

  if not executable or executable == "" then
    local mason_executable = vim.fn.stdpath("data") .. "/mason/bin/rust-analyzer"
    executable = vim.fn.executable(mason_executable) == 1 and mason_executable or "rust-analyzer"
  end

  return vim.lsp.rpc.start({ executable }, dispatchers, { cwd = cwd })
end

enable_lsp("rust_analyzer", {
  -- Prefer the rust-analyzer shipped with a project's pinned toolchain. This
  -- keeps its Cargo metadata protocol compatible; Mason remains the fallback.
  cmd = rust_analyzer_cmd,
  settings = {
    ["rust-analyzer"] = {
      -- Let Cargo select the Linux host target or a project-specific target.
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
