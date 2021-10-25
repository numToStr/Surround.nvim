local function find_br(line, spair, epair)
    local stack = {}

    local function inner(srow)
        local found, idx, wat = line:find('^.-([%' .. spair .. '%' .. epair .. '])', srow)

        if found then
            if wat == spair then
                table.insert(stack, 1, idx)
            end

            if wat == epair then
                stack[1] = nil
            end

            return inner(idx + 1)
        else
            return stack[1]
        end
    end

    return inner(1)
end

dump(find_br('1. ( () (', '(', ')'))
