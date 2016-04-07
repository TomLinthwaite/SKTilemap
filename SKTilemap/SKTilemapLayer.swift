//
//  SKTileLayer.swift
//  SKTilemap
//
//  Created by Thomas Linthwaite on 07/04/2016.
//  Copyright © 2016 Tom Linthwaite. All rights reserved.
//

import SpriteKit

// MARK: SKTileLayer
class SKTilemapLayer : SKNode, TMXTilemapProtocol {
    
// MARK: Properties
    override var hashValue: Int { get { return name!.hashValue } }
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
    /** The offset to draw this layer at from the tilemap position. */
    let offset: CGPoint
    
    /** The tilemap this layer has been added to. */
    let tilemap: SKTilemap
    
// MARK: Initialization
    
    /** Initialize a tile layer from tmx parser attributes. Should probably only be called by SKTilemapParser. */
    init?(tilemap: SKTilemap, tmxParserAttributes attributes: [String : String]) {
        
        guard
            let name = attributes["name"]
            else {
                print("SKTilemapLayer: Failed to initialize with tmxAttributes.")
                return nil
        }
        
        if let offsetX = attributes["offsetx"] where (Int(offsetX)) != nil,
            let offsetY = attributes["offsety"] where (Int(offsetY) != nil) {
            offset = CGPoint(x: Int(offsetX)!, y: Int(offsetY)!)
        } else {
            offset = CGPointZero
        }
        
        self.tilemap = tilemap
        
        super.init()
        
        self.name = name
        
        if let opacity = attributes["opacity"] where (Double(opacity)) != nil {
            alpha = CGFloat(Double(opacity)!)
        }
        
        if let visible = attributes["visible"] where (Int(visible)) != nil {
            hidden = (Int(visible)! == 0 ? false : true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: Debug
    func printDebugDescription() {
        print("\nSKTileLayer: \(name), Offset: \(offset), Opacity: \(alpha), Visible: \(!hidden)")
        print("Properties: \(properties)")
    }
}
