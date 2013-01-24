-- A Lua implementation of the Aho-Corasick string matching algorithm
--
-- Copyright (c) 2013 CloudFlare, Inc.
--
-- Usage:
--
-- local AC = require 'aho-corasick'
--
-- t = AC.build({'words', 'to', 'find'})
-- r = AC.match(t, 'try to find in this string')
-- r == {'to', 'find'}

local M = {}

local root = ""

-- make: creates a new entry in t for the given string c with
-- optional fail state
local function make(t, c, f) 
   t[c]      = {}
   t[c].to   = {}
   t[c].fail = f
   t[c].hit  = {}
   t[c].ch    = c:sub(-1,-1)
end

-- build: builds the Aho-Corasick data structure from an array of
-- strings
function M.build(m) 
   local t = {}
   make(t, root, root)

   for i = 1, #m do
	  local current = root

	  -- Build the tos and ends which capture the transitions within
	  -- the tree and whether a node is at the end of one of the
	  -- strings to match against

   	  for j = 1, m[i]:len() do
		 local c = m[i]:sub(j,j)
		 local path = current .. c

		 if t[current].to[c] == nil then
			t[current].to[c] = path

			if current == root then
			   make(t, path, root)
			else
			   make(t, path)
			end
		 end

		 current = path
	  end

	  table.insert(t[current].hit, m[i])
   end

   -- Build the fails which show how to backtrack when a fail matches

   local q = {}
   table.insert(q, root)

   while #q > 0 do
	  local path = table.remove(q, 1)

	  for c, p in pairs(t[path].to) do
		 table.insert(q, p)

		 local ch = t[p].ch
		 local fail = t[path].fail
		 
		 while fail ~= root and t[fail].to[ch] ~= nil do
			fail = t[fail].fail
		 end

		 if t[fail].to[ch] ~= nil and t[fail].to[ch] ~= p then
			t[p].fail = t[fail].to[ch]
		 else
			t[p].fail = root
		 end
	  end
   end

   return t
end

-- match: checks to see if the passed in string matches the passed in
-- tree created with build. If all is true (the default) an array of
-- all matches is returned. If all is false then only the first match
-- is returned. If no matches an empty table is returned.
function M.match(t, s, all)
   if all == nil then
	  all = true
   end

   local path = root
   local hits = {}

   for i = 1,s:len() do
	  local c = s:sub(i,i)

	  while t[path].to[c] == nil and path ~= root do
			path = t[path].fail
	  end

	  local n = t[path].to[c]

	  if n ~= nil then
		 path = n

		 if next(t[n].hit) ~= nil then
			for i, v in ipairs(t[n].hit) do
			   table.insert(hits, v)
			   if all == false then
				  return hits
			   end
			end
		 end
	  end
   end

   return hits
end

return M
