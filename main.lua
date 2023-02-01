--[[
    I recommend turning on "Minify JSON" and "Save levels to separate files" in project settings 
    to save space and increase loading speed.

    You can add your tileset images anywhere relative to main.lua.
    You have to save the LDtk project for it to take effect.

    As noted in https://love2d.org/wiki/Quad, you may notice bleeding when moving and scaling. 
    To fix this you have to add a border of the same color to every tile in the tileset then set 
    a spacing of 2px and a padding of 1px to the tileset in LDtk.
    If that sounds like too much work, I've already written a script that does it for you in Aseprite:
    https://github.com/HamdyElzonqali/BleedingFixer-Aseprite-Love2d 
]]

--loading ldtk library
local ldtk = require 'ldtk'

--objects table
local objects = {}


-------- ENTITIES --------
--classes are used for the example
local class = require 'classic'

--object class 
local object = class:extend()

function object:new(entitiy)
    -- setting up the object using the entity data
    self.x, self.y = entitiy.x, entitiy.y
    self.w, self.h = entitiy.width, entitiy.height
    self.visible = entitiy.visible
end

function object:draw()
    if self.visible then
        --draw a rectangle to represent the entity
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    end
end
-------------------------



function love.load()
    --resizing the screen to 512px width and 512px height
    love.window.setMode(512, 512)

    --setting up the project for pixelart
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')
    --

    --loading the .ldtk file
    ldtk:load('ldtk/game.ldtk')
    --ldtk:load('samples/AutoLayers_6_OptionalRules.ldtk')

    --[[
        This defines whether to filp the order or not. It's false by default.
        It can be useful if the drawing order is flipped as in this situation.
    ]]
    ldtk:setFlipped(true)

    --[[
        This library depends heavily on callbacks. It works by overriding the default callbacks.
    ]]

    --[[
        ldtk.onEntity is called when a new entity is created.
        
        entity = {
            id          = (string), 
            x           = (int), 
            y           = (int), 
            width       = (int), 
            height      = (int), 
            visible     = (bool)
            px          = (int),    --pivot x
            py          = (int),    --pivot y
            order       = (int), 
            props       = (table)   --custom fields defined in LDtk
        }
        
        Remember that colors are saved in HEX format and not RGB. 
        You can use ldtk ldtk.hex2rgb(color) to get an RGB table like {0.21, 0.57, 0.92}
    ]]
    function ldtk.onEntity(entity)
        --[[
            An example on how data could be used to create in-game objects.
            Generally, you would define a custom field in LDtk to determine the object that the entity represents.
            Ex. game_objects[entity.props.type]() --game_objects is a table that contains all the objects classes in the game.
        ]]
        local newObject = object(entity) --creating new object based on the class we defined before
        table.insert(objects, newObject) --add the object to the table we use to draw
    end

    --[[
        ldtk.onLayer is called when a new layer is created.    
    
        layer:draw() --used to draw the layer

        layer = {
            id          = (string), 
            x           = (int), 
            y           = (int), 
            visible     = (bool)
            color       = (table),  --the color of the layer {r,g,b,a}. Usually used for opacity.
            order       = (int),
            draw        = (function) -- used to draw the layer
        }
    ]]
    function ldtk.onLayer(layer)
        -- Here we treated the layer as an object and added it to the table we use to draw.
        -- Generally, you would create a new object and use that object to draw the layer.

        table.insert(objects, layer) --adding layer to the table we use to draw 
    end

    --[[
        ldtk.onLevelLoaded is called after the level data is loaded but before it's created.

        It's usually useful when you need to remove old objects and change some settings like background color

        level = {
            id          = (string), 
            worldX      = (int), 
            worldY      = (int), 
            width       = (int), 
            height      = (int), 
            props       = (table), --custom fields defined in LDtk
            backgroundColor = (table) --the background color of the level as defined in LDtk
        }
        
        props table has the custom fields defined in LDtk
    ]]
    function ldtk.onLevelLoaded(level)
        --removing all objects so we have a blank level
        objects = {}

        --changing background color to the one defined in LDtk
        love.graphics.setBackgroundColor(level.backgroundColor)
    end

    --[[
        ldtk.onLevelCreated is called after the level is created.

        It's usually useful when you need to call a function or manipulate the objects after they are created.

        level = {
            id          = (string), 
            worldX      = (int), 
            worldY      = (int), 
            width       = (int), 
            height      = (int), 
            props       = (table), --custom fields defined in LDtk
            backgroundColor = (table) --the background color of the level as defined in LDtk
        }
    ]]

    function ldtk.onLevelCreated(level)
        --Here we use a string defined in LDtk as a function
        if level.props.create then 
            load(level.props.create)() 
        end
    end

    --Loading the first level.
    ldtk:goTo(1)

    --[[
        You can load a level by its name
        ldtk:level('Level_0')

        You can load a level by its index (starting at 1 as the first level)
        ldtk:goTo(4) --loads the forth level
        
        You can load the next and previous levels
        ldtk:next() --loads the next level or the first if we are in the last one
        ldtk:previous() --loads the previous level or the last if we are in the first

        You can reload current level (if player loses for example)
        ldtk:reload()
    ]]
end


-- keyboard keys switch statement for lua
local keys = {
    right = function ()
        ldtk:next()
    end,
    left = function ()
        ldtk:previous()
    end,
    r = function ()
        ldtk:reload()
    end

}

function love.keypressed(k)
    if keys[k] then keys[k]() end
end


function love.draw()
    --scalling the screen up for pixelart
   love.graphics.scale(2, 2) 

   --drawing every object in order
   for _, obj in ipairs(objects) do
        obj:draw() 
    end

    --scaling down for the UI
    love.graphics.scale(0.5, 0.5)
    love.graphics.print('Use left and right arrows to change the level.\nWhite squares are entities.', 10, 10)
end
