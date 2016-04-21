//
//  AppDelegate.swift
//  SKTilemap-OSX
//
//  Created by Thomas Linthwaite on 21/04/2016.
//  Copyright (c) 2016 Tom Linthwaite. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {

        skView.frameInterval = 1 / 60
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.showsFields = false
        skView.showsPhysics = false
        skView.showsQuadCount = false
        
        skView.shouldCullNonVisibleNodes = true
        skView.ignoresSiblingOrder = true
        
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
