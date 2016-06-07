/*
 SKTilemap
 GameScene.swift
 
 Created by Thomas Linthwaite on 07/04/2016.
    GitHub: https://github.com/TomLinthwaite/SKTilemap
    Website (Guide): http://tomlinthwaite.com/
    Wiki: https://github.com/TomLinthwaite/SKTilemap/wiki
    YouTube: https://www.youtube.com/channel/UCAlJgYx9-Ub_dKD48wz6vMw
    Twitter: https://twitter.com/Mr_Tomoso
 
 -----------------------------------------------------------------------------------------------------------------------
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
 -----------------------------------------------------------------------------------------------------------------------
 */

import SpriteKit

// MARK: GameScene
class GameScene: SKScene {
    
// MARK: Properties
    
    /* Everything affected by the camera should be added to this node. This is the root node for all game related objects. */
    let worldNode = SKNode()
    
    /* A camera to help pan/zoom around the scene. Custom bounds can be set that the worldNode will be constrained to.
        by default these bounds are set to the size of the view. */
    var sceneCamera: SKTilemapCamera!
    
    /* The tilemap object. */
    var tilemap: SKTilemap!
    
// MARK: Initialization
    override init(size: CGSize) {
        
        super.init(size: size)
        
        /* Add the world node to the scene. */
        addChild(worldNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        /* Initial Setup */
        /**************************************************************************************************************/
 
        /* Create the camera and add it to the scene. */
        sceneCamera = SKTilemapCamera(scene: self, view: view, worldNode: worldNode)
        addChild(sceneCamera)
        camera = sceneCamera
        
        /* These settings are at their default values and are only here as an example. */
        sceneCamera.enabled = true
        sceneCamera.allowZoom = true
        sceneCamera.zoomRange.min = 0.1
        sceneCamera.zoomRange.max = 2.0
        
        /* Load Tilemap from .tmx file. */
        guard let tilemap = SKTilemap.loadTMX(name: "tilemap_example") else {
            fatalError("Failed to load tilemap.")
        }
        
        /* Add the tilemap to the scene (through the worldNode). */
        self.tilemap = tilemap
        self.worldNode.addChild(tilemap)
        
        /* Add the tilemap as a delegate to the camera. The tilemap will now recieve events when the camera updates its
            position/scale or bounds. */
        sceneCamera.addDelegate(tilemap)
        
        /* Tilemap settings */
        /**************************************************************************************************************/
        
        /* Will hide tiles outside of the tilemaps.displayBounds. By default the display bounds are set to the size of the
            view. How ever custom bounds can be set if you wish to not have the tilemap take up the whole view. 
            If the tilemap is an SKTilemapCamera delegate, its display bounds will be updated when the camera changes its
            bounds. */
        tilemap.enableTileClipping = true
        tilemap.displayBounds = sceneCamera.getBounds()
        
        /* Turn tile clipping off if the tilemap map is scaled below this threshold. Only relevant if you allow the camera
            to scale and use tile clipping. Tile clipping does improve performance for large maps, but performance can
            drop when there are a lot of tiles within the viewable area. Setting this prevents that performance drop. */
        tilemap.minTileClippingScale = 0.6
        
        /* The tilemap itself defaults to 0,0 positon on the worldNode. Changing its alignment will determine where its
            layers are drawn. The default alignment is 0.5,0.5. Layers will have there center at the center of the scene. */
        tilemap.alignment = CGPoint(x: 0.5, y: 0.5)
        
        /* Qucik example usage of the new function inside a tileset. Tiles not used in example, but see the console to
            check it worked. */
        tilemap.getTileset(name: "tmw_desert_spacing")?.addTileData(atlasName: "iso_tileset")
        //print("\(tilemap.getTileset(name: "tmw_desert_spacing")?.getTileData("dirt.png")?.tileset.textureAtlasName)")
        
        /* Initialize Path Finding Graph. 
            There are two ways to initialize a path finding graph for your tilemap. The first way (the way that has NOT
            been commented out) checks a certain layer for tiles. If there is a tile at a certain position the tile is
            assumed to be impassable/unwalkable/collidable and will not be used when finding paths. This is a common 
            way to do things when using Tiled as you get a visual represtantion. This layer is usually set to "hidden"
            and will not appear in the game. How ever for this example is has been left on. Check out the .tmx file
            to see how it works. */
        tilemap.initializeGraph(collisionLayerName: "collision layer", diagonalsAllowed: false)
        
        /* The second way is to have each tile have a certain property that you set either programatically or in Tiled.
            The property can be called anything you want and does not need a value. 
            When initializing a graph this way you can provide the names of the layers you wish to check for tiles with
            that property. The parameter is not required though and if left out all layers will be checked. Any tile found
            within any layer named here will be treated as collidable. */
        //tilemap.initializeGraph(collisionProperty: "collidable", collisionLayerNames: ["tile layer"], diagonalsAllowed: true)
        
        /* Loading custom objects */
        /**************************************************************************************************************/
        
        /* If you haven't done so already, open the example map in Tiled to get a better understanding of how the map is
            constructed. */
        
        /* Get an object group by name. In Tiled this is called an object layer. */
        if let objectGroup = tilemap.getObjectGroup(name: "object group") {
            
            /* In the example map there are only 2 objects. Niether has a name, but they do have a type. To get all objects
                that share a similar type use the function below. It will return an array of those objects. If no obects
                are found the array will be empty. */
            let objects = objectGroup.getObjects(type: "sign")
            
            /* For each of the objects with type sign, create a sprite node and add it to the worldNode. */
            for object in objects {
                
                if let layer = tilemap.getLayer(name: "tile layer") {
                    
                    /* Get the position this object should be at using the tile layer.
                     The position returned will be that of the tile at this location. This is important because tiles can
                     have different anchorPoints, layers can have offsets and the map its self can be aligned differently. */
                    let layerPosition = object.positionOnLayer(layer)
                    
                    /* We now have the position the object should be if it were placed on "tile layer". But in reality
                        its probably a bad idea to add objects directly to the layer. It would be better if all your game
                        objects shared the same coordinate space. This includes the player, enemies and anything else. 
                        So instead we will add this object to the worldNode. */
                    let worldPosition = worldNode.convertPoint(layerPosition, fromNode: layer)
                    
                    /* This new sprite will share a texture loaded from the tileset. It could easily be loaded from else
                        where. For this example we know the tile with ID 46 represents a sign so we will use that. */
                    let texture = tilemap.getTileData(id: 46)!.texture
                    let sprite = SKSpriteNode(texture: texture)
                    sprite.position = worldPosition
                    sprite.zPosition = layer.zPosition + 1 /* Just to make sure its drawn above anything else. */
                    worldNode.addChild(sprite)
                    
                    /* We want the sign to be "collidable" so remove the node at its position within the path finding
                        graph. */
                    tilemap.removeGraphNodeAtPosition(object.coord)
                }
            }
            
            /* You should now see signs on the tilemap at their respective object locations within the .tmx file. */
        }
    }
    
// MARK: Input iOS
    
#if os(iOS)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            /* Getting Tiles at Touch Position */
            /**********************************************************************************************************/
            if let tile = tilemap.getLayer(name: "tile layer")?.tileAtTouchPosition(touch) {
                /* I have added a property to each tile called "description", lets print the tiles description to
                    the console when it is touched. Note that I forcibly unwrapped the property. In practice its
                    a bad idea to do this. */
                print("Tile Description Proerty: \(tile.tileData.properties["description"]!)")
            }
            
            /* Getting Objects at Touch Position */
            /**********************************************************************************************************/
            
            /* Find out the coordinate of the tile that was touched. */
            if let coord = tilemap.getLayer(name: "tile layer")?.coordAtTouchPosition(touch) {
                
                if let object = tilemap.getObjectGroup(name: "object group")?.getObjectAtCoord(coord) {
                    
                    /* There are two objects on the map (remember we added them earlier). They don't have to be added to
                        the map in order for this to work. They just have to be in the object group. 
                     For each sign I added a "message" property. Lets print this to the console. Note that I forcibly 
                     unwrapped the property. In practice its a bad idea to do this. */
                    print("Object Message: \(object.properties["message"]!)")
                }
                
                /* A cheap way to check if the path finding is working. Will find a path from the center of the map to
                    where ever was touched. The path is shown by changing the alpha of the tiles along the path. */
                guard let path = tilemap.findPathFrom(CGPoint(x: 16, y: 16), to: coord, removeStartPosition: false) else { continue }
                
                for y in 0..<tilemap.height {
                    for x in 0..<tilemap.width {
                        tilemap.getLayer(name: "tile layer")?.tileAtCoord(x, y)?.alpha = 1.0
                    }
                }
                
                for point in path {
                    tilemap.getLayer(name: "tile layer")?.tileAtCoord(point)?.alpha = 0.5
                }
            }
            
            /* Try running this in the simulator to see the results. Touching anywhere on the tilemap will print the tile
                at the touch locations description to the console. Touching an object will print its message property. */
        }
    }
#endif
    
// MARK: Input OSX
    
#if os(OSX)
    override func mouseDown(theEvent: NSEvent) {
    }
    
    override func mouseUp(theEvent: NSEvent) {
        sceneCamera.finishedInput()
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        sceneCamera.updatePosition(theEvent)
        
    }
    
    override func didChangeSize(oldSize: CGSize) {
    
        guard let view = scene?.view else { return }
        
        let bounds = CGRect(x: -(view.bounds.width / 2),
                            y: -(view.bounds.height / 2),
                            width: view.bounds.width,
                            height: view.bounds.height)
        
        sceneCamera.updateBounds(bounds)
    }
#endif
}