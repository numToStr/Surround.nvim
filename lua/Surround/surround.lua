local Pair = require('Surround.pairs')
local P = require('Surround.parser')
local U = require('Surround.utils')
local A = vim.api

local S = {}

function S.setup()
    -- Default pairs
    Pair.set('(', ')')
    Pair.set('[', ']')
    Pair.set('{', '}')
    Pair.set('<', '>')
end

function S.opfunc()
    local target = U.get_char()
    if not target then
        return U.abort()
    end

    local repl = U.get_char()
    if not repl or (target == repl) then
        return U.abort()
    end

    local line = A.nvim_get_current_line()
    local row, col = unpack(A.nvim_win_get_cursor(0))

    -- local test = 'hello world' ' hello

    -- print()
    -- print(Pair.get(rep() ) hehe(lo ( fhfhfh) ) hfhfhfh)

    local spair, epair = Pair.get(target)

    -- local h, f = P.walk_pair(col, line, spair, epair)

    dump(P.walk_pair(col, line, spair, epair))

    -- local scol, ecol = P.walk_char(col, line, target)
    --
    -- if not scol then
    --     return vim.notify(('Surround :: Pattern %s not found'):format(target), vim.log.levels.WARN)
    -- end
    --
    -- U.replace_pair(row, scol, ecol, repl)
end

return S
