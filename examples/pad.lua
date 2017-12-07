#!/usr/bin/luajit
-- ---------------------------------------------
-- pad.lua          2014/09/16
--   Copyright (c) 2014 Jun Mizutani,
--   released under the MIT open source license.
-- ---------------------------------------------
package.path = "../LjES/?.lua;" .. package.path

require("GamePad")
local util = require("util")

local pad = GamePad:new()

pad:list()
print(pad:getNumOfButtons())

if pad:available() then

  while (true) do
    if pad:readEvents() > 0 then
      if pad:checkButton(GamePad.A) then
	 print("A") -- do something
      elseif pad:checkButton(GamePad.B) then
	 print("B") -- do something
      end
      local dirX = pad:checkAxis(GamePad.DirX)
      local dirY = pad:checkAxis(GamePad.DirY)
      util.printf("dirX=%3d, dirY=%3d\n", dirX, dirY)
    end
    -- util.sleep(0.5)
  end

end

