local P = {}

function P.walk_char(col, line, pat)
    local reverse = false
    local patt = vim.pesc(pat)

    local function inner_char(start)
        local s, e = line:find(patt .. '.-' .. patt, start)

        if not s or not e then
            -- Pattern not found even after reverse lookup
            if reverse then
                return
            end

            -- print(line:reverse())

            -- FIXME better to reverse the string
            reverse = true
            return inner_char(1)
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

        return inner_char(e - 1)
    end

    return inner_char(1)
end

-- TODO lookahead
function P.walk_pair(col, line, spair, epair)
    local score, sidx, eidx
    local coll = col + 1

    local function inner_pair(start)
        local s, e = line:find('%b' .. spair .. epair, start)

        if not s or not e then
            return sidx, eidx
        end

        -- To qualify as the pairs the cursor should be in b/w opening and closeing pair
        if s <= coll and e >= coll then
            -- To solve the nested the pairs problem, we need to find the closest opening pair
            -- We can give each pair a score to determine the distance b/w the opening pair and the cursor
            -- Pair with smallest score will win and has to be the closest pairs to cursor
            local diff = col - s
            if not score or diff < score then
                score, sidx, eidx = diff, s, e
            end
        end

        -- Then we repeat this until all the pairs are analyzed
        return inner_pair(s + 1)
    end

    return inner_pair(1)
end

return P
