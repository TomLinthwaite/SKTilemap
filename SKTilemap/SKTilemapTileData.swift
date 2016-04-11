//
//  SKTileData.swift
//  SKTilemap
//
//  Created by Thomas Linthwaite on 07/04/2016.
//  Copyright © 2016 Tom Linthwaite. All rights reserved.
//

import SpriteKit

// MARK: SKTileData
class SKTilemapTileData : Equatable, Hashable {
    
    // MARK: Properties
    var hashValue: Int { get { return self.id.hashValue } }
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
    /** The tile datas ID. */
    let id: Int
    
    /** Weak pointer to the tileset this data belongs to. */
    weak var tileset: SKTilemapTileset!
    
    /** The texture used to draw tiles with this data. */
    let texture: SKTexture
    
    /** The filename of the texture used for this data. If it is empty the tileset used a spritesheet to create the
     the texture for this data. */
    let source: String
    
// MARK: Initialization
    init(id: Int, texture: SKTexture, tileset: SKTilemapTileset) {
        
        self.id = id
        self.tileset = tileset
        source = ""
        self.texture = texture
        texture.filteringMode = .Nearest
    }
    
    init(id: Int, imageNamed source: String, tileset: SKTilemapTileset) {
        
        self.id = id
        self.tileset = tileset
        self.source = source
        texture = SKTexture(imageNamed: source)
        texture.filteringMode = .Nearest
    }
    
// MARK: Debug
    func printDebugDescription() {
        print("TileData: \(id), Source: \(source), Properties: \(properties)")
    }
}

func ==(lhs: SKTilemapTileData, rhs: SKTilemapTileData) -> Bool {
    return (lhs.hashValue == rhs.hashValue)
}


// MARK: SKTile
class SKTilemapTile : SKNode {
    
// MARK: Properties
    
    /** The tile data this tile represents. */
    let tileData: SKTilemapTileData
    
    /** The sprite of the tile. */
    let sprite: SKSpriteNode
    
// MARK: Initialization
    
    /* Initialize an SKTile using SKTileData. */
    init(tileData: SKTilemapTileData) {
        
        self.tileData = tileData
        sprite = SKSpriteNode(texture: tileData.texture)
        
        super.init()
        
        addChild(sprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}