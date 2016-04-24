#SKTilemap Change Log

###Latest - 24th April 2016

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
