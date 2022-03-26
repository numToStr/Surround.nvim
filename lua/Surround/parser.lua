local A = vim.api
local P = {}

---Find position of linear pairs ie. '"
---@param col number Column number
---@param line string Current line
---@param pair string Pair to search
---@return number number Starting position of pair
---@return number number Ending position of pair
function P.walk_char(col, line, pair)
    local reverse = false
    local pat_esc = vim.pesc(pair)
    local pattern = pat_esc .. '.-' .. pat_esc

    local function inner_char(start)
        local start_idx, end_idx = line:find(pattern, start)

        if not start_idx or not end_idx then
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
        if reverse and (end_idx < col and start_idx < col) then
            return start_idx, end_idx
        end

        -- If the start + end of the pattern is greater than the cursor
        -- If the cursor is in b/w the pattern's start and end
        if (start_idx > col and end_idx > col) or (start_idx <= col and end_idx > col) then
            return start_idx, end_idx
        end

        return inner_char(end_idx - 1)
    end

    return inner_char(1)
end

---Find position of combine-pairs ie. () [] {}
---@param col number Current column position
---@param line string Current line
---@param spair string Opening pair
---@param epair string Closing pair
---@return number number Starting position of pair
---@return number number Ending position of pair
function P.walk_pair(col, line, spair, epair)
    local score, sidx, eidx
    local coll = col + 1
    local pattern = '%b' .. spair .. epair

    local function inner_pair(start)
        local start_idx, end_idx = line:find(pattern, start)

        -- When both idx are nil, It could means eol or pairs not found
        if not start_idx or not end_idx then
            -- NOTE: this is the place where search for extended pairs begin
            -- true : If pairs not found in the line
            -- false : If search reaches the end of line
            return not score, sidx, eidx
        end

        -- If starting and ending pair is away from cursor then it means we can easily replace
        -- This is only valid before giving any score to other pairs
        -- We can also say this as `lookahead`
        if not score and start_idx > col and end_idx > col then
            return false, start_idx, end_idx
        end

        -- To qualify as the pairs the cursor should be in b/w opening and closing pair
        if start_idx <= coll and end_idx >= coll then
            -- To solve the nested the pairs problem, we need to find the closest opening pair
            -- We can give each pair a score to determine the distance b/w the opening pair and the cursor
            -- Pair with smallest score will win and has to be the closest pairs to cursor
            local diff = col - start_idx
            if not score or diff < score then
                score, sidx, eidx = diff, start_idx, end_idx
            end
        end

        -- Then we repeat this until all the pairs are analyzed
        return inner_pair(start_idx + 1)
    end

    return inner_pair(1)
end

local function process_first_half(row, spair, epair)
    local first_half = A.nvim_buf_get_lines(0, 0, row - 1, false)
    local pattern = '([' .. vim.pesc(spair) .. vim.pesc(epair) .. '])'
    local stack = {}

    local function inner(ln, srow)
        local found, idx, wat = ln:find(pattern, srow)

        if not found then
            return stack[#stack]
        end

        if wat == spair then
            table.insert(stack, idx)
        end

        if wat == epair then
            table.remove(stack)
        end

        return inner(ln, idx + 1)
    end

    for i = #first_half, 1, -1 do
        local found = inner(first_half[i], 1)
        if found then
            return i, found
        end
    end
end

local function process_second_half(row, spair, epair)
    local second_half = A.nvim_buf_get_lines(0, row, -1, false)
    local pattern = '([' .. vim.pesc(spair) .. vim.pesc(epair) .. '])'
    local opening_count = 0

    local function inner(ln, srow)
        local found, idx, wat = ln:find(pattern, srow)

        if found then
            if opening_count == 0 and wat == epair then
                return idx
            end

            if wat == spair then
                opening_count = opening_count + 1
            end

            if wat == epair then
                opening_count = opening_count - 1
            end

            return inner(ln, idx + 1)
        end
    end

    for i, line in ipairs(second_half) do
        local found = inner(line, 1)
        if found then
            return row + i, found
        end
    end
end

-- TODO async maybe
---Find position of combine-pairs over multiptle lines
---@param row number Current line number
---@param spair string Opening pair
---@param epair string Closing pair
---@return number number Starting row
---@return number number Starting column
---@return number number Ending row
---@return number number Ending column
function P.walk_pair_extended(row, spair, epair)
    local srow, scol = process_first_half(row, spair, epair)
    local erow, ecol = process_second_half(row, spair, epair)

    return srow, scol, erow, ecol
end

return P
