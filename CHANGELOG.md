#SKTilemap Change Log

###Latest - 25th May 2016

+ **New Property** - * SKTilemap* - `var nextGID: Int`
    + Provides the next avaible GID ready to be used inside this tilemap. Useful for when you're adding tilesets at run time and want to avoid conflicting GIDs.
+ **New Property** - * SKTilemap* - `func anyLayer() -> SKTilemapLayer?`
    + I wasn't sold on this idea when I first implemented it but it's grown on me while working in my own project so its staying. This is useful for when you want quick access to layer functions, such as finding a coord at touch position and it doesn't matter which layer it is. Be warned though, if you have layers with different offsets results may vary from what you expect. Only use this function if you expect your layers to be uniform in position.
+ **Updated Property** - * SKTilemapCamera* - `var enabled: Bool`
    + Is now a computed property and enables/disables the Gesture Recognizers when running on iOS.
+ **New Function** - *SKTilemapLayer* - `func initializeTilesWithID(id: Int)`
    + Initialize the layer with a single tile GID. (All tiles will be set to this GID.
+ **New Function** - *SKTilemapPathFindingExtension* - `func nextPositionOnPathFrom(x: Int32, y: Int32, toX: Int32, toY: Int32) -> (x: Int32, y: Int32, distance: Int)?`
    + **New Function** - *SKTilemapPathFindingExtension* - `func nextPositionOnPathFrom(position: CGPoint, to: CGPoint) -> (position: CGPoint, distance: Int)?`
+ **New Function** - *SKTilemapPathFindingExtension* - `func nextPositionOnPathFrom(position: vector_int2, to: vector_int2) -> (position: vector_int2, distance: Int)?`
    +   Three new helper functions when working with path finding. These functions in essence all return the same thing. The next point along a path from one point to another. The function return type is a tuple and also returns the total distance of the path. I added this in because I found it useful when developing my game. The AI could determine whether to bother following the path based on its distance.
+ **New Property** - *SKTilemapTileset* - `var lastGID: Int`
    + Returns the last GID inside this tileset. Useful if you want to add to it. lastGID + 1 will be your next GID.
+ **New Initializer** - *SKTilemapTileset* - `convenience init(name: String, atlasName: String, firstGID: Int, tileSize: CGSize, tileOffset: CGPoint = CGPointZero)`
    + Tilesets now support loading tile data from an atlas file. All images within the atlas will be added as individual TileData objects to the tileset. How ever, GIDs cannot be garunteed when adding tile data this way. Therefore you must use the new function *'func getTileData(name: String) -> SKTilemapTileData?'* to get at your tile data stored within the tileset. The name you will use will be the images source name (with or without the .extension). 
+ **New Function** - *SKTilemapTileset* - `func addTileData(atlasName atlasName: String, atlas: SKTextureAtlas)`
+ **New Function** - *SKTilemapTileset* - `func addTileData(atlasName atlasName: String)`
    + You can now add tile data to a tileset using images found inside a SKTextureAtlas. Both functions do essentially the same thing, except the latter will load the texture atlas on the spot. The other function (which takes an SKTextureAtlas as an argument) is primarily to be used when you have already loaded the texture atlas - maybe you loaded all your resources when the app/level started etc...
+ **New Function** - *SKTilemapTileset* - `func getTileData(name: String) -> SKTilemapTileData?`
    + Returns a TileData object with a certain name. The name will be the same as the image name used to create it (with or without the .extension). Note that only TileData objects created through an .atlas or added with an image name will can be retrieved. If you loaded this tileset from a sprite sheet or added tile data with only a texture this function will not find the tile. This is because there is no way of knowing what the source image is called.
    
**Note**
Just a quick note on why you have to provide a name for you atlas if you are already providing the SKTextureAtlas object when adding to a tileset. The reason is because eventually I will get round to writing features that will Save/Load your current tilemap state. The name will be required because the tileset will need to know how it get its tiles.


**11th May 2016**

+ **New Extension** - *SKTilemapPathFindingExtension*
+ SKTilemap now supports Path Finding! The example project has also been updated to show how to use it. (which is very simple).
+ **New Function** - *SKTilemapPathFindingExtension* - `func initializeGraph(collisionProperty collisionProperty: String, collisionLayerNames: [String]? = nil, diagonalsAllowed: Bool) -> Bool`
    + Initializes the path finding graph. Tiles on the layers named that have the collision property are treated as collidable (walls / non-walkable). Naming all of the collision layers isn't required. If no names are supplied all layer tiles are checked for the corresponding property.
+ **New Function** - *SKTilemapPathFindingExtension* - `func initializeGraph(collisionLayerName collisionLayerName: String, diagonalsAllowed: Bool) -> Bool`
    + Initializes the path finding graph. All tiles on the given layer are treated as collidable tiles (walls / non-walkable).
+ **New Function** - *SKTilemapPathFindingExtension* - `func findPathFrom(x x: Int32, y: Int32, toX: Int32, toY: Int32, removeStartPosition: Bool = true) -> [CGPoint]?`
+ **New Function** - *SKTilemapPathFindingExtension* - `findPathFrom(position: CGPoint, toPosition: CGPoint, removeStartPosition: Bool = true) -> [CGPoint]?`
    + Find a path from a start grid position to an end grid position. Will return nil if no path can be found. Optional parameter removes the starting position from the returned graph, which is usually desired. How ever it can be turned off. Returns an array of tilemap coordinates representing the path from start to finish.
+ **New Function** - *SKTilemapPathFindingExtension* - `func removeGraphNodeAtPosition(x x: Int32, y: Int32)`
+ **New Function** - *SKTilemapPathFindingExtension* - `func removeGraphNodeAtPosition(position: CGPoint)`
    + Removes a node from the graph. This node can no longer be used when finding a path.
+ **New Function** - *SKTilemapPathFindingExtension* - `func addGraphNodeAtPosition(x x: Int32, y: Int32)`
+ **New Function** - *SKTilemapPathFindingExtension* - `func addGraphNodeAtPosition(position: CGPoint)`
    + Adds a previously removed node to the grid. Does nothing if the grid already has a node at this position. Nodes that are added to the grid become valid path positions.
+ **New Function** - *SKTilemapPathFindingExtension* - `func resetGraph()`
    + Re-adds all nodes that were removed from the graph. This resets the graph to the state it was in when it was first initialized.
+ **New Property** - * SKTilemap* - `var width: Int { return Int(size.width) }`
+ **New Property** - * SKTilemap* - `var height: Int { return Int(size.height) }`
    + Added these to help clean up the code a bit instead of calling Int(n) all the time. Makes sense since these properties should never have a value thats not an Int.

**10th May 2016**

+ **New Property** - *SKTilemapTile* - `let layer: SKTilemapLayer`
    + A tile now has a reference to the layer it belongs to. 
+ **New Property** - *SKTilemapCamera* - `private var longPressGestureRecognizer: UILongPressGestureRecognizer!`
+ **New Property** - *SKTilemapCamera* - `private var previousLocation: CGPoint!`
    + The camera no longer requires you to update the position outside of its own class. (For example in the scene touchesMoved method). Instead a UILongPressGestureRecognizer is created and added to the view on initialization. This change keeps the code cleaner and lets the class handle itself.
+ **New Function** - *SKTilemapCamera* - `func centerOnPosition(scenePosition: CGPoint, easingDuration: NSTimeInterval = 0)`
+ **New Function** - *SKTilemapCamera* - `func centerOnNode(node: SKNode?, easingDuration: NSTimeInterval = 0)`
    + Two new functions for the camera useful for following/focusing on nodes in the scene. Moves the camera so it centers on a certain position within the scene. Easing can be applied by setting a timing value. Otherwise the camera position is updated instantly.

**26th April 2016**

+ **New Class** - *SKTilemapCamera* - `class SKTilemapCamera : SKCameraNode`
    + After a lot of deliberating I've decided to bring the camera class in to the project. It's still not required by SKTilemap and is very much just an additional extra.
+ **New Extension** - *SKTilemapCameraExtension* - `extension SKTilemap : SKTilemapCameraDelegate`
    + Because I didn't want the SKTilemap class itself to know about the camera I decided to create an extension that will respond to camera events. This gives the tilemap a chance to react when the camera moves/zooms or changes its bounds. As I said before you can totally remove this file and the camera and the tilemap will still work as expected.
+ **Misc.** - *Example Code Update*
    + I've re-written the GameScene class to show how to use most of the features within SKTilemap as well as setup the new camera.

**24th April 2016**

+ **New Property** - *SKTilemap* - `var minTileClippingScale: CGFloat`
    + When tile clipping is enabled this property will disable it when the scale passed in goes below this threshold. This is important because the tile clipping can cause serious slow down when a lot of tiles are drawn on screen. Experiment with this value to see what's best for your map. This is only needed if you plan on scaling the tilemap. 
+ **Removed Property** - *SKTilemapObject* - `let position: CGPoint`
+ **New Function** - *SKTilemapObject* - `func positionOnLayer(layer: SKTilemapLayer) -> CGPoint`
    + Position of an object didn't make sense. I tried a few ways to get it working nicely and as expected every time but the truth of the matter is, with the difference in y axis, anchor points and offsets of all of the tile layers/object layers and tiles a set position just didn't feel right and would require to much information from the rest of the map which I didn't want an Object to know about. 
        I've settled for an alternative of getting a position of an object based on a layer already added to the tilemap. This makes it easier to get the position you want at a particular place on the map and solves all of the issues I mentioned above.
+ **New Property** - *SKTilemapObjectGroup* - `let offset: CGPoint`
    + Tiled lets you offset your object layer, so now SKTilemap does to!
+ **Renamed Function** - *SKTilemapObjectGroup* - `func allObjects() -> [SKTilemapObject]` to `func getObjects() -> [SKTilemapObject]`
    + Not sure why I called it allObjects yesterday... Didn't fit with the naming convention for framework.

**23rd April 2016**

+ Created change log...
+ **New Function** - *SKTilemapObjectGroup* - `func allObjects() -> [SKTilemapObject]`
    + Returns an array containing all objects belonging to a group.
+ **New Property** - *SKTilemapTileData* - `var rawID: Int`
