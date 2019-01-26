local string = string
local tostring = tostring
local table = table
local pairs = pairs
local type = type

local htmlspecialchars_set = {}
htmlspecialchars_set["&"] = "&amp;"
htmlspecialchars_set['"'] = "&quot;"
htmlspecialchars_set["'"] = "&#039;"
htmlspecialchars_set["<"] = "&lt;"
htmlspecialchars_set[">"] = "&gt;"
htmlspecialchars_set[" "] = "&nbsp;"

--[[
    @desc:将特殊字符转为HTML转义符，并返回转换结果，譬如&转为&amp;
    --@input:[#string]
    @return:[#string]
]]
function string.htmlspecialchars(input)
    assert(type(input) == "string", "the pameter of input is not string")
    for k, v in pairs(htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end

--[[
    @desc:将HTML转义符还原为特殊字符，并返回还原结果，譬如&amp;还原成&
    --@input:[#string]
    @return:[#string]
]]
function string.restorehtmlspecialchars(input)
    assert(type(input) == "string", "the pameter of input is not string")
    for k, v in pairs(htmlspecialchars_set) do
        input = string.gsub(input, v, k)
    end
    return input
end

--[[
    @desc:将字符串中的\n换行符转换为HTML标记的<br />，并返回转换结果
    --@input:[#string]
    @return:[#string]
]]
function string.nl2br(input)
    assert(type(input) == "string", "the pameter of input is not string")
    return string.gsub(input, "\n", "<br />")
end

--[[
    @desc:将字符串中的特殊字符、\n换行符转换、\t制表符转换为HTML转义符、标记、4个空格，并返回转换结果
    --@input:[#string]
    @return:[#string]
]]
function string.text2html(input)
    assert(type(input) == "string", "the pameter of input is not string")
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.nl2br(input)
    return input
end

--[[
    @desc:判断字符串是空指针或空字符串
    --@input:[#string]
    @return:[#boolean]
]]
function string.nilorempty(input)
    if input == nil then
        return true
    end
    assert(type(input) == "string", "the pameter of input is not string")
    return input == ""
end

--[[
    @desc:用指定字符或字符串分割输入字符串，返回包含分割结果的数组，如果分割失败均返回一个空数组
    --@input:[#string]
	--@delimiter:[#string]
    @return:[#string<>]
]]
function string.split(input, delimiter)
    assert(type(input) == "string", "the pameter of input is not string")
    assert(type(delimiter) == "string", "the pameter of delimiter is not string")
    if input == "" then
        return {}
    end
    if delimiter == "" then
        return {}
    end
    local pos, arr = 0, {}
    -- for each divider found
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

--[[
    @desc:去除输入字符串头部的空白字符，并返回去除结果
    --@input:[#string] 
    @return:[#string]
]]
function string.ltrim(input)
    assert(type(input) == "string", "the pameter of input is not string")
    return string.gsub(input, "^[ \t\n\r]+", "")
end

--[[
    @desc:去除输入字符串尾部的空白字符，并返回去除结果
    --@input:[#string] 
    @return:[#string]
]]
function string.rtrim(input)
    assert(type(input) == "string", "the pameter of input is not string")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

--[[
    @desc:去除输入字符串头部和尾部的空白字符，并返回去除结果
    --@input:[#string]
    @return:[#string]
]]
function string.trim(input)
    assert(type(input) == "string", "the pameter of input is not string")
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

--[[
    @desc:将字符串的第一个字符转为大写，返回结果
    --@input:[#string]
    @return:[#string]
]]
function string.ucfirst(input)
    assert(type(input) == "string", "the pameter of input is not string")
    return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end

--[[
    @desc:将字符串转换为符合 URL 传递要求的格式，并返回转换结果
    --@input: 
    @return:
]]
function string.urlencode(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

function string.urldecode(input)
    input = string.gsub(input, "+", " ")
    input =
        string.gsub(
        input,
        "%%(%x%x)",
        function(h)
            return string.char(checknumber(h, 16))
        end
    )
    input = string.gsub(input, "\r\n", "\n")
    return input
end

--[[
    @desc:根据utf8首个字节，返回它的长度
    --@char:[#int] 
    @return:[#int]
]]
local function utf8CharSize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

--[[
    @desc:获取一个UTF8字符串包含的字符数量，一个中文是一个字符
    --@input:[#string]
    @return:[#int]
]]
function string.utf8len(input)
    local index = 1
    local cnt = 0
    local len = string.len(input)
    while index <= len do
        local char = string.byte(input, index)
        index = index + utf8CharSize(char)
        cnt = cnt + 1
    end
    return cnt
end

function string.utf8str(input, start_index, end_index)
    local start_byte = 1
    while start_index > 1 do
        local char = string.byte(input, start_byte)
        start_byte = start_byte + utf8CharSize(char)
        start_index = start_index - 1
    end

    local end_byte = 1
    while end_index > 0 do
        local char = string.byte(input, end_byte)
        end_byte = end_byte + utf8CharSize(char)
        end_index = end_index - 1
    end
    end_byte = end_byte - 1

    return input:sub(start_byte, end_byte)
end

function string.formatnumberthousands(num)
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then
            break
        end
    end
    return formatted
end
