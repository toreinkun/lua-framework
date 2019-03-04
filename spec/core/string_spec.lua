--[[
    MIT License

    GitHub: https://github.com/toreinkun/lua-framework

    Author: HIBIKI <toreinkun@gmail.com>

    Copyright (c) 2018 HIBIKI <toreinkun@gmail.com>

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

local module = module
local os = os
local print = print

--@region nilorempty
module("string-test.nilorempty", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testEmptyString()
    local input = ""
    local result = string.nilorempty(input)
    assert_true(result)
end

function testNilString()
    local input = nil
    local result = string.nilorempty(input)
    assert_true(result)
end

function testNotEmptyString()
    local input = "I>我<わたし"
    local result = string.nilorempty(input)
    assert_false(result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = 1
            string.nilorempty(input)
        end
    )
end
--@endregion

--@region htmlspecialchars
module("string-test.htmlspecialchars", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testNoneSpecialChars()
    local input = "I我わたし"
    local result = string.htmlspecialchars(input)
    assert_equal(input, result)
end

function testExistsSpecialChars()
    local input = "I>我<わたし"
    local result = string.htmlspecialchars(input)
    assert_not_equal(input, result)
end

function testOneSpecialChars()
    local input = "I>我>わたし"
    local result = string.htmlspecialchars(input)
    assert_equal("I&gt;我&gt;わたし", result)
end

function testMultiSpecialChars()
    local input = 'I 我&わ;た"し\''
    local result = string.htmlspecialchars(input)
    assert_equal("I 我&amp;わ;た&quot;し&#39;", result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.htmlspecialchars(input)
        end
    )
end
--@endregion endregion

--@region restorehtmlspecialchars
module("string-test.restorehtmlspecialchars", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testNoneSpecialChars()
    local input = "I我わたし"
    local result = string.restorehtmlspecialchars(input)
    assert_equal(input, result)
end

function testExistsSpecialChars()
    local input = "I&gt;我&gt;わたし"
    local result = string.restorehtmlspecialchars(input)
    assert_not_equal(input, result)
end

function testOneSpecialChars()
    local input = "I&gt;我&gt;わたし"
    local result = string.restorehtmlspecialchars(input)
    assert_equal("I>我>わたし", result)
end

function testMultiSpecialChars()
    local input = "I 我&amp;わ;た&quot;し&#39;"
    local result = string.restorehtmlspecialchars(input)
    assert_equal('I 我&わ;た"し\'', result)
end

function testOtherAmpersandChars()
    local input = "I 我&&amp;&わ;た&quot;し&#39;&xxx"
    local result = string.restorehtmlspecialchars(input)
    assert_equal('I 我&&&わ;た"し\'&xxx', result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.restorehtmlspecialchars(input)
        end
    )
end
--@endregion

--@region text2html
module("string-test.text2html", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testNoneSpecialChars()
    local input = "I我わたし"
    local result = string.text2html(input)
    assert_equal(input, result)
end

function testHandleSpecialChars()
    local input = 'I 我&わ;た"し\'\n<br /> \t'
    local result = string.text2html(input)
    assert_equal("I 我&amp;わ;た&quot;し&#39;<br />&lt;br /&gt;     ", result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.text2html(input)
        end
    )
end
--@endregion

--@region html2text
module("string-test.html2text", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testNoneSpecialChars()
    local input = "I我わたし"
    local result = string.html2text(input)
    assert_equal(input, result)
end

function testHandleSpecialChars()
    local input = "I 我&amp;わ;た&quot;し&#39;<br />&lt;br /&gt;     "
    local result = string.html2text(input)
    assert_equal('I 我&わ;た"し\'\n<br />     ', result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.html2text(input)
        end
    )
end
--@endregion

--@region xmlspecialchars
module("string-test.xmlspecialchars", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testNoneSpecialChars()
    local input = "I我わたし"
    local result = string.xmlspecialchars(input)
    assert_equal(input, result)
end

function testExistsSpecialChars()
    local input = "I>我<わたし"
    local result = string.xmlspecialchars(input)
    assert_not_equal(input, result)
end

function testOneSpecialChars()
    local input = "I>我>わたし"
    local result = string.xmlspecialchars(input)
    assert_equal("I&gt;我&gt;わたし", result)
end

function testMultiSpecialChars()
    local input = 'I 我&わ;た"し\''
    local result = string.xmlspecialchars(input)
    assert_equal("I 我&amp;わ;た&quot;し&apos;", result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.xmlspecialchars(input)
        end
    )
end
--@endregion

--@region restorexmlspecialchars
module("string-test.restorexmlspecialchars", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testNoneSpecialChars()
    local input = "I我わたし"
    local result = string.restorexmlspecialchars(input)
    assert_equal(input, result)
end

function testExistsSpecialChars()
    local input = "I&gt;我&gt;わたし"
    local result = string.restorexmlspecialchars(input)
    assert_not_equal(input, result)
end

function testOneSpecialChars()
    local input = "I&gt;我&gt;わたし"
    local result = string.restorexmlspecialchars(input)
    assert_equal("I>我>わたし", result)
end

function testMultiSpecialChars()
    local input = "I 我&amp;わ;た&quot;し&apos;"
    local result = string.restorexmlspecialchars(input)
    assert_equal('I 我&わ;た"し\'', result)
end

function testOtherAmpersandChars()
    local input = "I 我&&amp;&わ;た&quot;し&apos;&xxx"
    local result = string.restorexmlspecialchars(input)
    assert_equal('I 我&&&わ;た"し\'&xxx', result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.restorexmlspecialchars(input)
        end
    )
end
--@endregion

--@region text2xml
module("string-test.text2xml", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testNoneSpecialChars()
    local input = "I我わたし"
    local result = string.text2xml(input)
    assert_equal(input, result)
end

function testHandleSpecialChars()
    local input = 'I 我&わ;た"し\'\n<br /> \t'
    local result = string.text2xml(input)
    assert_equal("I 我&amp;わ;た&quot;し&apos;\n&lt;br /&gt; \t", result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.text2xml(input)
        end
    )
end
--@endregion

--@region xml2text
module("string-test.xml2text", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testNoneSpecialChars()
    local input = "I我わたし"
    local result = string.xml2text(input)
    assert_equal(input, result)
end

function testHandleSpecialChars()
    local input = "I 我&amp;わ;た&quot;し&apos;\n&lt;br /&gt;     "
    local result = string.xml2text(input)
    assert_equal('I 我&わ;た"し\'\n<br />     ', result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.xml2text(input)
        end
    )
end
--@endregion

--@region split
module("string-test.split", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testEmptyDelimiter()
    local input = "I我わたし"
    local delimiter = ""
    local result = string.split(input, delimiter)
    assert_equal("I", result[1])
    assert_equal(13, #input)
end

function testEmptyInputString()
    local input = ""
    local delimiter = "|"
    local result = string.split(input, delimiter)
    assert_equal(0, #result)
end

function testSplitSuccess()
    local input = "I我わたし"
    local delimiter = "わた"
    local result = string.split(input, delimiter)
    assert_equal("I我", result[1])
    assert_equal("し", result[2])
    assert_equal(2, #result)
end

function testSplitFail()
    local input = "I我わたし"
    local delimiter = "KK"
    local result = string.split(input, delimiter)
    assert_equal("I我わたし", result[1])
    assert_equal(1, #result)
end

function testSplitLastDelimiter()
    local input = "I我わたし,"
    local delimiter = ","
    local result = string.split(input, delimiter)
    assert_equal("I我わたし", result[1])
    assert_equal("", result[2])
    assert_equal(2, #result)
end

function testSplitFirstDelimiter()
    local input = ",I我わたし"
    local delimiter = ","
    local result = string.split(input, delimiter)
    assert_equal("", result[1])
    assert_equal("I我わたし", result[2])
    assert_equal(2, #result)
end

function testSplitContinuousDelimiter()
    local input = "I我わ,,たし"
    local delimiter = ","
    local result = string.split(input, delimiter)
    assert_equal("I我わ", result[1])
    assert_equal("", result[2])
    assert_equal("たし", result[3])
    assert_equal(3, #result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            local delimiter = "|"
            string.split(input, delimiter)
        end
    )
end

function testErrorDelimiter()
    assert_error(
        "",
        function()
            local input = "I我わたし"
            local delimiter = nil
            string.split(input, delimiter)
        end
    )
end
--@endregion

--@region ltrim
module("string-test.ltrim", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testTrimEmptyString()
    local input = ""
    local result = string.ltrim(input)
    assert_equal("", input)
end

function testTrimNoSpaceString()
    local input = "I我わたし"
    local result = string.ltrim(input)
    assert_equal("I我わたし", result)
end 

function testTrimExistsTopSpaceString()
    local input = "  \t\n\f\r   I我わたし"
    local result = string.ltrim(input)
    assert_equal("I我わたし", result)
end 

function testTrimExistsTailSpaceString()
    local input = "I我わたし \t \n\f"
    local result = string.ltrim(input)
    assert_equal("I我わたし \t \n\f", result)
end

function testTrimExistsBothSpaceString()
    local input = "  \t\n\f\r  I我わたし \t \n\f"
    local result = string.ltrim(input)
    assert_equal("I我わたし \t \n\f", result)
end

function testTrimExistsCenterSpaceString()
    local input = "I我わ \t \n\fたし"
    local result = string.ltrim(input)
    assert_equal("I我わ \t \n\fたし", result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.ltrim(input)
        end
    )
end
--@endregion

--@region rtrim
module("string-test.rtrim", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testTrimEmptyString()
    local input = ""
    local result = string.rtrim(input)
    assert_equal("", input)
end

function testTrimNoSpaceString()
    local input = "I我わたし"
    local result = string.rtrim(input)
    assert_equal("I我わたし", result)
end 

function testTrimExistsTopSpaceString()
    local input = "  \t\n\f\r   I我わたし"
    local result = string.rtrim(input)
    assert_equal("  \t\n\f\r   I我わたし", result)
end 

function testTrimExistsTailSpaceString()
    local input = "I我わたし \t \n\f \r"
    local result = string.rtrim(input)
    assert_equal("I我わたし", result)
end

function testTrimExistsBothSpaceString()
    local input = "  \t\n\f\r  I我わたし \t \n\f"
    local result = string.rtrim(input)
    assert_equal("  \t\n\f\r  I我わたし", result)
end

function testTrimExistsCenterSpaceString()
    local input = "I我わ \t \n\fたし"
    local result = string.rtrim(input)
    assert_equal("I我わ \t \n\fたし", result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.ltrim(input)
        end
    )
end
--@endregion

--@region trim
module("string-test.trim", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testTrimEmptyString()
    local input = ""
    local result = string.trim(input)
    assert_equal("", input)
end

function testTrimNoSpaceString()
    local input = "I我わたし"
    local result = string.trim(input)
    assert_equal("I我わたし", result)
end 

function testTrimExistsTopSpaceString()
    local input = "  \t\n\f\r   I我わたし"
    local result = string.trim(input)
    assert_equal("I我わたし", result)
end 

function testTrimExistsTailSpaceString()
    local input = "I我わたし \t \n\f \r"
    local result = string.trim(input)
    assert_equal("I我わたし", result)
end

function testTrimExistsBothSpaceString()
    local input = "  \t\n\f\r  I我わたし \t \n\f"
    local result = string.trim(input)
    assert_equal("I我わたし", result)
end

function testTrimExistsCenterSpaceString()
    local input = "I我わ \t \n\fたし"
    local result = string.trim(input)
    assert_equal("I我わ \t \n\fたし", result)
end

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.trim(input)
        end
    )
end
--@endregion

--@region ucfirst
module("string-test.ucfirst", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testEmptyString()
    local input = ""
    local result = string.ucfirst(input)
    assert_equal("", result)
end

function testTopLowerCaseString()
    local input = "abc"
    local result = string.ucfirst(input)
    assert_equal("Abc", result)
end 

function testTopUpperCaseString()
    local input = "Abc"
    local result = string.ucfirst(input)
    assert_equal("Abc", result)
end 

function testUtf8String()
    local input = "我わたし"
    local result = string.ucfirst(input)
    assert_equal(input, result)
end 

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.ucfirst(input)
        end
    )
end

--@endregion

--@region urlencode
module("string-test.urlencode", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testEmptyString()
    local input = ""
    local result = string.urlencode(input)
    assert_equal("", result)
end

function testEncodeNoneSpecialCharString()
    local input = "abcdefghijklmn"
    local result = string.urlencode(input)
    assert_equal(input, result)
end 

function testEncodeSpecialCharString()
    local input = "Abc \\H.ged.><%21"
    local result = string.urlencode(input)
    assert_equal("Abc+%5CH.ged.%3E%3C%2521", result)
end 

function testEncodeUtf8String()
    local input = "我わたし \\H.ged.><%21+"
    local result = string.urlencode(input)
    assert_equal("%E6%88%91%E3%82%8F%E3%81%9F%E3%81%97+%5CH.ged.%3E%3C%2521%2B", result)
end 

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.urlencode(input)
        end
    )
end

--@endregion

--@region urldecode
module("string-test.urldecode", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testEmptyString()
    local input = ""
    local result = string.urldecode(input)
    assert_equal("", result)
end

function testDecodeNoneSpecialCharString()
    local input = "abcdefghijklmn"
    local result = string.urldecode(input)
    assert_equal(input, result)
end 

function testDecodeSpecialCharString()
    local input = "Abc+%5CH.ged.%3E%3C%2521"
    local result = string.urldecode(input)
    assert_equal("Abc \\H.ged.><%21", result)
end 

function testDecodeUtf8String()
    local input = "%E6%88%91%E3%82%8F%E3%81%9F%E3%81%97+%5CH.ged.%3E%3C%2521%2B"
    local result = string.urldecode(input)
    assert_equal("我わたし \\H.ged.><%21+", result)
end 

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.urldecode(input)
        end
    )
end

--@endregion

--@region utf8len
module("string-test.utf8len", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testGetEmptyStringLength()
    local input = ""
    local result = string.utf8len(input)
    assert_equal(0, result)
end

function testGetEnglishStringLength()
    local input = "abcdefghijklmn"
    local result = string.utf8len(input)
    assert_equal(14, result)
end 

function testGetUtf8StringLength()
    local input = "我わたし "
    local result = string.utf8len(input)
    assert_equal(5, result)
end 

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            string.urldecode(input)
        end
    )
end

--@endregion

--@region utf8str
module("string-test.utf8str", lunit.testcase)

function setup()
    lunit.require("core.string")
    string = lunit.string
end

function teardown()
    lunit.unload("core.string")
    string = nil
end

function testGetEmptySubString()

local input = [==[                     MIT License 

GitHub: https://github.com/toreinkun/lua-framework

Author: HIBIKI <toreinkun@gmail.com>

Copyright (c) 2018 HIBIKI <toreinkun@gmail.com>

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
SOFTWARE.                       ]==]

for i = 1 ,10 do 
    input = input .. input
end 
    for i = 1, 10 do 
        local t= os.clock() 
        string.trim(input)
        print("t", os.clock() - t)
    end 

    local input = ""
    local result = string.utf8str(input, 1)
    assert_equal("", result)
end

function testGetEnglishSubString()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 3)
    assert_equal("cdefghijklmn", result)
end 

function testGetEnglishSubStringWithMinusIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, -1)
    assert_equal("n", result)
end 

function testGetEnglishSubStringWithZeroIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 0)
    assert_equal("abcdefghijklmn", result)
end 

function testGetEnglishSubStringWithFirstIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 1)
    assert_equal("abcdefghijklmn", result)
end 

function testGetEnglishSubStringWithLastIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 14)
    assert_equal("n", result)
end 

function testGetEnglishSubStringWithLargerIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 20)
    assert_equal("", result)
end 

function testGetEnglishSubStringWithEndIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 5, 8)
    assert_equal("efgh", result)
end 

function testGetEnglishSubStringWithFirstStartIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 1, 12)
    assert_equal("abcdefghijkl", result)
end 

function testGetEnglishSubStringWithLastStartIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 14, 30)
    assert_equal("n", result)
end 

function testGetEnglishSubStringWithLargerStartIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 20, 30)
    assert_equal("", result)
end 

function testGetEnglishSubStringWithSameIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 5, 5)
    assert_equal("e", result)
end 

function testGetEnglishSubStringWithLargerEndIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 7, 30)
    assert_equal("ghijklmn", result)
end 

function testGetEnglishSubStringWithStartLargerThanEndIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 8, 4)
    assert_equal("", result)
end 

function testGetEnglishSubStringWithMinusStartIndexAndEndIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, -2, 9)
    assert_equal("", result)
end 

function testGetEnglishSubStringWithStartAndMinusEndIndex()
    local input = "abcdefghijklmn"
    local result = string.utf8str(input, 10, -2)
    assert_equal("jklm", result)
end 

function testGetUtf8SubString()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 3)
    assert_equal("たしI我わたしI我わたし", result)
end 

function testGetUtf8SubStringWithMinusIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, -1)
    assert_equal("し", result)
end 

function testGetUtf8SubStringWithZeroIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 0)
    assert_equal("我わたしI我わたしI我わたし", result)
end 

function testGetUtf8SubStringWithFirstIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 1)
    assert_equal("我わたしI我わたしI我わたし", result)
end 

function testGetUtf8SubStringWithLastIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 14)
    assert_equal("し", result)
end 

function testGetUtf8SubStringWithLargerIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 20)
    assert_equal("", result)
