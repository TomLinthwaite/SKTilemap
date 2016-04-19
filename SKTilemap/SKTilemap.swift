//
//  SKTilemap.swift
//  SKTilemap
//
//  Created by Thomas Linthwaite on 07/04/2016.
//  Copyright © 2016 Tom Linthwaite. All rights reserved.
//

import SpriteKit

// MARK: SKTilemapOrientation
enum SKTilemapOrientation : String {
    
    case Orthogonal = "orthogonal";
    case Isometric = "isometric";
    
    /** Change these values in code if you wish to have your tiles have a different anchor point upon layer initialization. */
    func tileAnchorPoint() -> CGPoint {
        
        switch self {
        case .Orthogonal:
            return CGPoint(x: 0.5, y: 0.5)
            
        case .Isometric:
            return CGPoint(x: 0.5, y: 0.5)
        }
    }
}

// MARK: SKTilemap
class SKTilemap : SKNode {
    
//MARK: Properties
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
    /** The current version of the tilemap. */
    var version: Double = 0
    
    /** The dimensions of the tilemap in tiles. */
    let size: CGSize
    private var sizeHalved: CGSize { get { return CGSize(width: size.width / 2, height: size.height / 2) } }
    
    /** The size of the grid for the tilemap. Note that tilesets may have differently sized tiles. */
    let tileSize: CGSize
    private var tileSizeHalved: CGSize { get { return CGSize(width: tileSize.width / 2, height: tileSize.height / 2) } }
    
    /** The orientation of the tilemap. See SKTilemapOrientation for valid orientations. */
    let orientation: SKTilemapOrientation
    
    /** The tilesets this tilemap contains. */
    private var tilesets: Set<SKTilemapTileset> = []
    
    /** The layers this tilemap contains. */
    private var tileLayers: Set<SKTilemapLayer> = []
    
    /** The object groups this tilemap contains */
    private var objectGroups: Set<SKTilemapObjectGroup> = []
    
    /** The display bounds the viewable area of this tilemap should be constrained to. Tiles positioned outside this 
        rectangle will not be shown. This should speed up performance for large tilemaps. If this property is not set 
        the SKView bounds will be used instead as default. */
    var displayBounds: CGRect?
    
    
    private var useTileClipping = false
    
    var enableTileClipping: Bool {
        get { return useTileClipping }
        set {
            
            if newValue == true {
                
                if displayBounds == nil && scene == nil && scene?.view == nil {
                    print("SKTiledMap: Failed to enable tile clipping. No bounds set.")
                    useTileClipping = false
                    return
                }
                else if (scene != nil && scene?.view != nil) || displayBounds != nil {
                    
                    for y in 0..<Int(size.height) {
                        for x in 0..<Int(size.width) {
                            for layer in tileLayers {
                                if let tile = layer.tileAtCoord(x, y) {
                                    tile.hidden = true
                                }
                            }
                        }
                    }
                    
                    useTileClipping = true
                    clipTilesOutOfBounds(tileBufferSize: 1)
                }
            } else {
                
                for y in 0..<Int(size.height) {
                    for x in 0..<Int(size.width) {
                        for layer in tileLayers {
                            if let tile = layer.tileAtCoord(x, y) {
                                tile.hidden = false
                            }
                        }
                    }
                }
                
                useTileClipping = false
            }
        }
    }
    
// MARK: Initialization
    
    /** Initialize an empty tilemap object. */
    init(size: CGSize, tileSize: CGSize, orientation: SKTilemapOrientation) {
        
        self.size = size
        self.tileSize = tileSize
        self.orientation = orientation
        
        super.init()
    }
    
