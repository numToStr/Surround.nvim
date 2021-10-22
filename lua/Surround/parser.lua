local A = vim.api
local P = {}

function P.walk_char(col, line, pat)
    local reverse = false
    local pat_esc = vim.pesc(pat)
    local pattern = pat_esc .. '.-' .. pat_esc

    local function inner_char(start)
        local s, e = line:find(pattern, start)

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

function P.walk_pair(col, line, spair, epair)
    local score, sidx, eidx
    local coll = col + 1
    local pattern = '%b' .. spair .. epair

    local function inner_pair(start)
        local s, e = line:find(pattern, start)

        -- When both idx are nil, It could means eol or pairs not found
        if not s or not e then
            -- NOTE: this is the place where search for extended pairs begin
            -- true : If pairs not found in the line
            -- false : If search reaches the end of line
            return not score, sidx, eidx
        end

        -- If starting and ending pair is away from cursor then it means we can easily replace
        -- This is only valid before giving any score to other pairs
        -- We can also say this as `lookahead`
        if not score and s > col and e > col then
            return false, s, e
        end

        -- To qualify as the pairs the cursor should be in b/w opening and closing pair
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

local function process_first_half(row, s_patrn, e_patrn)
    -- First go up
    -- function op(s)
    --     -- The last matching opening pair
    --     print(s:find('^.*%('))
    -- end
    -- op('hello ( ( fhhffjf')

    local first_half = A.nvim_buf_get_lines(0, 0, row - 1, false)
    local closing_count = 0

    for i = #first_half, 1, -1 do
        local line = first_half[i]

        -- Check if there are closing brackets
        if line:find(e_patrn) then
            closing_count = closing_count + 1
        end

        local is_found, col = line:find(s_patrn)
        if is_found then
            if closing_count == 0 then
                return i, col
            else
                closing_count = closing_count - 1
            end
        end
    end
end

local function process_second_half(row, s_patrn, e_patrn)
    -- Next go down
    -- function ep(s)
    --     The first matching closing pairs
    --     print(s:find('^.-%)'))
    -- end
    --
    -- ep('hello ) ) fhhffjf')

    local second_half = A.nvim_buf_get_lines(0, row, -1, false)
    local opening_count = 0

    for i, line in ipairs(second_half) do
        local is_found, col = line:find(e_patrn)

        -- Check if there are opening brackets
        if line:find(s_patrn) then
            opening_count = opening_count + 1
        end

        if is_found then
            if opening_count == 0 then
                return row + i, col
            else
                opening_count = opening_count - 1
            end
        end
    end
end

-- TODO async maybe
function P.walk_pair_extended(row, spair, epair)
    local s_patrn = '^.*%' .. spair
    local e_patrn = '^.-%' .. epair

    local srow, scol = process_first_half(row, s_patrn, e_patrn)
    local erow, ecol = process_second_half(row, s_patrn, e_patrn)

    return srow, scol, erow, ecol
end

return P
