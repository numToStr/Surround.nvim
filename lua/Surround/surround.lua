local P = require('Surround.parser')
local U = require('Surround.utils')
local A = vim.api

local S = {}

function S.opfunc()
    local target = U.get_char()
    local repl = U.get_char()

    if not target or not repl or (target == repl) then
        return U.abort()
    end

    local line = A.nvim_get_current_line()

    -- local test = "hello world" ' hello

    local row, scol, ecol = P.walk(line, target)

    if not scol then
        return vim.notify('Surround.nvim - Pattern not found ' .. target, vim.log.levels.INFO)
    end

    U.replace_char(row, scol, ecol, repl)
end

return S
