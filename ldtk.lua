-- A basic LDtk loader for LÖVE created by Hamdy Elzonqali
-- Last tested with LDtk 0.9.3
--
-- ldtk.lua
--
-- Copyright (c) 2021 Hamdy Elzonqali
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--



-- Remember to put json.lua in the same directory

-- loading json
-- Current folder trick
local currentFolder = (...):gsub('%.[^%.]+$', '')

local jsonLoaded = false

if json then
    jsonLoaded = true
end

-- Try to load json
if not jsonLoaded then
    jsonLoaded, json = pcall(require, "json")
end

-- Try to load relatively
if not jsonLoaded then
    jsonLoaded, json = pcall(require, currentFolder .. ".json")
end
--



local ldtk, TileLayer = {
    flipped = false
}, {}
local newPath, newRelPath, pathLen, keys
local _path

local cache = {
    tilesets = {

    },
    quods = {

    },
    batch = {

    }
}

local levels, levelsNames, tilesets = {}, {}, {}

--this is used as a switch statement for lua. much faster than if-else.
local flipX = {
    [0] = 1,
    [1] = -1,
    [2] = 1,
    [3] = -1
}

local flipY = {
    [0] = 1,
    [1] = 1,
    [2] = -1,
    [3] = -1
}


--[[
    called for every entity in the level
    entity = {x = (int), y = (int), width = (int), height = (int), 
              px = (int), py = (int), visible = (bool), props = (table)}
    px is pivot x and py is pivot y
    props contains all custom fields defined in LDtk for that entity
]]
function ldtk.entity(entity)
    
end

--[[
    called when a new layer is created
    layer is an object that has a draw function
    it has x, y, order, identifier, visible and color
    layer:draw()
]]
function ldtk.layer(layer)
    
end

--[[
    this is called before a new level is created
    you may use it to remove all entities and layers from last room for example
    levelData = {bgColor = (table), identifier = (string), index = (int)
        worldX = (int), worldY = (int), width = (int), height = (int), props = (table)}
]]
function ldtk.onLevelLoad(levelData)
    
end

--[[
    this is called after a new level is created
    you may use it to change background color for example
    levelData = {bgColor = (table), identifier = (string), index = (int)
        worldX = (int), worldY = (int), width = (int), height = (int), props = (table)}
]]
function ldtk.onLevelCreated(levelData)
    
end

--getting relative file path to main instead of .ldtk file
function ldtk.getPath(relPath)
    newPath, newRelPath = '', {}
    pathLen = #_path

    for str in string.gmatch(relPath, "([^"..'/'.."]+)") do
        table.insert(newRelPath, str)
    end

    for i = #newRelPath, 1, -1 do
        if newRelPath[i] == '..' then
            pathLen = pathLen - 1
            newRelPath[i] = nil
        end
    end

    for i = 1, pathLen, 1 do
        newPath = newPath .. (i > 1 and '/' or '') .. _path[i]
    end

    keys = {}
    for key, _ in pairs(newRelPath) do
        table.insert(keys, key)
    end
    table.sort(keys)


    local len = #keys
    for i = 1, len, 1 do
        newPath = newPath .. (newPath ~= '' and '/' or '') .. newRelPath[keys[i]]
    end

    return newPath
end

--LDtk uses hex colors while LÖVE uses RGB (on a scale of 0 to 1)
function ldtk.getColorHex(color)
    local r = loadstring ("return {0x" .. color:sub(2, 3) .. ",0x" .. color:sub(4, 5) .. 
                ",0x" .. color:sub(6, 7) .. "}")()
    return {r[1] / 255, r[2] / 255, r[3] / 255}
end

