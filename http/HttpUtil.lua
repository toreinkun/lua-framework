--local lpeg = require "lpeg"
--local http_patts = require "lpeg_patterns.http"

-- Encodes a character as a percent encoded string
local function char_to_pchar(c)
	return string.format("%%%02X", c:byte(1,1))
end

-- encodeURI replaces all characters except the following with the appropriate UTF-8 escape sequences:
-- ; , / ? : @ & = + $
-- alphabetic, decimal digits, - _ . ! ~ * ' ( )
-- #
local function encodeURI(str)
	return (str:gsub("[^%;%,%/%?%:%@%&%=%+%$%w%-%_%.%!%~%*%'%(%)%#]", char_to_pchar))
end

-- encodeURIComponent escapes all characters except the following: alphabetic, decimal digits, - _ . ! ~ * ' ( )
local function encodeURIComponent(str)
	return (str:gsub("[^%w%-_%.%!%~%*%'%(%)]", char_to_pchar))
end

-- decodeURI unescapes url encoded characters
-- excluding for characters that are special in urls
local decodeURI do
	-- Keep the blacklist in numeric form.
	-- This means we can skip case normalisation of the hex characters
	local decodeURI_blacklist = {}
	for char in ("#$&+,/:;=?@"):gmatch(".") do
		decodeURI_blacklist[string.byte(char)] = true
	end
	local function decodeURI_helper(str)
		local x = tonumber(str, 16)
		if not decodeURI_blacklist[x] then
			return string.char(x)
		end
		-- return nothing; gsub will not perform the replacement
	end
	function decodeURI(str)
		return (str:gsub("%%(%x%x)", decodeURI_helper))
	end
end

-- Converts a hex string to a character
local function pchar_to_char(str)
	return string.char(tonumber(str, 16))
end

-- decodeURIComponent unescapes *all* url encoded characters
local function decodeURIComponent(str)
	return (str:gsub("%%(%x%x)", pchar_to_char))
end

-- An iterator over query segments (delimited by "&") as key/value pairs
-- if a query segment has no '=', the value will be `nil`
local function query_args(str)
	local iter, state, first = str:gmatch("([^=&]+)(=?)([^&]*)&?")
	return function(state, last) -- luacheck: ignore 431
		local name, equals, value = iter(state, last)
		if name == nil then return nil end
		name = decodeURIComponent(name)
		if equals == "" then
			value = nil
		else
			value = decodeURIComponent(value)
		end
		return name, value
	end, state, first
end

local function query_argsTable(str)
    local tbl = {};
    for key, var in query_args(str) do
        tbl[key] = var;
    end
    return tbl;
end
-- Converts a dictionary (string keys, string values) to an encoded query string
local function dict_to_query(form)
	local r, i = {}, 0
	for name, value in pairs(form) do
		i = i + 1
		r[i] = encodeURIComponent(name).."="..encodeURIComponent(value)
	end
	return table.concat(r, "&", 1, i)
end

-- Resolves a relative path
local function resolve_relative_path(orig_path, relative_path)
	local t, i = {}, 0

	local is_abs
	if relative_path:sub(1,1) == "/" then
		-- "relative" argument is actually absolute. ignore orig_path argument
		is_abs = true
	else
		is_abs = orig_path:sub(1,1) == "/"
		-- this will skip empty path components due to +
		-- the / on the end ignores trailing component
		for segment in orig_path:gmatch("([^/]+)/") do
			i = i + 1
			t[i] = segment
		end
	end

	for segment in relative_path:gmatch("([^/]+)") do
		if segment == ".." then
			-- if we're at the root, do nothing
			if i > 0 then
				-- discard a component
				i = i - 1
			end
		elseif segment ~= "." then
			i = i + 1
			t[i] = segment
		end
	end

	-- Make sure leading slash is kept
	local s
	if is_abs then
		if i == 0 then return "/" end
		t[0] = ""
		s = 0
	else
		s = 1
	end
	-- Make sure trailing slash is kept
	if relative_path:sub(-1, -1) == "/" then
		i = i + 1
		t[i] = ""
	end
	return table.concat(t, "/", s, i)
end

local scheme_to_port = {
	http = 80;
	ws = 80;
	https = 443;
	wss = 443;
}

-- Splits a :authority header (same as Host) into host and port
local function split_authority(authority, scheme)
	local host, port
	local h, p = authority:match("^[ \t]*(.-):(%d+)[ \t]*$")
	if p then
		authority = h
		port = tonumber(p, 10)
	else -- when port missing from host header, it defaults to the default for that scheme
		port = scheme_to_port[scheme]
		if port == nil then
			return nil, "unknown scheme"
		end
	end
	local ipv6 = authority:match("^%[([:%x]+)%]$")
	if ipv6 then
		host = ipv6
	else
		host = authority
	end
	return host, port
end

-- Reverse of `split_authority`: converts a host, port and scheme
-- into a string suitable for an :authority header.
local function to_authority(host, port, scheme)
	local authority = host
	if host:match("^[%x:]+:[%x:]*$") then -- IPv6
		authority = "[" .. authority .. "]"
	end
	local default_port = scheme_to_port[scheme]
	if default_port == port then
		port = nil
	end
	if port then
		authority = string.format("%s:%d", authority, port)
	end
	return authority
end

-- HTTP prefered date format
-- See RFC 7231 section 7.1.1.1
local function imf_date(time)
	return os.date("!%a, %d %b %Y %H:%M:%S GMT", time)
end

---- This pattern checks if it's argument is a valid token, if so, it returns it as is.
---- Otherwise, it returns it as a quoted string (with any special characters escaped)
--local maybe_quote do
--	local EOF = lpeg.P(-1)
--	local patt = http_patts.token * EOF
--		+ lpeg.Cs(lpeg.Cc'"' * ((lpeg.S"\\\"") / "\\%0" + http_patts.qdtext)^0 * lpeg.Cc'"') * EOF
--	maybe_quote = function (s)
--		return patt:match(s)
--	end
--end

-- A pcall relative that can be yielded over in PUC 5.1
local yieldable_pcall
-- See if pcall can be yielded over
if coroutine.wrap(function() return pcall(coroutine.yield, true) end)() then
	yieldable_pcall = pcall
else
	local function handle_resume(co, ok, ...)
		if not ok then
			return false, ...
		elseif coroutine.status(co) == "dead" then
			return true, ...
		end
		return handle_resume(co, coroutine.resume(co, coroutine.yield(...)))
	end
	yieldable_pcall = function(func, ...)
		if type(func) ~= "function" or debug.getinfo(func, "S").what == "C" then
			local C_func = func
			-- Can't give C functions to coroutine.create
			func = function(...) return C_func(...) end
		end
		local co = coroutine.create(func)
		return handle_resume(co, coroutine.resume(co, ...))
	end
end

return {
	encodeURI = encodeURI;
	encodeURIComponent = encodeURIComponent;
	decodeURI = decodeURI;
	decodeURIComponent = decodeURIComponent;
	query_args = query_args;
    query_argsTable = query_argsTable;
	dict_to_query = dict_to_query;
	resolve_relative_path = resolve_relative_path;
	scheme_to_port = scheme_to_port;
	split_authority = split_authority;
	to_authority = to_authority;
	imf_date = imf_date;
--	maybe_quote = maybe_quote;
	yieldable_pcall = yieldable_pcall;
}