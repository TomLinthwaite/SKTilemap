# SKTilemap

## Table of Contents
+ [Change Log](https://github.com/TomLinthwaite/SKTilemap/blob/master/CHANGELOG.md)
+ [Wiki](https://github.com/TomLinthwaite/SKTilemap/wiki)
+ [Overview](#overview)
+ [Why](#why)
+ [Supports](#supports)
+ [Requirements](#requirements)
+ [Usage](#usage)
+ [Quick Guide](#quick-guide)
+ [TMX Support](#tmx-support)
+ [License](#license)
+ [Other](#other)

## Overview
An addition to Apples Sprite Kit frame work for iOS which allows for the creation of tilemaps either programmatically or from a .tmx file (created in [Tiled](www.mapeditor.org)). SKTilemap is written purely in Swift and sets out to be a simple solution for all game programmers alike to add tilemaps to their Sprite Kit games.

## Why
I decided to write this because I couldn't find a good alternative written purely in Swift. I'm also a self taught programmer and this was a good learning exercise. I've tried to document the code as well as I can so it shouldn't be to hard to look through it and add features or change anything you want.

## Supports
* OSX
* iOS

## Requirements
* Xcode 7.3
* Swift 2.2

## Usage
Simply add the SKTilemap*.swift files to your project and you're good to go.

*In the future I will combine all of the files into a single file. For now while I'm still working on the project it's just easier to keep the classes seperate.*

### Loading a Tilemap from a .tmx
To load a tilemap from a .tmx file simply add the .tmx to your project (plus the associated images for your tiles) and use:
    
    if let tilemap = SKTilemap.loadTMX(name: "awsome_map_made_in_Tiled") { 
        scene.addChild(tilemap)
        
        tilemap.enableTileClipping = true // Improve your performance!
    }
    
Once the tilemap has been successfully loaded you can treat it as a normal SKNode. It's always best to load the tilemap within an **if let** or **guard let** statement because the loading *can* fail.

## Quick Guide
Here's a quick overview of the API which should hopefully be self explanatory. I have tried to document everything in code as best I can if you get stuck. **This is not all of the API, please see the wiki.**

### Tilemap Layers
Layers are also SKNode objects and can be added to an SKTilemap object. Each layer contains many SKTile objects (as children) that make up the visual look for that layer.

**Adding, Getting and Removing Layers**

    tilemap.getLayer(name: "Tile Layer 1")
    tilemap.getLayers()
    tilemap.add(tileLayer: someLayer)
    tilemap.add(tileLayer: someLayer, zPosition: 1000)
    tilemap.removeLayer(name: "Tile Layer 87")
    
**Adding, Getting and Removing Tiles from a Layer**

    layer.tileAtCoord(3, 3)
    layer.tileAtPosition(CGPoint(x: 3,y: 3))
    layer.setTileAtCoord(3, 3, tile: aTile)
    layer.setTileAtCoord(3, 3, id: 90)
    layer.removeTileAtCoord(3, 3)
    layer.removeAllTiles()
    
**Tile Coordinates & Positioning**

    layer.tilePositionAtCoord(x: 3, y: 3)
    layer.coordAtPosition(position: CGPoint)
    
**iOS Only**

    layer.coordAtTouchPosition(UITouch)
    layer.tileAtTouchPosition(UITouch)
    
**OSX Only**

    layer.coordAtMousePosition(NSEvent)
    layer.tileAtMousePosition(NSEvent)
    
### Object Groups
Will probably only be used if loading from a .tmx file.

**Adding and Getting Object Groups**

    tilemap.add(objectGroup: AnObjectGroup)
    tilemap.getObjectGroup(name: "Some Object Group")
    
**Adding and Getting Objects**
    
    objectGroup.addObject(SomeObject)
    objectGroup.getObject(id: 5)
    objectGroup.getObjects()
    objectGroup.getObjectAtCoord(32, 54)
    objectGroup.getObjects(name: "Gold Coin")
    objectGroup.getObjects(type: "enemy")
    
### Tilesets
Tilesets are a collection of SKTileData objects. SKTileData objects act as a blueprint when creating individual tiles. Each SKTileData object has a unique ID number known as a GID (if you're familiar with Tiled).

**Adding and Getting Tilesets**
    
    tilemap.add(tileset: SKTileset)
    tilemap.getTileset(name: "coolest graphics eva")
    tilemap.getTileData(id: 54)
    
**Adding and Getting TileData**

    tileset.addTileData(spriteSheet: "a load of sheet sprites")
    tileset.addTileData(id: 90, texture: SKTexture)
    tileset.addTileData(id: 45, imageNamed: "Grass")
    tileset.getTileData(id: 45)

## TMX Support
I haven't yet implemented all of the features you can use to create a tilemap in [Tiled](www.mapeditor.org). Here's a quick list of what **is** and **isn't** yet implemented. I hope to support all features in the future, but feel free to fork this project and add anything yourself. I've tried to make this list as comprehensive as possible but no doubt there are many things I've missed.

### Supported
* Orientation (Orthogonal, Isometric)
* Tilesets (Separate Image, Sprite Sheet)
* Tile Layers
* Object Groups (Layers)
* Encoding (Base64, CSV, XML)
* Objects (Rectangular)
* Properties for all types (Map, Layer, Objects etc...)
* Animated Tiles
* Tile Clipping (Useful for large maps!)
* Path Finding

### Not Supported
* Orientation (Isometric Staggered, Hexagonal)
* Tilesets (External)
* Image Layers
* Terrain Types
* Compression (gzip, zlib)
* Tile Flipping
* Objects (Elipse, Polygon, Polyline)

## Other
Feel free to visit my [YouTube](https://www.youtube.com/channel/UCAlJgYx9-Ub_dKD48wz6vMw) channel where I some times upload videos on game development stuff. I'm likely to put up some videos regarding this project, How-To's and what not.
Also, although I like my current job as a chef I would really like a job in programming! I'm self taught and have no certification to my name but you never know, someone might read this and message me :P

## License

    MIT License

    Copyright (c) 2016 Tom Linthwaite

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
