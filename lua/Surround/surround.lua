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

    local spair_target, epair_target = Pair.get(target)

    if spair_target then
        local ex, scol, ecol = P.walk_pair(col, line, spair_target, epair_target)

        if not ex and not scol then
            return U.wprint(('Pair %s not found'):format(target))
        end

        local spair_repl, epair_repl = Pair.get(repl, repl)

        if not ex then
            U.replace_pair(row, scol, ecol, spair_repl, epair_repl)
        else
            local srow_ex, scol_ex, erow_ex, ecol_ex = P.walk_pair_extended(row, spair_target, epair_target)
            if srow_ex and erow_ex then
                U.replace_ex_pair(srow_ex, erow_ex, scol_ex, ecol_ex, spair_repl, epair_repl)
            end
        end
    else
        local scol, ecol = P.walk_char(col, line, target)

        if not scol then
            return U.wprint(('Pattern %s not found'):format(target))
        end

        local spair_repl, epair_repl = Pair.get(repl, repl)
        U.replace_pair(row, scol, ecol, spair_repl, epair_repl)
    end
end

local H = {
    'hello',
    'hello',
    'hello',
    { { 'hello' } },
    'hello',
    'hello',
    'hello',
    'hello',
    'hello',
    'hello',
    'hello',
}

local I = {
    { 1 },
    { 2 },
    { 3 },
    { 4 },
    { 4 },
    { 5 },
}

return S
