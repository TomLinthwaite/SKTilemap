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
        
        /* Setup a basic Camera object to allow for panning/zooming. */
        sceneCamera = Camera(scene: self, view: view, worldNode: worldNode)
        addChild(sceneCamera)
        camera = sceneCamera
        
        /* Load Tilemap from .tmx file and add it to the scene through the worldNode. */
        if let tilemap = SKTilemap.loadTMX(name: "tilemap_orthogonal") {
            
            /* Print tilemap information to console, useful for debugging. */
            tilemap.printDebugDescription()
            worldNode.addChild(tilemap)
            self.tilemap = tilemap
        }
    }
    
    // MARK: Input
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            if let layer = tilemap?.getLayer(name: "ground layer") {
                if let coord = layer.coordAtTouchPosition(touch) {
                    print("Coord at Touch Position: \(coord)")
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            sceneCamera.panCamera(touch)
        }
    }
}
