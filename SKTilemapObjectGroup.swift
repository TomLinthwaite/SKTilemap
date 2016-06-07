/*
 SKTilemap
 SKTilemapObjectGroup.swift
 
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

// MARK: SKObjectGroup
class SKTilemapObjectGroup : Equatable, Hashable {
    
// MARK: Properties
    var hashValue: Int { get { return name.hashValue } }
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
    /** The offset of this object group from the tilemaps position. */
    let offset: CGPoint
    
    /** The name of this object group. This should be unique per tilemap. */
    let name: String
    
    /** The objects within this object group. */
    private var objects: Set<SKTilemapObject> = []
    
    /** The tilemap this layer has been added to. */
    let tilemap: SKTilemap
    
// MARK: Initialization
    
    /** Initialize a object group from tmx parser attributes. Should probably only be called by SKTilemapParser. */
    init?(tilemap: SKTilemap, tmxParserAttributes attributes: [String : String]) {
        
        guard let name = attributes["name"] else {
            print("SKTilemapObjectGroup: Failed to initialize with tmxAttributes.")
            return nil
        }
        
        self.name = name
        self.tilemap = tilemap
        
        if let offsetX = attributes["offsetx"] where (Int(offsetX)) != nil,
            let offsetY = attributes["offsety"] where (Int(offsetY) != nil) {
            offset = CGPoint(x: Int(offsetX)!, y: Int(offsetY)!)
        } else {
            offset = CGPointZero
        }
    }
    
// MARK: Debug
    func printDebugDescription() {
        print("\nSKTilemapObjectGroup: \(name)")
        print("Properties: \(properties)")
        
        for object in objects { object.printDebugDescription() }
    }
    
// MARK: Objects
    
    /** Adds an object to the group. Will return the object on success or nil on failure. (It will fail if an object
        with the same ID has already been added to the group. */
    func addObject(object: SKTilemapObject) -> SKTilemapObject? {
        
        if objects.contains({ $0.hashValue == object.hashValue }) {
            print("SKTilemapObjectGroup: Failed to add object. An object with the same id already exists.")
            return nil
        }
            
        objects.insert(object)
        return object
    }
    
    /** Returns an object with a specific ID or nil on failure. */
    func getObject(id id: Int) -> SKTilemapObject? {
        
        if let index = objects.indexOf( { $0.id == id } ) {
            return objects[index]
        }
        
        return nil
    }
    
    /** Returns an array of all objects in the group. */
    func getObjects() -> [SKTilemapObject] {
        return Array(objects)
    }
    
    /** Returns an object at coord x and y, or nil on failure. */
    func getObjectAtCoord(x: Int, _ y: Int) -> SKTilemapObject? {
        
        if let index = objects.indexOf( { Int($0.coord.x) == x && Int($0.coord.y) == y } ) {
            return objects[index]
        }
        
        return nil
    }
    
    /** Returns an object at coord x and y, or nil on failure. */
    func getObjectAtCoord(coord: CGPoint) -> SKTilemapObject? {
        return getObjectAtCoord(Int(coord.x), Int(coord.y))
    }
    
    /** Returns an array of objects that have a matching name. */
    func getObjects(name name: String) -> [SKTilemapObject] {
        
        var objects = [SKTilemapObject]()
        
        for object in self.objects {
            if object.name == name {
                objects.append(object)
            }
        }
        
        return objects
    }
    
    /** Returns an array of objects that have a matching type. */
    func getObjects(type type: String) -> [SKTilemapObject] {
        
        var objects = [SKTilemapObject]()
        
        for object in self.objects {
            if object.type == type {
                objects.append(object)
            }
        }
        
        return objects
    }
}

func ==(lhs: SKTilemapObjectGroup, rhs: SKTilemapObjectGroup) -> Bool {
    return lhs.hashValue == rhs.hashValue
}