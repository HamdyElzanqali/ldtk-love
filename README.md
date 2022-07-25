# ldtk-love
A simple [LDtk](https://ldtk.io/) loader for [LÖVE](https://love2d.org/). 

It was tested with LDtk v0.9.3

All layer types are supported.

## Installation
Place ldtk.lua anywhere in the project and make sure you have json.lua in the same folder.

add this to the top of main.lua
```lua
local ldtk = require 'path/to/ldtk.lua'
```
json.lua is needed because LDtk relies on json.

You can add your tilesets anywhere relative to main.lua.

I recommend checking "Minify JSON", "Save levels to separate files" and "Advanced --> discard pre-CSV..."
in project settings to save space and increase loading speed.

Load the .ldtk file using

```lua
ldtk:load('path/to/file.ldtk')
```

check main.lua for a detailed example on how to use this library.

## API
### Callbacks

callbacks gives you the extracted data from LDtk project file.

| name | description | input |
| -- | -- | -- |
| entity | called when a new entity is created | entity object |
| layer | called when a new layer object is created | layer object |
| onLevelLoad | called just before any other callback when a new level is loaded | levelData object |
| onLevelCreated | called just after all other callbacks when a new level is created | levelData object |

### objects
`entity`

| properity | description | type |
| -- | -- | -- |
| x | x position | integer |
| y | y position | integer |
| identifier | the entity name | string |
| width | the entity width in pixels | integer |
| height | the entity height in pixels | integer |
| visisble | whether the entity is visible or not | boolean |
| px | the x pivot of the entity | integer |
| py | the y pivot of the entity | integer |
| order | the order of the entity layer. | integer |
| props | a table containing all custom properties defined in LDtk | table |



`layer`

| properity | description | type |
| -- | -- | -- |
| x | x position | integer |
| y | y position | integer |
| identifier | the layer name | string |
| visible | whether the layer is visible or not | boolean |
| order | the order of the entity layer.|
| color | the blend color of the color. default: {1, 1, 1} (white) | table |
| draw | draws the current layer | function |



`levelData`

| properity | description | type |
| -- | -- | -- |
| bgColor | the background color. {r, g, b} like {0.47, 0.14, 0.83} | table |
| identifier | the name of the level | string |
| worldX | the level x in the world | integer |
| worldY | the level y in the world | integer |
| width | the width of the level | integer |
| height | the height of the level | integer |
| props | a table containing all custom properties defined in LDtk | table |


### Functions

#### ldtk:load
loads the .ldtk project file.
```lua
ldtk:load('path/to/file.ldtk')
```
returns nothing

#### ldtk:goTo
loads a level by its index starting at 1 as the first level
```lua
ldtk:goTo(3) --loads the third level
```
returns nothing

#### ldtk:level
loads a level by its id (name)
```lua
ldtk:load('menu') --loads the level named menu
```
returns nothing

#### ldtk:next
loads the next level or the first if we are in the last
```lua
ldtk:next() --loads the next level
```
returns nothing


#### ldtk:previous
loads the next level or the last if we are in the first
```lua
ldtk:previous() --loads the previous level
```
returns nothing

#### ldtk:reload
reloads current level
```lua
ldtk:reload() --reloads current level
```
returns nothing

#### ldtk:getCurrent
gets current level index. can be accesed as ldtk.current
```lua
ldtk:getCurrent() --gets current level index
```
returns integer

#### ldtk:getCurrentName
gets current level name.
```lua
ldtk:getCurrentName() --gets current level name
```
returns string

#### ldtk.getIndex
gets a level index by its name
```lua
ldtk.getIndex('menu') --gets the index of the level named menu
```
returns integer

#### ldtk.getName
gets a level name by its index
```lua
ldtk.getName(3) --gets the name of the third level
```
returns string

#### ldtk.removeCache
removes the cached images and quads. you may use it before loading another .ldtk file
```lua
ldtk.removeCache() --remove the cached images and quads
```
returns nothing

#### ldtk.getColorHex
gets an RGB color (on a scale of 0 to 1) from a HEX color
```lua
ldtk.getColorHex('#316f1b') --gets the rgb color of #316f1b
```
returns table (r, g, b) like (0.2, 1, 0.49)

#### ldtk.getPath
makes the path relative to main.lua instead of the .ldtk file
```lua
ldtk.getPath('../tilesets/tiles.png') --gets the the relative path to main.lua
```
returns string

#### ldtk.setFlipped
whether to flip the order or not. false by default and can be accessed like ldtk.flipped
```lua
ldtk.setFlipped(true) -- flips the order and the top layer will be created last
```
returns nothing

#### ldtk.getFlipped
gets whether the order is flipped or not. same as ldtk.flipped
```lua
ldtk.getFlipped() -- is the order flipped ?
```
returns boolean

## Support
If you like what you see, you can help by sharing. Pull requests are welcome.

You can became a [Patreon](https://www.patreon.com/HamdyElzonqali) if you want :3

## License
[MIT](https://choosealicense.com/licenses/mit/)


Have Fun!
