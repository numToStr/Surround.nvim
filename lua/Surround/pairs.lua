local Pairs = {}

return {
    set = function(s, e)
        Pairs[s] = { e, true }
        Pairs[e] = { s, false }
    end,
    get = function(c)
        local found = Pairs[c]
        if not found then
            return
        end

        local pair, is_end = unpack(found)

        if is_end then
            return c, pair
        end

        return pair, c
    end,
}
