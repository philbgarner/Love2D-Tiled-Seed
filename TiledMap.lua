--[[

  TiledMap
  
  Simply rendering.
  
  Phil Garner
  July 2017

]]--

local TiledMap = {
    _props = {}
  }

-- More comfortable getter/setter.
TiledMap.__index = function(self, key) 
  if self._props[key] ~= nil then
    return self._props[key]
  else
    return false
  end
end

-- More comfortable getter/setter.
TiledMap.__newindex = function(self, key, value)
  if self._props[key] ~= nil then
    self._props[key] = value
  else
    rawset(self, key, value)
  end
end

-- Redundant getter/setter, __newindex should cover assignments, but I have some legacy code lying around...
function TiledMap:get(prop)
  if self._props and self._props[prop] then
    return self._props[prop]
  end
  return false
end

-- Redundant getter/setter, __newindex should cover assignments, but I have some legacy code lying around...
function TiledMap:set(prop, value)
  self._props[prop] = value
  return true
end

-- Load the .lua exported map in 'filename', 'tilesheet' is a Love2D Image (IE: love.graphics.newImage(image_filename))
function TiledMap:load(filename, tilesheet)
  -- Slice the image into a series of quads and store them in a table
  -- for quick reference in the draw() method.
  
  local quads = {}
  
  package.loaded[filename] = nil  -- If the .lua Tiled map has already been included previously, set this to nil so it thinks it hasn't been.
  self.mapdata = require(filename)  -- (Re)Load .lua Tiled map.

  self.tileset = {
          filename = filename
          ,image = tilesheet
          ,imageWidth = tilesheet:getWidth()
          ,imageHeight = tilesheet:getHeight()
          ,width = self.mapdata.tilesets[1].tilewidth
          ,height = self.mapdata.tilesets[1].tileheight
      }
      
  local img = tilesheet
  local imgh = img:getHeight()
  local imgw = img:getWidth()

  local cx = 0
  local cy = 0
  local count = 0
  while cy < imgh do
    quads[count] = love.graphics.newQuad(cx, cy, self.tileset.width, self.tileset.height, imgw, imgh) -- Can't use table.insert, those indices start at 1.
    cx = cx + self.tileset.width
    if cx >= imgw then
      cx = 0
      cy = cy + self.tileset.height
    end
    count = count + 1
    
  end
  
  self.quads = quads

end

function TiledMap:getTile(x, y, l)

  if not l then l = 1 end
  if x == nil or y == nil or x < 0 or y < 0 then return 0 end
  if x > self.mapdata.layers[l].width or y > self.mapdata.layers[l].height then return 0 end
  
  -- Because the data is not stored by the Tiled exporter as a matrix (array of arrays) but rather it stores it 
  -- as a single table of integers (array), we need to use this formula to get the correct tile for the specified
  -- x/y coordinates.

  local t = self.mapdata.layers[l].data[(y * self.mapdata.layers[l].width) + x]
  if t > 0 then
    return t - 1
  else
    return 0
  end
end

function TiledMap:draw()
  
  -- If there's no map loaded, don't draw anything.
  if not self.mapdata then return end
  
  local dx = 0
  local dy = 0
  for j=1, self.mapdata.height - 1 do
    for i=1, self.mapdata.width - 1 do
      love.graphics.draw(self.tileset.image, self.quads[self:getTile(i, j)], dx, dy)
      dx = dx + self.tileset.width
    end
    dy = dy + self.tileset.height
    dx = 0
  end
  
end

return TiledMap