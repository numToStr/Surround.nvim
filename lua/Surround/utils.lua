local A = vim.api
local fn = vim.fn

local U = {}

function U.abort()
    local esc = A.nvim_replace_termcodes('<ESC>', true, true, true)
    A.nvim_feedkeys(esc, 'n', false)
end

function U.is_esc(s)
    return s:find('\27')
end

function U.parse_char()
    local num = fn.getchar()
    if type(num) == 'number' then
        return string.char(num)
    end
    return num
end

function U.get_char()
    local char = U.parse_char()
    if U.is_esc(char) then
        return
    end
    return char
end

function U.replace_char(row, scol, ecol, repl)
    local r, s, e = row - 1, scol - 1, ecol - 1
    A.nvim_buf_set_text(0, r, s, r, scol, { repl })
    A.nvim_buf_set_text(0, r, e, r, ecol, { repl })
end

return U
