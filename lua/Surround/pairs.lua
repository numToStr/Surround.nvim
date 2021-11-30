---@class Pairs
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
---@param pair string Pair to search
---@param default string (Optional) Pair char if pairs not found in the set
---@return string string Opening pair
---@return string string Closing pair
function P.get(pair, default)
    local found = P.__pairs[pair]
    if not found then
        return default, default
    end

    local pp, is_end = unpack(found)

    if is_end then
        return pair, pp
    end

    return pp, pair
end

return P
