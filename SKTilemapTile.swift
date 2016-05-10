/*
 SKTilemap
 SKTilemapTile.swift
 
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

// MARK: SKTile
class SKTilemapTile : SKSpriteNode {
    
// MARK: Properties
    
    /** The tile data this tile represents. */
    var tileData: SKTilemapTileData
    
    /** The layer this tile is on. */
    let layer: SKTilemapLayer
    
// MARK: Initialization
    
    /* Initialize an SKTile using SKTileData. */
    init(tileData: SKTilemapTileData, layer: SKTilemapLayer) {
        
        self.tileData = tileData
        self.layer = layer
        
        super.init(texture: tileData.texture, color: SKColor.clearColor(), size: tileData.texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: Animation
    
    /** Will start the animation from this tiles tileData if it has one. */
    func playAnimation(tilemap: SKTilemap, loopForever: Bool = true) {
        
        if let animation = tileData.getAnimation(tilemap) {
            
            if loopForever {
                runAction(SKAction.repeatActionForever(animation), withKey: "tile animation")
            } else {
                runAction(animation, withKey: "tile animation")
            }
        }
    }
    
    /** Stops the tile animating. */
    func stopAnimation() {
        removeActionForKey("tile animation")
    }
}