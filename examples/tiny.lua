#!/usr/bin/luajit

  package.path = "../LjES/?.lua;" .. package.path
  local demo = require("demo")

  demo.screen(0, 0)
  local aSpace = demo.getSpace()
  local eye = aSpace:addNode(nil, "eye")
  eye:setPosition(0, 0, 30)
  demo.backgroundColor(0.2, 0.2, 0.4)

  local shape = Shape:new()
  shape:donut(8, 3, 16, 16)
  shape:endShape()
  shape:shaderParameter("color", {1.0, 0.5, 0.6, 1.0})

  local node = aSpace:addNode(nil, "node1")
  node:setPosition(0, 0, 0)
  node:addShape(shape)

  function draw()
    node:rotateX(0.1)
    aSpace:draw(eye)
  end

  demo.loop(draw, true)
  demo.exit()
