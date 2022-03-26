local Pairs = require('Surround.pairs')
local P = require('Surround.parser')
local U = require('Surround.utils')
local A = vim.api

---Plugin's Config
---@class Config
---@field mappings boolean Create default mappings

---@class Surround
---@field config Config
local S = {}

---Replace target pairs with replacement pairs
---@param target string Target pair
---@param repl string Replacement pair
function S.replacer(target, repl)
    local line = A.nvim_get_current_line()
    local row, col = unpack(A.nvim_win_get_cursor(0))

    local spair_target, epair_target = Pairs:get(target)
    local spair_repl, epair_repl = Pairs:get(repl, repl)

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

---Surround the text with pairs
function S.add(vmode)
    local pair = U.get_char()
    if not pair then
        return U.abort()
    end

    local range = U.get_region(vmode)
    local spair, epair = Pairs:get(pair, pair)

    -- We are in full line mode (yss)
    if range.srow == range.erow and range.scol == range.ecol then
        local line = A.nvim_get_current_line()
        local indent, chars = U.get_indent(line)
        return A.nvim_buf_set_lines(0, range.srow - 1, range.srow, false, {
            indent .. spair .. chars .. epair,
        })
    end

    -- When we are adding pairs on the same line (ysiw | ys{t,f})
    if range.srow == range.erow then
        local line = A.nvim_get_current_line()
        local row, scol, ecol = range.srow - 1, range.scol + 1, range.ecol + 1
        return A.nvim_buf_set_text(0, row, range.scol, row, ecol, {
            spair .. line:sub(scol, ecol) .. epair,
        })
    end

    -- When we are adding pairs over mutliple lines (ys[count]{j,k})
    local srow = range.srow - 1
    local lines = A.nvim_buf_get_lines(0, srow, range.erow, false)

    ----- adjusting indentation -----
    local indent = U.get_indent(lines[1] or '')
    local tabs = (' '):rep(vim.bo.tabstop) -- NOTE: maybe use something other than `tabstop`
    for i, line in ipairs(lines) do
        lines[i] = tabs .. line
    end
    table.insert(lines, 1, indent .. spair)
    table.insert(lines, indent .. epair)
    ----- adjusting indentation -----

    return A.nvim_buf_set_lines(0, srow, range.erow, false, lines)
end

---Change the surrounded pairs
function S.change()
    local target = U.get_char()
    if not target then
        return U.abort()
    end
    local rep = U.get_char()
    if not rep or target == rep then
        return U.abort()
    end
    S.replacer(target, rep)
end

---Deletes the surrounded pairs
function S.delete()
    local target = U.get_char()
    if not target then
        return U.abort()
    end
    S.replacer(target)
end

---Setup the plugin and configure it
---@param cfg Config
function S.setup(cfg)
    S.config = {
        mappings = true,
    }

    if cfg then
        S.config = vim.tbl_extend('force', S.config, cfg)
    end

    -- Default pairs
    Pairs:default()

    if S.config.mappings then
        vim.keymap.set('n', 'cs', '<CMD>lua require"Surround.api".change()<CR>')
        vim.keymap.set('n', 'ds', '<CMD>lua require"Surround.api".delete()<CR>')
        vim.keymap.set('n', 'ys', "<CMD>set operatorfunc=v:lua.require'Surround.api'.add<CR>g@")
        vim.keymap.set('n', 'yss', '<CMD>lua require"Surround.api".add()<CR>')
    end
end

return S
