
TiledMap = require 'TiledMap'

gamera = require 'gamera' -- From https://github.com/kikito/gamera

local cam

function love.load()
  love.graphics.setDefaultFilter( 'nearest', 'nearest' ) -- Set scaling filter to avoid blurriness.
  
  TiledMap:load("example1", love.graphics.newImage("images/GreenlandsTileset.png"))
  
  local w = TiledMap.mapdata.width * TiledMap.mapdata.tilewidth
  local h = TiledMap.mapdata.height * TiledMap.mapdata.tileheight
  cam = gamera.new(0, 0, w, h)
  
  local winW, winH = love.window.getMode( )
  cam:setWindow(0, 0, winW, winH) -- Set camera area to screen.
  cam:setScale(2) -- Set camera scale.
end

function love.mousemoved( x, y, dx, dy, istouch)
  
  if love.mouse.isDown(1) then
    local cx, cy = cam:getPosition()
    cam:setPosition(cx + dx, cy + dy)
  end
  
end

function love.wheelmoved( x, y )
  
  local s = cam:getScale()
  cam:setScale(s + y, s + y)
  
end

function love.draw()
  
  cam:draw(function (l, t, w, h)
    TiledMap:draw()
  end)
  
end