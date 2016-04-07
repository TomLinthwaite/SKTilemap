//
//  SKTileData.swift
//  SKTilemap
//
//  Created by Thomas Linthwaite on 07/04/2016.
//  Copyright © 2016 Tom Linthwaite. All rights reserved.
//

import SpriteKit

// MARK: SKTileData
class SKTileData : TMXTilemapProtocol, Equatable, Hashable {
    
    // MARK: Properties
    var hashValue: Int { get { return self.id.hashValue } }
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
    /** The tile datas ID. */
    let id: Int
    
    /** Weak pointer to the tileset this data belongs to. */
    weak var tileset: SKTilemapTileset?
    
    /** The texture used to draw tiles with this data. */
    let texture: SKTexture
    
    /** The filename of the texture used for this data. If it is empty the tileset used a spritesheet to create the
     the texture for this data. */
    let source: String
    
// MARK: Initialization
    init(id: Int, texture: SKTexture, tileset: SKTilemapTileset) {
        
        self.id = id
        self.tileset = tileset
        self.texture = texture
        source = ""
    }
    
    init(id: Int, source: String, tileset: SKTilemapTileset) {
        
        self.id = id
        self.tileset = tileset
        self.source = source
        texture = SKTexture(imageNamed: source)
    }
    
// MARK: Debug
    func printDebugDescription() {
        print("TileData: \(id), Source: \(source), Properties: \(properties)")
    }
}

func ==(lhs: SKTileData, rhs: SKTileData) -> Bool {
    return (lhs.hashValue == rhs.hashValue)
}