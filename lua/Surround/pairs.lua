local P = {
    __pairs = {},
}

---Store opening and closing pair
---@param s string Opening pair
---@param e string Closing pair
function P.set(s, e)
    P.__pairs[s] = { e, true }
    P.__pairs[e] = { s, false }
end

---Get opening and closing pair from a char
---@param p string Pair to search
---@return string string Opening pair
---@return string string Closing pair
function P.get(p)
    local found = P.__pairs[p]
    if not found then
        return
    end

    local pair, is_end = unpack(found)

    if is_end then
        return p, pair
    end

    return pair, p
end

return P
