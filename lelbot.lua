#! /usr/bin/env lua5.1

package.path = "./?/init.lua;./irc/?.lua;./?.lua;"..package.path
package.cpath = "./lib?.so;./?.dll;"..package.cpath

local luairc = require("irc")

local SERV = "irc.freenode.net"
local CHAN = "##mt-irc-mod"
local NICK = "meh"

local ignores = { }

local conn = luairc.new({
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

dofile = nil
loadfile = nil
load = nil
module = nil
socket = nil

irc = nil

function exit()
	conn:disconnect("Bye!")
	os_exit()
end

local out_text

function print(...)
	local s = table.concat({...}, " ")
	s = s:gsub("[\001-\031]", " ")
	table.insert(out_text, s)
end

conn:hook("OnChat", function(user, channel, message)
	base_print(("[%s] %s: %s"):format(channel, user.nick, message))
	if message:sub(1, 1) == "%" then
		local f = loadstring(message:sub(2))
		out_text = { }
		local r, e = pcall(f)
		if r then
			conn:sendChat(CHAN, user.nick..": "..table.concat(out_text, " "))
		else
			conn:sendChat(CHAN, user.nick..": Error: "..tostring(e))
		end
		return
	end
end)

conn:join(CHAN)

while true do
	pcall(function() conn:think() end)
end
