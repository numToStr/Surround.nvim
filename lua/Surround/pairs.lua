local P = {
    __pairs = {},
}

---Default pairs
function P.default()
    P.set('(', ')').set('[', ']').set('{', '}').set('<', '>')
end

---Store opening and closing pair
---@param s string Opening pair
---@param e string Closing pair
function P.set(s, e)
    P.__pairs[s] = { e, true } -- end pair is true
    P.__pairs[e] = { s, false }
    return P
end

---Get opening and closing pair from a char
---@param p string Pair to search
---@param d string (Optional) Pair char if pairs not found in the set
---@return string string Opening pair
---@return string string Closing pair
function P.get(p, d)
    local found = P.__pairs[p]
    if not found then
        return d, d
    end

    local pair, is_end = unpack(found)

    if is_end then
        return p, pair
    end

    return pair, p
end

return P
