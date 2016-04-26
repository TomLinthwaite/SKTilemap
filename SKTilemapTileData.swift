/*
 SKTilemap
 SKTilemapTileData.swift
 
 Created by Thomas Linthwaite on 07/04/2016.
 GitHub: https://github.com/TomLinthwaite/SKTilemap
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

// MARK: SKTileData
class SKTilemapTileData : Equatable, Hashable {
    
    // MARK: Properties
    var hashValue: Int { get { return self.id.hashValue } }
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
    /** The tile datas ID. */
    let id: Int
    
    /** Returns the Tile ID you would see in Tiled. */
    var rawID: Int { get { return self.id - self.tileset.firstGID } }
    
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
        texture.filteringMode = .Nearest
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