//
//  SKTilemap.swift
//  SKTilemap
//
//  Created by Thomas Linthwaite on 07/04/2016.
//  Copyright © 2016 Tom Linthwaite. All rights reserved.
//

import SpriteKit

// MARK: TMXTilemapProtocol
protocol TMXTilemapProtocol {
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] { get }
}

// MARK: SKTilemapOrientation
enum SKTilemapOrientation : String {
    
    case Orthogonal = "orthogonal";
    case Isometric = "isometric";
}

// MARK: SKTilemap
class SKTilemap : SKNode, TMXTilemapProtocol {
    
//MARK: Properties
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
    /** The current version of the tilemap. */
    let version: Double
    
    /** The dimensions of the tilemap in tiles. */
    let size: CGSize
    
    /** The size of the grid for the tilemap. Note that tilesets may have differently sized tiles. */
    let tileSize: CGSize
    
    /** The orientation of the tilemap. See SKTilemapOrientation for valid orientations. */
    let orientation: SKTilemapOrientation
    
    /** The tilesets this tilemap contains. */
    private var tilesets: Set<SKTilemapTileset> = []
    
    /** The layers this tilemap contains. */
    private var tileLayers: Set<SKTilemapLayer> = []
    
    /** The object groups this tilemap contains */
    private var objectGroups: Set<SKTilemapObjectGroup> = []
    
// MARK: Initialization
    
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
                if zPosition == nil {
                    highestZPosition = layer.zPosition
                }
                else if layer.zPosition > highestZPosition {
                    highestZPosition = layer.zPosition
                }
            }
            
            if highestZPosition == nil { highestZPosition = 0 }
            tileLayer.zPosition = highestZPosition!
        }
        
        tileLayers.insert(tileLayer)
        addChild(tileLayer)
        return tileLayer
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
}