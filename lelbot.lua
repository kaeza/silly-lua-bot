#! /usr/bin/env lua5.1

package.path = "./?/init.lua;./irc/?.lua;./?.lua;"..package.path
package.cpath = "./lib?.so;./?.dll;"..package.cpath

local irc = require("irc")

local SERV = "irc.freenode.net"
local CHAN = "##mt-irc-mod"
local NICK = "meh"

local ignores = { }

local conn = irc.new({
	nick = NICK,
	username = "Meh",
	realname = "Meh",
})

conn:connect({
	host = SERV,
	port = 6667,
})

local base_print = print
local os_exec = os.execute
local os_exit = os.exit

os = nil
debug = nil
io = nil
require = nil
package = nil

function exit()
	conn:disconnect("Bye!")
	os_exit()
end

function print(...)
	local s = table.concat({...}, " ")
	s = s:gsub("[\001-\031]", " ")
	conn:sendChat(CHAN, s)
end

conn:hook("OnChat", function(user, channel, message)
	base_print(("[%s] %s: %s"):format(channel, user.nick, message))
	if message:sub(1, 1) == "%" then
		local f = loadstring(message:sub(2))
		local r, e = pcall(f)
		if not r then
			print("Error: "..tostring(e))
		end
		return
	end
end)

conn:join(CHAN)

while true do
	pcall(function() conn:think() end)
end
