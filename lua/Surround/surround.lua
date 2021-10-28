local Pairs = require('Surround.pairs')
local P = require('Surround.parser')
local U = require('Surround.utils')
local A = vim.api

local S = {}

---OpFunc
---@param _ any
---@param action Action
function S.opfunc(_, action)
    local target = U.get_char()
    if not target then
        return U.abort()
    end

    local repl
    if action == U.action.change then
        repl = U.get_char()
        if not repl or (target == repl) then
            return U.abort()
        end
    end

    local line = A.nvim_get_current_line()
    local row, col = unpack(A.nvim_win_get_cursor(0))

    local spair_target, epair_target = Pairs.get(target)
    local spair_repl, epair_repl = Pairs.get(repl, repl)

    if spair_target then
        local ex, scol, ecol = P.walk_pair(col, line, spair_target, epair_target)

        if not ex and not scol then
            return U.wprint(('Pair %s not found'):format(target))
        end

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

        U.replace_pair(row, scol, ecol, spair_repl, epair_repl)
    end
end

function S.ys()
    S.opfunc(nil, U.action.add)
end

function S.cs()
    S.opfunc(nil, U.action.change)
end

function S.ds()
    S.opfunc(nil, U.action.delete)
end

function S.setup()
    -- Default pairs
    Pairs.default()

    -- local map = A.nvim_set_keymap
    -- local map_opt = { noremap = true, silent = true }

    -- map('n', 'cs', "<CMD>lua require('Surround.surround').cs()<CR>", map_opt)
    -- map('n', 'ds', "<CMD>lua require('Surround.surround').ds()<CR>", map_opt)

    --map(
    --    'n',
    --    'gs',
    --    "<CMD>set operatorfunc=v:lua.require'Surround.surround'.opfunc<CR><CMD>lua require('Surround.surround').opfunc()<CR>",
    --    map_opt
    --)
end

return S
