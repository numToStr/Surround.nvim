local P = {}

function P.walk_char(col, line, pat)
    local reverse = false
    local patt = vim.pesc(pat)

    local function inner(start)
        local s, e = line:find(patt .. '.-' .. patt, start)

        if not s or not e then
            -- Pattern not found even after reverse lookup
            if reverse then
                return
            end

            -- print(line:reverse())

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

    return inner(1)
end

function P.walk_pair()
    -- TODO pairs logic
end

return P
