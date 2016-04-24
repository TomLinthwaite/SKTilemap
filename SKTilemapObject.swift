//
//  SKTilemapObject.swift
//  SKTilemap
//
//  Created by Thomas Linthwaite on 14/04/2016.
//  Copyright © 2016 Tom Linthwaite. All rights reserved.
//

import SpriteKit

// MARK: SKTilemapObject
class SKTilemapObject : Equatable, Hashable {
    
// MARK: Properties
    var hashValue: Int { get { return id.hashValue } }
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
    /** A unique ID for this object. */
    let id: Int
    
    /** The position of this object as taken from the .tmx file */
    let rawPosition: CGPoint
    
    /** The coordinate the position of this object is at on the map */
    var coord: CGPoint {
        get {
            switch objectGroup.tilemap.orientation {
            case .Orthogonal:
                return CGPoint(x: rawPosition.x / objectGroup.tilemap.tileSize.width,
                               y: rawPosition.y / objectGroup.tilemap.tileSize.height)
            case .Isometric:
                return CGPoint(x: rawPosition.x / (objectGroup.tilemap.tileSize.width / 2),
                               y: rawPosition.y / objectGroup.tilemap.tileSize.height)
            }
        }
    }
    
    /** The size of thie object. */
    let size: CGSize
    
    /** The name of this object. */
    let name: String
    
    /** The type of this object. */
    let type: String
    
    /** The object group this object belongs to. */
    let objectGroup: SKTilemapObjectGroup
    
// MARK: Initialization
    
    /** Initialize a object from tmx parser attributes. Should probably only be called by SKTilemapParser. */
    init?(objectGroup: SKTilemapObjectGroup, tmxParserAttributes attributes: [String : String]) {
        
        guard
            let id = attributes["id"] where (Int(id) != nil),
            let x = attributes["x"] where (Int(x) != nil),
            let y = attributes["y"] where (Int(y) != nil)
            else {
                
                print("SKTilemapObject: Failed to initialize with tmxAttributes.")
                return nil
        }
        
        self.id = Int(id)!
        self.rawPosition = CGPoint(x: Int(x)!, y: Int(y)!)
        
        if let width = attributes["width"] where (Int(width)) != nil,
            let height = attributes["height"] where (Int(height) != nil) {
            
            size = CGSize(width: Int(width)!, height: Int(height)!)
        } else {
            size = CGSizeZero
        }
        
        if let name = attributes["name"] { self.name = name } else { name = "" }
        if let type = attributes["type"] { self.type = type } else { type = "" }
        self.objectGroup = objectGroup
    }
    
// MARK: Debug
    func printDebugDescription() {
        print("\nSKTilemapObject: \(id), Name: \(name), Type: \(type), Raw Position: \(rawPosition), Size: \(size)")
        print("Properties: \(properties)")
    }
    
    func positionOnLayer(layer: SKTilemapLayer) -> CGPoint {
        return layer.tilePositionAtCoord(Int(coord.x), Int(coord.y), offset: objectGroup.offset)
    }
}

func ==(lhs: SKTilemapObject, rhs: SKTilemapObject) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
