# SKTilemap

Table of Contents
-
+ [Overview](#overview)

Overview
-
An addition to Apples Sprite Kit frame work for iOS which allows for the creation of tilemaps either programmatically or from a .tmx file (created in Tiled). SKTilemap is written purely in Swift and sets out to be a simple solution for all game programmers alike to add tilemaps to thier Sprite Kit games.

Installation
-
Simply add the SKTilemap... swift files to your project and you're good to go.

*In the future I will combine all of the files into a single file. For now while I'm still working on the project it's just easier to keep the classes seperate.*

Loading a Tilemap from a .tmx
-
To load a tilemap from a .tmx file simply add the .tmx to your project (plus the associated images for your tiles) and use:
    
    if let tilemap = SKTilemap.loadTMX(name: "awsome_map_made_in_Tiled") { }
    
Once the tilemap has been successfully loaded you can treat it as a normal SKNode. It's always best to load the tilemap within an **if let** or **guard let** statement because the loading *can* fail.

Creating a Tilemap Programmatically
-
*Not yet fully implemented*

Tilemap Layers
-
Layers are also SKNode objects and can be added to an SKTilemap object. Each layer contains many SKTile objects (as children) that make up the visual look for that layer.

**Adding, Getting and Removing Layers**

    tilemap.getLayer(name: "Tile Layer 1")
    tilemap.add(tileLayer: someLayer)
    tilemap.add(tileLayer: someLayer, zPosition: 1000)
    tilemap.removeLayer(name: "Tile Layer 87")
    
**Adding, Getting/Removing Tiles from a Layer**

    layer.tileAt(x: 3, y 3)
    layer.tileAt(position: CGPoint(x: 3,y: 3))
    layer.setTileAt(x: 3, y: 3, tile: aTile)
    layer.setTileAt(x: 3, y: 3, id: 90)
    layer.removeTile(x: 3, y: 3)
    layer.removeAllTiles()
    
**Tile Coordinates & Positioning**

    layer.tilePositionAt(x: 3, y: 3)
    layer.coordAtPosition(position: CGPoint)
    layer.coordAtTouchPosition(UITouch)
    
Object Groups
-
Will probably only be used if loading from a .tmx file.

**Adding and Getting Object Groups**

    tilemap.add(objectGroup: AnObjectGroup)
    tilemap.getObjectGroup(name: "Some Object Group")
    
**Adding and Getting Objects**
    
    objectGroup.addObject(SomeObject)
    objectGroup.getObject(id: 5)
    objectGroup.getObjects(name: "Gold Coin")
    objectGroup.getObjects(type: "enemy")
    
Tilesets
-
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
