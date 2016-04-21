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
    
    /** The tile IDs and durations used for animating this tile. */
    var animationFrames: [(id: Int, duration: CGFloat)] = []
    
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
        //texture.filteringMode = .Nearest
    }
    
// MARK: Debug
    func printDebugDescription() {
        print("TileData: \(id), Source: \(source), Properties: \(properties)")
    }
    
// MARK: Animation
    
    /** Returns the animation for this tileData if it has one. The animation is created from the animationFrames property. */
    func getAnimation(tilemap: SKTilemap) -> SKAction? {
        
        if animationFrames.isEmpty {
            return nil
        }
        
        var frames: [SKAction] = []
        
        for frameData in animationFrames {
            
            if let texture = tilemap.getTileData(id: frameData.id)?.texture {
                
                let textureAction = SKAction.setTexture(texture)
                let delayAction = SKAction.waitForDuration(NSTimeInterval(frameData.duration / 1000))
                frames.append(SKAction.group([textureAction, delayAction]))
            }
        }
        
        return SKAction.sequence(frames)
    }
}

func ==(lhs: SKTilemapTileData, rhs: SKTilemapTileData) -> Bool {
    return (lhs.hashValue == rhs.hashValue)
}