--loads project settings
function ldtk:load(file, level, flipped)
    self.data = json.decode(love.filesystem.read(file))
    self.layers = {}
    self.entities = {}
    self.x, self.y = self.x or 0, self.x or 0
    self._layerToDraw = {}
    self.current = 1
    self.max = #self.data.levels
    self.layersCount = #self.data.defs.layers
    
    --creating a table with path separated by '/', 
    --used to load image in other folders. ignore it
    _path = {}
    for str in string.gmatch(file, "([^"..'/'.."]+)") do
        table.insert(_path, str)
    end
    _path[#_path] = nil

    for index, value in ipairs(self.data.levels) do
        levels[value.identifier] = index
    end

    for key, value in pairs(levels) do
        levelsNames[value] = key
    end

    for index, value in ipairs(self.data.defs.tilesets) do
        tilesets[value.uid] = self.data.defs.tilesets[index]
    end

    if level then
        self:goTo(level)
    end
end



local layers, layer, entity, props, levelProps, levelEntry, len
--loading level by its index (int)
function ldtk:goTo(index)
    if index > self.max then error('there are no level with that index.') end
    self.current = index

    if self.data.externalLevels then
        layers = json.decode(love.filesystem.read(self.getPath(self.data.levels[index].externalRelPath))).layerInstances
    else
        layers = self.data.levels[index].layerInstances
    end
    
    levelProps = {}
    for _, p in ipairs(self.data.levels[index].fieldInstances) do
        levelProps[p.__identifier] = p.__value
    end



    levelEntry = {
        bgColor = ldtk.getColorHex(self.data.levels[index].__bgColor),
        identifier = self.data.levels[index].identifier,
        worldX  = self.data.levels[index].worldX,
        worldY = self.data.levels[index].worldY,
        width = self.data.levels[index].pxWid,
        height = self.data.levels[index].pxHei,
        index = index,
        props = levelProps
    }

    self.onLevelLoad(levelEntry)

    local types = {
        Entities = function (currentLayer, order)
            for _, value in ipairs(currentLayer.entityInstances) do
                props = {}
    
                for _, p in ipairs(value.fieldInstances) do
                    props[p.__identifier] = p.__value
                end
    
                entity = {
                    identifier = value.__identifier,
                    x = value.px[1],
                    y = value.px[2],
                    width = value.width,
                    height = value.height,
                    px = value.__pivot[1],
                    py = value.__pivot[2],
                    order = order,
                    visible = currentLayer.visible,
                    props = props
                }

                self.entity(entity)
            end
        end,

        Tiles = function (currentLayer, order)
            if #currentLayer.gridTiles > 0 then
                layer = {create = TileLayer.create, draw = TileLayer.draw}
                layer = setmetatable(layer, TileLayer)
                layer:create(currentLayer)
                layer.order = order
                self.layer(layer)
            end
        end,

        IntGrid = function (currentLayer, order)
            if #currentLayer.autoLayerTiles > 0 and currentLayer.__tilesetDefUid then
                layer = {create = TileLayer.create, draw = TileLayer.draw}
                    layer = setmetatable(layer, TileLayer)
                    layer:create(currentLayer, true)
                    layer.order = order
                    self.layer(layer)
            end
        end,

        AutoLayer = function (currentLayer, order)
            if currentLayer.__tilesetDefUid and #currentLayer.autoLayerTiles > 0 then
                layer = {create = TileLayer.create, draw = TileLayer.draw}
                layer = setmetatable(layer, TileLayer)
                layer:create(currentLayer, true)
                layer.order = order
                self.layer(layer)
            end
        end
    }

    if self.flipped then
        for i = #layers, 1, -1 do
            types[layers[i].__type](layers[i], self.layersCount - i)
        end    
    else
        len = #layers
        for i = 1, len do
            types[layers[i].__type](layers[i], self.layersCount - i)
        end    
    end
    

    self.onLevelCreated(levelEntry)
end

--loads a level by its name (string)
function ldtk:level(name)
    self:goTo(levels[name] or error('There is no level with that name! sorry :(\nDid you save? (ctrl +s)'))
end

--loads next level
function ldtk:next()
    self:goTo(self.current + 1 <= self.max and self.current + 1 or 1)
end

--loads previous level
function ldtk:previous()
    self:goTo(self.current - 1 >= 1 and self.current - 1 or self.max)
end

--reloads current level
function ldtk:reload()
    self:goTo(self.current)
end

--gets the index of a specific level
function ldtk.getIndex(name) 
    return levels[name]
end

--get the name of a specific level
function ldtk.getName(index) 
    return levelsNames[index]
end

--gets the current level index
function ldtk:getCurrent()
    return self.current
end

--get the current level name
function ldtk:getCurrentName()
    return levelsNames[self:getCurrent()]
end

--sets whether to invert the loop or not
function ldtk:setFlipped(flipped)
    self.flipped = flipped
end

--gets whether the loop is inverted or not
function ldtk:getFlipped()
    return self.flipped
end

--remove the cahced tiles and quods. you may use it if you have multiple .ldtk files
function ldtk.removeCache()
    cache = {
        tilesets = {
            
        },
        quods = {
            
        },
        batch = {

        }
    }
    collectgarbage()
end


--creates the layer object from data. only used here. ignore it
function TileLayer:create(data, auto)
    self._offsetX = {
        [0] = 0,
        [1] = data.__gridSize,
        [2] = 0,
        [3] = data.__gridSize,
    }

    self._offsetY = {
        [0] = 0,
        [1] = 0,
        [2] = data.__gridSize,
        [3] = data.__gridSize,
    }

    --getting tiles information
    if auto then
        self.tiles = data.autoLayerTiles
    else 
        self.tiles = data.gridTiles
    end

    self.relPath = data.__tilesetRelPath
    self.path = ldtk.getPath(data.__tilesetRelPath)
    self.data = data
    self.identifier = data.__identifier
    self.x, self.y = data.__pxTotalOffsetX, data.__pxTotalOffsetY

    self.visible = data.visible
    self.color = {1, 1, 1, data.__opacity}

    --getting tileset information
    self.tileset = tilesets[data.__tilesetDefUid]

    --creating new tileset if not created yet
    if not cache.tilesets[data.__tilesetDefUid] then
        --loading tileset
        cache.tilesets[data.__tilesetDefUid] = love.graphics.newImage(self.path)
        --create spritebatch
        cache.batch[data.__tilesetDefUid] = love.graphics.newSpriteBatch(cache.tilesets[data.__tilesetDefUid])

        --creating quads for tileset
        cache.quods[data.__tilesetDefUid] = {}
        local count = 0
        for ty = 0, self.tileset.__cHei - 1, 1 do
            for tx = 0, self.tileset.__cWid - 1, 1 do
                cache.quods[data.__tilesetDefUid][count] = 
                    love.graphics.newQuad(self.tileset.padding + tx * (self.tileset.tileGridSize + self.tileset.spacing),
                    self.tileset.padding + ty * (self.tileset.tileGridSize + self.tileset.spacing), 
                    self.tileset.tileGridSize, self.tileset.tileGridSize,
                    cache.tilesets[data.__tilesetDefUid]:getWidth(), cache.tilesets[data.__tilesetDefUid]:getHeight())
                    
                count = count + 1
            end
        end
    end



end

local len, oldColor = 0, {}

--draws tiles
function TileLayer:draw()
    if self.visible then
        len = #self.tiles
        --Clear batch
        cache.batch[self.tileset.uid]:clear()
        --Get old color
        oldColor[1], oldColor[2], oldColor[3], oldColor[4] = love.graphics.getColor()
        -- Fill batch with quads
         for i = 1, len do
            cache.batch[self.tileset.uid]:add(cache.quods[self.tileset.uid][self.tiles[i].t], 
                                self.x + self.tiles[i].px[1] + self._offsetX[self.tiles[i].f], 
                                self.y + self.tiles[i].px[2] + self._offsetY[self.tiles[i].f], 0, 
                                flipX[self.tiles[i].f], flipY[self.tiles[i].f])
        end

        love.graphics.setColor(self.color)
        --Draw batch
        love.graphics.draw(cache.batch[self.tileset.uid])
        love.graphics.setColor(oldColor)
    end
end

return ldtk