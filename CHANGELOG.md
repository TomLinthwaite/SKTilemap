#SKTilemap Change Log

###Latest - 11th May 2016

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
