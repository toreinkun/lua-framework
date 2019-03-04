--[[
    MIT License

    Copyright (c) 2018 HIBIKI

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]
local string = string
local tostring = tostring
local table = table
local pairs = pairs
local type = type

--[[
    @desc:check the string if it is empty.
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
    @desc:convert html's special characters to escape characters from string.
    --@input:[#string]
    @return:[#string]
]]
function string.htmlspecialchars(input)
    assert(type(input) == "string", "the pameter of input is not string")
    input = string.gsub(input, "&", "&amp;")
    input = string.gsub(input, '"', "&quot;")
    input = string.gsub(input, "'", "&#39;")
    input = string.gsub(input, "<", "&lt;")
    return string.gsub(input, ">", "&gt;")
end

--[[
    @desc:restore html's escape characters to original characters from string.
    --@input:[#string]
    @return:[#string]
]]
function string.restorehtmlspecialchars(input)
    assert(type(input) == "string", "the pameter of input is not string")
    input = string.gsub(input, "&gt;", ">")
    input = string.gsub(input, "&lt;", "<")
    input = string.gsub(input, "&#39;", "'")
    input = string.gsub(input, "&quot;", '"')
    return string.gsub(input, "&amp;", "&")
end

--[[
    @desc:convert the common string to html's string.
    --@input:[#string]
    @return:[#string]
]]
function string.text2html(input)
    assert(type(input) == "string", "the pameter of input is not string")
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    return string.gsub(input, "\n", "<br />")
end

--[[
    @desc:restore the html's string to original string
    --@input:[#string]
    @return:[#string]
]]
function string.html2text(input)
    assert(type(input) == "string", "the pameter of input is not string")
    input = string.gsub(input, "<br />", "\n")
    return string.restorehtmlspecialchars(input)
end

--[[
    @desc:convert xml's special characters to escape characters from string.
    --@input:[#string]
    @return:[#string]
]]
function string.xmlspecialchars(input)
    assert(type(input) == "string", "the pameter of input is not string")
    input = string.gsub(input, "&", "&amp;")
    input = string.gsub(input, '"', "&quot;")
    input = string.gsub(input, "'", "&apos;")
    input = string.gsub(input, "<", "&lt;")
    return string.gsub(input, ">", "&gt;")
end

--[[
    @desc:restore xml's escape characters to original characters from string.
    --@input:[#string]
    @return:[#string]
]]
function string.restorexmlspecialchars(input)
    assert(type(input) == "string", "the pameter of input is not string")
    input = string.gsub(input, "&gt;", ">")
    input = string.gsub(input, "&lt;", "<")
    input = string.gsub(input, "&apos;", "'")
    input = string.gsub(input, "&quot;", '"')
    return string.gsub(input, "&amp;", "&")
end

--[[
    @desc:convert the common string to xml's string.
    --@input:[#string]
    @return:[#string]
]]
function string.text2xml(input)
    assert(type(input) == "string", "the pameter of input is not string")
    return string.xmlspecialchars(input)
end

--[[
    @desc:restore the xml's string to original string
    --@input:[#string]
    @return:[#string]
]]
function string.xml2text(input)
    assert(type(input) == "string", "the pameter of input is not string")
    return string.restorexmlspecialchars(input)
end

--[[
    @desc:use delimiters to split the string.
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
    local pos, arr = 0, {}
    if delimiter == "" then
        for pos = 1, string.len(input) do
            arr[pos] = string.char(string.byte(input, pos))
        end
    else
        -- for each divider found
        for st, sp in function()
            return string.find(input, delimiter, pos, true)
        end do
            table.insert(arr, string.sub(input, pos, st - 1))
            pos = sp + 1
        end
        table.insert(arr, string.sub(input, pos))
    end
    return arr
end

--[[
    @desc:trim spaces from the top side of the string
    --@input:[#string] 
    @return:[#string]
]]
function string.ltrim(input)
    assert(type(input) == "string", "the pameter of input is not string")
    return string.gsub(input, "^%s+", "")
end

--[[
    @desc:trim spaces from the tail side of the string
    --@input:[#string] 
    @return:[#string]
]]
function string.rtrim(input)
    assert(type(input) == "string", "the pameter of input is not string")
    return string.gsub(input, "%s+$", "")
end

--[[
    @desc:trim spaces from both sides of the string
    --@input:[#string]
    @return:[#string]
]]
function string.trim(input)
    assert(type(input) == "string", "the pameter of input is not string")
    return string.gsub(input, "^%s*(.-)%s*$", "%1")
end

--[[
    @desc:convert the top side of character to uppercase
    --@input:[#string]
    @return:[#string]
]]
function string.ucfirst(input)
    assert(type(input) == "string", "the pameter of input is not string")
    return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

--[[
    @desc:encode character to url encoding
    author:zhihao
    --@char:[#string]
    @return:[#string]
]]
local function urlencodechar(char)
    return string.format("%%%02X", string.byte(char))
end

--[[
    @desc:encode string to url encoding
    --@input:[#string] 
    @return:[#string]
]]
function string.urlencode(input)
    assert(type(input) == "string", "the pameter of input is not string")
    -- convert line endings
    input = string.gsub(input, "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

--[[
    @desc:decode string from url encoding
    author:zhihao
    --@input:[#string]
    @return:[#string]
]]
function string.urldecode(input)
    assert(type(input) == "string", "the pameter of input is not string")
    input = string.gsub(input, "+", " ")
    input =
        string.gsub(
        input,
        "%%(%x%x)",
        function(h)
            return string.char(tonumber(h, 16))
        end
    )
    input = string.gsub(input, "\r\n", "\n")
    return input
end

--[[
    @desc:get the size of the utf8 char according to the top byte
    --@char:[#int] 
    @return:[#int]
]]
local function utf8CharSize(char)
    if char >= 0xf0 then
        return 4
    elseif char >= 0xe0 then
        return 3
    elseif char >= 0xc0 then
        return 2
    else
        return 1
    end
end

--[[
    @desc:get the utf8 string's length, regardless of the byte's count, the length is one
    --@input:[#string]
    @return:[#int]
]]
function string.utf8len(input)
    assert(type(input) == "string", "the pameter of input is not string")
    local index = 1
    local cnt = 0
    local len = string.len(input)
    while index <= len do
        local char_size = utf8CharSize(string.byte(input, index))
        index = index + char_size
        cnt = cnt + 1
    end
    return cnt
end

--[[
    @desc:get the substring of utf8 string, the index is according to utf8 char
    --@input:[#string]
	--@start_index:[#int]
	--@end_index:[#int]
    @return:[#string]
]]
function string.utf8str(input, start_index, end_index)
    assert(type(input) == "string", "the pameter of input is not string")
    assert(type(start_index) == "number", "the pameter of start_index is not number")
    assert(not end_index or type(end_index) == "number", "the pameter of end_index is not number")

    if start_index < 0 or (end_index and end_index < 0) then
        local utf8_len = string.utf8len(input)
        if start_index < 0 then
            start_index = utf8_len + start_index + 1
        end
        if end_index and end_index < 0 then
            end_index = utf8_len + end_index + 1
        end
    end

    start_index = start_index == 0 and 1 or start_index
    end_index = (end_index and end_index == 0) and 1 or end_index

    if end_index and start_index > end_index then
        return ""
    end

    local len = string.len(input)
    if start_index > len then
        return ""
    end

    local start_byte = 1
    local current_index = start_index
    while current_index > 1 and start_byte <= len do
        local char_size = utf8CharSize(string.byte(input, start_byte))
        start_byte = start_byte + char_size
        current_index = current_index - 1
    end

    if start_byte > len then
        return ""
    end

    if not end_index or end_index >= len then
        return string.sub(input, start_byte)
    end

    local end_byte = start_byte
    current_index = end_index
    while current_index >= start_index and end_byte <= len do
        local char_size = utf8CharSize(string.byte(input, end_byte))
        end_byte = end_byte + char_size
        current_index = current_index - 1
    end
    end_byte = end_byte - 1

    return string.sub(input, start_byte, end_byte)
end