end 

function testGetUtf8SubStringWithEndIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 5, 8)
    assert_equal("I我わた", result)
end 

function testGetUtf8SubStringWithFirstStartIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 1, 12)
    assert_equal("我わたしI我わたしI我わ", result)
end 

function testGetUtf8SubStringWithLastStartIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 14, 30)
    assert_equal("し", result)
end 

function testGetUtf8SubStringWithLargerStartIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 20, 30)
    assert_equal("", result)
end 

function testGetUtf8SubStringWithSameIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 6, 6)
    assert_equal("我", result)
end 

function testGetUtf8SubStringWithLargerEndIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 7, 30)
    assert_equal("わたしI我わたし", result)
end 

function testGetUtf8SubStringWithStartLargerThanEndIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 8, 4)
    assert_equal("", result)
end 

function testGetUtf8SubStringWithMinusStartIndexAndEndIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, -2, 9)
    assert_equal("", result)
end 

function testGetUtf8SubStringWithStartAndMinusEndIndex()
    local input = "我わたしI我わたしI我わたし"
    local result = string.utf8str(input, 10, -2)
    assert_equal("I我わた", result)
end 

function testErrorInputString()
    assert_error(
        "",
        function()
            local input = nil
            local startIdx = 2
            string.utf8str(input, 2)
        end
    )
end

function testErrorStartIndex()
    assert_error(
        "",
        function()
            local input = ""
            local startIdx = nil
            string.utf8str(input,startIdx)
        end
    )
end

function testSuccessNilEndIndex()
    assert_pass(
        "",
        function()
            local input = "abcdefg"
            local startIdx = 2
            local endIdx = nil
            string.utf8str(input,startIdx, endIdx)
        end
    )
end

function testErrorEndIndex()
    assert_error(
        "",
        function()
            local input = "abcdefg"
            local startIdx = 2
            local endIdx = {}
            string.utf8str(input,startIdx, endIdx)
        end
    )
end

--@endregion
