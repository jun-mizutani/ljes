#!/usr/bin/luajit

package.path = "../LjES/?.lua;" .. package.path
local termios = require("termios")
termios.getTermios()
termios.resetRawMode()
