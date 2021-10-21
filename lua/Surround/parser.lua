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

function P.walk_pair(col, line, spair, epair)
    local function inner(start, haystack)
        local s, e = line:find('%b' .. spair .. epair, start)

        if not s or not e then
            return haystack
        end

        if e > col then
            haystack[s] = e
        end

        return inner(s + 1, haystack)
    end

    local list = inner(1, {})
    local score, idx = nil, nil
    local coll = col + 1

    for sidx, _ in pairs(list) do
        if sidx <= coll then
            local diff = col - sidx
            if not score or diff < score then
                score, idx = diff, sidx
            end
        end
    end

    return list, idx, list[idx]
end

return P
