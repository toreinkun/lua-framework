require "spec.lunit"
require "spec.lunit-console"
package.cpath = package.cpath .. 'C:/Users/panzhihao/.vscode/extensions/kangping.luaide-0.7.5/runtime/win32/?.dll'
local g = require ("lfs")
-- local f = assert(package.loadlib("lfs.dll", "luaopen_lfs"))
for entry in lfs.dir(rootpath) do
    if entry ~= "." and entry ~= ".." then
        local path = rootpath .. "\\" .. entry
        local attr = lfs.attributes(path)
        --print(path)
        local filename = getFileName(entry)

        if attr.mode ~= "directory" then
            local postfix = getExtension(entry)
            print(filename .. "\t" .. attr.mode .. "\t" .. postfix)
        else
            print(filename .. "\t" .. attr.mode)
            fun(path)
        end
    end
end

lunit.main()
