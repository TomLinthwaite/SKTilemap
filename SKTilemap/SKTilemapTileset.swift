//
//  SKTilemapTileset.swift
//  SKTilemap
//
//  Created by Thomas Linthwaite on 07/04/2016.
//  Copyright © 2016 Tom Linthwaite. All rights reserved.
//

import SpriteKit

// MARK: SKTilemapTileset
class SKTilemapTileset : Equatable, Hashable {
    
    // MARK: Properties
    var hashValue: Int { get { return name.hashValue } }
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
    /** The first GID of data within the tileset. */
    let firstGID: Int
    
    /** The name of this tileset. This name should be unique per tileset added to the tilemap. */
    let name: String
    
    /** The filename of the source image used for this tileset. This will only be used if the tileset was created from
     a single image. */
    var source = ""
    
    /** Spacing in pixels between tiles within the source image. Only used when creating tiles from a single image
     (sprite sheet). */
    var spacing = 0
    
    /** Margin in pixels around the edges of the source image. Only used when creating tiles from a single image.
     (sprite sheet) */
    var margin = 0
    
    /** The size of each tile. */
    let tileSize: CGSize
    
    /** Offset from tile position when drawing tiles. */
    var tileOffset = CGPointZero
    
    /** A set containing all of the tile data for this tileset. */
    private var tileData: Set<SKTileData> = []
    
// MARK: Initialization
    
    /** Initialize an empty tileset. */
    init(name: String, firstGID: Int, tileSize: CGSize, tileOffset: CGPoint = CGPointZero) {
        
        self.name = name
        self.firstGID = firstGID
        self.tileSize = tileSize
        self.tileOffset = tileOffset
    }
    
    /** Initialize using TMX Parser attributes. Should probably only be called by SKTilemapParser. */
    init?(tmxParserAttributes attributes: [String : String]) {
        
        guard
            let firstGID = attributes["firstgid"] where (Int(firstGID) != nil),
            let name = attributes["name"],
            let tileWidth = attributes["tilewidth"] where (Int(tileWidth) != nil),
            let tileHeight = attributes["tileheight"] where (Int(tileHeight) != nil)
            else {
                print("SKTilemapTileset: Failed to initialize with tmxAttributes.")
                return nil
        }
        
        self.firstGID = Int(firstGID)!
        self.name = name
        self.tileSize = CGSize(width: Int(tileWidth)!, height: Int(tileHeight)!)
        
        /* Optional attributes */
        if let spacing = attributes["spacing"] where (Int(spacing) != nil) { self.spacing = Int(spacing)! } else { spacing = 0 }
        if let margin = attributes["margin"] where (Int(margin) != nil) { self.margin = Int(margin)! } else { margin = 0 }
    }
    
// MARK: Debug
    func printDebugDescription() {
        
        print("\nTileset: \(name), firstGID: \(firstGID), TileSize: \(tileSize), TileOffset: \(tileOffset), Source: \(source), Margin: \(margin), Spacing: \(spacing)")
        print("Properties: \(properties)")
        
        for tile in tileData { tile.printDebugDescription() }
    }
    
// MARK: Tile Data
    
    /** Add tile data to the tileset using a sprite sheet. */
    func addTileData(spriteSheet source: String) {
        
        self.source = source
        let texture = SKTexture(imageNamed: source)
        let width = Int(texture.size().width)
        let height = Int(texture.size().height)
        let tilesPerRow = (width - (margin * 2) + spacing) / (Int(tileSize.width) + spacing)
        let tilesPerCol = (height - (margin * 2) + spacing) / (Int(tileSize.height) + spacing)
        let totalTiles = tilesPerCol * tilesPerRow
        var x = margin
        var y = margin + (Int(tileSize.height) * tilesPerCol) + (spacing * (tilesPerCol - 1)) - Int(tileSize.height)
        
        for id in firstGID..<(firstGID + totalTiles) {
            
            let rX = CGFloat(x) / CGFloat(width)
            let rY = CGFloat(y) / CGFloat(height)
            let rW = tileSize.width / CGFloat(width)
            let rH = tileSize.height / CGFloat(height)
            let rect = CGRect(x: rX, y: rY, width: rW, height: rH)
            
            let texture = SKTexture(rect: rect, inTexture: texture)
            addTileData(id: id, texture: texture)
            
            x += Int(tileSize.width) + spacing
            if x >= width {
                x = margin
                y -= Int(tileSize.height) + spacing
            }
        }
    }
    
    /** Add a single SKTileData object to this tileset with texture. Will return the tile data object that was added on
        success or nil on failure. */
    func addTileData(id id: Int, texture: SKTexture) -> SKTileData? {
        
        if self.tileData.contains({ $0.hashValue == id.hashValue }) {
            print("SKTilemapTileset: Failed to add tile data. Tile data with the same id already exists.")
            return nil
        }
        
        let tileData = SKTileData(id: id, texture: texture, tileset: self)
        self.tileData.insert(tileData)
        return tileData
    }
    
    /** Add a single SKTileData object to this tileset. It's texture is loaded from a file provided from the filename.
        Will return the tile data object that was added on success or nil on failure. */
    func addTileData(id id: Int, imageNamed source: String) -> SKTileData? {
        
        if self.tileData.contains({ $0.hashValue == id.hashValue }) {
            print("SKTilemapTileset: Failed to add tile data. Tile data with the same id already exists.")
            return nil
        }
        
        let tileData = SKTileData(id: id, imageNamed: source, tileset: self)
        self.tileData.insert(tileData)
        return tileData
    }
    
    /** Returns a SKTileData object contained within this tileset matching the ID. Returns nil on failure. */
    func getTileData(id id: Int) -> SKTileData? {
        
        if let index = tileData.indexOf( { $0.id == id } ) {
            return tileData[index]
        }
        
        return nil
    }
}

func ==(lhs: SKTilemapTileset, rhs: SKTilemapTileset) -> Bool {
    return (lhs.hashValue == rhs.hashValue)
}