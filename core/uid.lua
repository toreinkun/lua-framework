local _uid = 0
setglobal("uid", function()
    _uid = _uid + 1
    return _uid
end ) 