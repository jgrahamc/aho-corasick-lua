local AC = require 'aho-corasick'

local count = 0

function error(e, t)
    print(count .. " " .. e)
    os.exit()
end

function test(s, d, r)
    count = count + 1
    local t = AC.build(d)
    local f = AC.match(t, s)
    
    if #r ~= #f then
        error("Wrong number of results " .. #r .. ", " .. #f, t)
    end
    
    for i = 1,#r do
        if r[i] ~= f[i] then
            error("Non-matching result " .. r[i] .. ", " .. f[i], t)
        end
    end
    
    print(count .. " ok")
end

-- Example from Wikipedia page
test("abccab", {"a", "ab", "bc", "bca", "c", "caa"},
     {"a", "ab", "bc", "c", "c", "a", "ab"})

-- Simple test for finding a string
test("The pot had a handle", {"poto"}, {})
test("The pot had a handle", {"The"}, {"The"})
test("The pot had a handle", {"pot"}, {"pot"})
test("The pot had a handle", {"pot "}, {"pot "})
test("The pot had a handle", {"ot h"}, {"ot h"})
test("The pot had a handle", {"andle"}, {"andle"})

-- Multiple non-overlapping patterns
test("The pot had a handle", {"h"}, {"h", "h", "h"})
test("The pot had a handle", {"ha", "he"}, {"he", "ha", "ha"})
test("The pot had a handle", {"pot", "had"}, {"pot", "had"})
test("The pot had a handle", {"pot", "had", "hod"}, {"pot", "had"})
test("The pot had a handle", {"The", "pot", "had", "hod", "andle"},
     {"The", "pot", "had", "andle"})

-- Overlapping patterns
test("The pot had a handle", {"Th", "he pot", "The", "pot h"},
     {"Th", "The", "he pot", "pot h"})

-- One pattern inside another
test("The pot had a handle", {"handle", "hand", "and", "andle"},
     {"hand", "and", "handle", "andle"})
test("The pot had a handle", {"handle", "hand", "an", "n"},
     {"an", "n", "hand", "handle"})
test("The pot had a handle", {"dle", "l", "le"},
     {"l", "dle", "le"})

-- Random example
test("yasherhs", {"say", "she", "shr", "he", "her"},
     {"she", "he", "her"})

-- Fail from partial match
test("The pot had a handle", {"dlf", "l"}, {"l"})

-- Many suffixes and prefixes
test("The pot had a handle", {"handle", "andle", "ndle", "dle", "le", "e"},
     {"e", "handle", "andle", "ndle", "dle", "le", "e"})
test("The pot had a handle", {"handle", "handl", "hand", "han", "ha", "a"},
     {"ha", "a", "a", "ha", "a", "han", "hand", "handl", "handle"})

-- Long word
test("macintosh", {"acintosh", "in"}, {"in", "acintosh"})
test("macintosh", {"acintosh", "in", "tosh"}, {"in", "acintosh", "tosh"})
test("macintosh", {"acintosh", "into", "to", "in"},
     {"in", "into", "to", "acintosh", })
