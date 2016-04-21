//
//  SKTilemapTile.swift
//  SKTilemap
//
//  Created by Thomas Linthwaite on 14/04/2016.
//  Copyright © 2016 Tom Linthwaite. All rights reserved.
//

import SpriteKit

// MARK: SKTile
class SKTilemapTile : SKSpriteNode {
    
// MARK: Properties
    
    /** The tile data this tile represents. */
    var tileData: SKTilemapTileData
    
// MARK: Initialization
    
    /* Initialize an SKTile using SKTileData. */
    init(tileData: SKTilemapTileData) {
        
        self.tileData = tileData
        
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