    /** Initialize a tilemap from tmx parser attributes. Should probably only be called by SKTilemapParser. */
    init?(filename: String, tmxParserAttributes attributes: [String : String]) {
        
        guard
            let version = attributes["version"] where (Double(version) != nil),
            let width = attributes["width"] where (Int(width) != nil),
            let height = attributes["height"] where (Int(height) != nil),
            let tileWidth = attributes["tilewidth"] where (Int(tileWidth) != nil),
            let tileHeight = attributes["tileheight"] where (Int(tileHeight) != nil),
            let orientation = attributes["orientation"] where (SKTilemapOrientation(rawValue: orientation) != nil)
            else {
                print("SKTilemap: Failed to initialize with tmxAttributes.")
                return nil
        }
        
        self.version = Double(version)!
        self.orientation = SKTilemapOrientation(rawValue: orientation)!
        size = CGSize(width: Int(width)!, height: Int(height)!)
        tileSize = CGSize(width: Int(tileWidth)!, height: Int(tileHeight)!)
        
        super.init()
        
        self.name = filename
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /** Loads a tilemap from .tmx file. */
    class func loadTMX(name name: String) -> SKTilemap? {
        return SKTilemapParser().loadTilemap(filename: name)
    }
    
// MARK: Debug
    func printDebugDescription() {
        
        print("\nTilemap: \(name) (\(version)), Size: \(size), TileSize: \(tileSize), Orientation: \(orientation)")
        print("Properties: \(properties)")
        
        for tileset in tilesets { tileset.printDebugDescription() }
        for tileLayer in tileLayers { tileLayer.printDebugDescription() }
        for objectGroup in objectGroups { objectGroup.printDebugDescription() }
    }
    
// MARK: Tilesets
    
    /** Adds a tileset to the tilemap. Returns nil on failure. (A tileset with the same name already exists). Or 
        or returns the tileset. */
    func add(tileset tileset: SKTilemapTileset) -> SKTilemapTileset? {
        
        if tilesets.contains({ $0.hashValue == tileset.hashValue }) {
            print("SKTilemap: Failed to add tileset. A tileset with the same name already exists.")
            return nil
        }
        
        tilesets.insert(tileset)
        return tileset
    }
    
    /** Returns a tileset with specified name or nil if it doesn't exist. */
    func getTileset(name name: String) -> SKTilemapTileset? {
        
        if let index = tilesets.indexOf( { $0.name == name } ) {
            return tilesets[index]
        }
        
        return nil
    }
    
    /** Will return a SKTilemapTileData object with matching id from one of the tilesets associated with this tilemap
        or nil if no match can be found. */
    func getTileData(id id: Int) -> SKTilemapTileData? {
        
        for tileset in tilesets {
            
            if let tileData = tileset.getTileData(id: id) {
                return tileData
            }
        }
        
        return nil
    }
    
// MARK: Tile Layers
    
    /** Adds a tile layer to the tilemap. A zPosition can be supplied and will be applied to the layer. If no zPosition
        is supplied, the layer is assumed to be placed on top of all others. Returns nil on failure. (A layer with the
        same name already exists. Or returns the layer. */
    func add(tileLayer tileLayer: SKTilemapLayer, zPosition: CGFloat? = nil) -> SKTilemapLayer? {
        
        if tileLayers.contains({ $0.hashValue == tileLayer.hashValue }) {
            print("SKTilemap: Failed to add tile layer. A tile layer with the same name already exists.")
            return nil
        }
        
        if zPosition != nil {
            tileLayer.zPosition = zPosition!
        } else {
            
            var highestZPosition: CGFloat?
            
            for layer in tileLayers {
                
                if highestZPosition == nil {
                    highestZPosition = layer.zPosition
                }
                else if layer.zPosition > highestZPosition {
                    highestZPosition = layer.zPosition
                }
            }
            
            if highestZPosition == nil { highestZPosition = -1 }
            tileLayer.zPosition = highestZPosition! + 1
        }
        
        tileLayers.insert(tileLayer)
        addChild(tileLayer)
        centerLayer(tileLayer)
        return tileLayer
    }
    
    /** Positions a tilemap layer so that its center position is resting at the tilemaps 0,0 position. */
    private func centerLayer(layer: SKTilemapLayer) {
        
        if orientation == .Orthogonal {
            layer.position = CGPoint(x: -sizeHalved.width * tileSize.width,
                                     y: sizeHalved.height * tileSize.height)
        }
        
        if orientation == .Isometric {
            layer.position = CGPoint(x: -((sizeHalved.width - sizeHalved.height) * tileSizeHalved.width),
                                     y: ((sizeHalved.width + sizeHalved.height) * tileSizeHalved.height))
        }
        
        /* Apply the layers offset */
        layer.position.x += (layer.offset.x + layer.offset.x * orientation.tileAnchorPoint().x)
        layer.position.y -= (layer.offset.y - layer.offset.y * orientation.tileAnchorPoint().y)
    }
    
    /* Get all layers in a set. */
    func getLayers() -> Set<SKTilemapLayer> {
        return tileLayers
    }
    
    /** Returns a tilemap layer with specified name or nil if one does not exist. */
    func getLayer(name name: String) -> SKTilemapLayer? {
        
        if let index = tileLayers.indexOf( { $0.name == name } ) {
            return tileLayers[index]
        }
        
        return nil
    }
    
    /** Removes a layer from the tilemap. The layer removed is returned or nil if the layer wasn't found. */
    func removeLayer(name name: String) -> SKTilemapLayer? {
        
        if let layer = getLayer(name: name) {
            
            layer.removeFromParent()
            tileLayers.remove(layer)
            return layer
        }
        
        return nil
    }
    
    /** Will "clip" tiles outside of the tilemaps 'displayBounds' property if set or the SKView bounds (if it's a child
        of a view... which it should be). 
        You must call this function when ever you reposition the tilemap so it can update the visible tiles. 
        For example in a scenes TouchesMoved function if scrolling the tilemap with a touch or mouse. */
    func clipTilesOutOfBounds(scale scale: CGFloat = 1.0, tileBufferSize: CGFloat = 2) {
        
        if !useTileClipping { return }
        
        for layer in tileLayers {
            layer.clipTilesOutOfBounds(displayBounds, scale: scale, tileBufferSize: tileBufferSize)
        }
    }
    
// MARK: Object Groups
    
    /** Adds an object group to the tilemap. Returns nil on failure. (An object group with the same name already exists.
        Or returns the object group. */
    func add(objectGroup objectGroup: SKTilemapObjectGroup) -> SKTilemapObjectGroup? {
        
        if objectGroups.contains({ $0.hashValue == objectGroup.hashValue }) {
            print("SKTilemap: Failed to add object layer. An object layer with the same name already exists.")
            return nil
        }
        
        objectGroups.insert(objectGroup)
        return objectGroup
    }
    
    /** Returns a object group with specified name or nil if it does not exist. */
    func getObjectGroup(name name: String) -> SKTilemapObjectGroup? {
        
        if let index = objectGroups.indexOf( { $0.name == name } ) {
            return objectGroups[index]
        }
        
        return nil
    }
}