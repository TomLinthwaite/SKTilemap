/*
 SKTilemap
 SKTilemapObject.swift
 
 Created by Thomas Linthwaite on 07/04/2016.
 GitHub: https://github.com/TomLinthwaite/SKTilemap
 Website (Guide): http://tomlinthwaite.com/
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
    
    /* Returns the position of this object on a certain tilemap layer. This position will share the same position as 
        the tile at this position. */
    func positionOnLayer(layer: SKTilemapLayer) -> CGPoint {
        return layer.tilePositionAtCoord(Int(coord.x), Int(coord.y), offset: objectGroup.offset)
    }
    
    /* Returns the position of this object on a certain tilemap layer. This position will share the same position as
     the tile at this position. Can return nil if a layer cannot be found with that name. */
    func positionOnLayerNamed(name: String) -> CGPoint? {
        if let layer = objectGroup.tilemap.getLayer(name: name) {
            return positionOnLayer(layer)
        }
        
        return nil
    }
}

func ==(lhs: SKTilemapObject, rhs: SKTilemapObject) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
