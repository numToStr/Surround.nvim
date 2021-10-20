local A = vim.api
local P = {}

function P.walk(line, pat)
    local row, col = unpack(A.nvim_win_get_cursor(0))
    local reverse = false

    local function inner(start)
        local s, e = line:find(pat .. '.-' .. pat, start)

        if not s or not e then
            -- Pattern not found even after reverse lookup
            if reverse then
                return
            end

            print(line:reverse())

            -- FIXME better to reverse the string
            reverse = true
            return inner(1)
        end

        -- if the search is revered then we can say that cursor is ahead of the pattern
        if reverse and (e < col and s < col) then
            return s, e
        end

        -- If the start + end of the pattern is greater than the cursor
        -- If the cursor is in b/w the pattern's start and end
        if (s > col and e > col) or (s <= col and e > col) then
            return s, e
        end

        return inner(e - 1)
    end

    return row, inner(1)
end

return P
