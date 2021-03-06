local A = vim.api
local mark = A.nvim_buf_get_mark
local U = {}

---@alias VMode 'line'|'char'|'v'|'V' Vim Mode. Read `:h map-operator`

---Range of the selection that needs to be commented
---@class SRange
---@field srow number Starting row
---@field scol number Starting column
---@field erow number Ending row
---@field ecol number Ending column

---Surround action
---@class Action
---@field add number Includes ys, yS, yss, ySs, ySS
---@field change number Includes cs, cS
---@field delete number Includes ds
U.action = {
    add = 0,
    change = 1,
    delete = 2,
}

---Prints a warning
---@param msg string
function U.wprint(msg)
    return vim.notify('[Surround] ' .. msg, vim.log.levels.WARN)
end

---Abort the current operation
function U.abort()
    local esc = A.nvim_replace_termcodes('<ESC>', true, true, true)
    A.nvim_feedkeys(esc, 'ni', false)
end

---Check if a string is <ESC> key
---@param s string
function U.is_esc(s)
    return s:find('\27')
end

---Get a input from the user and parse it into char
---@return string
function U.parse_char()
    local num = vim.fn.getchar()
    if type(num) == 'number' then
        return string.char(num)
    end
    return num
end

---Get a key from the user and checks if <ESC> is pressed
---@return string
function U.get_char()
    local char = U.parse_char()
    if U.is_esc(char) then
        return nil
    end
    return char
end

function U.get_indent(ln)
    return ln:match('(%s*)(.*)')
end

---Get region for line movement or visual selection
---NOTE: Returns the current line, if `vmode` is not given.
---@param vmode? VMode
---@return SRange
function U.get_region(vmode)
    if not vmode then
        local row, col = unpack(A.nvim_win_get_cursor(0))
        return { srow = row, scol = col, erow = row, ecol = col }
    end

    local buf = 0
    local sln, eln

    if vmode:match('[vV]') then
        sln, eln = mark(buf, '<'), mark(buf, '>')
    else
        sln, eln = mark(buf, '['), mark(buf, ']')
    end

    return { srow = sln[1], scol = sln[2], erow = eln[1], ecol = eln[2] }
end

---Replace pairs on the same line
---@param row number Line number
---@param scol number Starting column
---@param ecol number Ending column
---@param s_pair string Opening pairs
---@param e_pair string Closing pairs
function U.replace_pair(row, scol, ecol, s_pair, e_pair)
    local r, s, e = row - 1, scol - 1, ecol - 1
    A.nvim_buf_set_text(0, r, e, r, ecol, { e_pair })
    A.nvim_buf_set_text(0, r, s, r, scol, { s_pair })
end

---Replace pairs in-between multiple line
---@param srow number Starting row
---@param erow number Ending row
---@param scol number Starting column
---@param ecol number Ending column
---@param s_pair string Opening pairs
---@param e_pair string Closing pairs
function U.replace_ex_pair(srow, erow, scol, ecol, s_pair, e_pair)
    local sr, er, sc, ec = srow - 1, erow - 1, scol - 1, ecol - 1
    A.nvim_buf_set_text(0, er, ec, er, ecol, { e_pair })
    A.nvim_buf_set_text(0, sr, sc, sr, scol, { s_pair })
end

return U
