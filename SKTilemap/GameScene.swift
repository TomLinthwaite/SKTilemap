//
//  GameScene.swift
//  SKTilemap
//
//  Created by Thomas Linthwaite on 07/04/2016.
//  Copyright (c) 2016 Tom Linthwaite. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: Properties
    
    // MARK: Initialization
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        if let tilemap = SKTilemapParser().loadTilemap(filename: "tilemap_iso_csv") {
            tilemap.printDebugDescription()
        }
    }
    
    // MARK: Input
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
}
