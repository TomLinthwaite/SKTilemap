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
    var tilemap: SKTilemap?
    let worldNode: SKNode
    var sceneCamera: Camera!
    
    // MARK: Initialization
    override init(size: CGSize) {
        
        worldNode = SKNode()
        
        super.init(size: size)
        
        addChild(worldNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        sceneCamera = Camera(scene: self, view: view, worldNode: worldNode)
        addChild(sceneCamera)
        camera = sceneCamera
        
        if let tilemap = SKTilemapParser().loadTilemap(filename: "tilemap_iso_csv") {
            tilemap.printDebugDescription()
            worldNode.addChild(tilemap)
            self.tilemap = tilemap
        }
    }
    
    // MARK: Input
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            if let coord = tilemap?.getLayer(name: "Tile Layer 1")?.coordForTouch(touch) {
                print(coord)
            }
        }
        
        if tilemap?.getObjectGroup(name: "Object Layer 1")?.getObjects(name: "ob2ject 1").count > 0 {
            print("YAY!")
        }
        
        if tilemap?.getObjectGroup(name: "Objct Layer 1")?.getObjects(type: "wew").count > 0 {
            print("YAY 2!")
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            sceneCamera.panCamera(touch)
        }
    }
}
