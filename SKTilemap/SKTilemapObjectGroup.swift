//
//  SKTilemapObjectGroup.swift
//  SKTilemap
//
//  Created by Thomas Linthwaite on 07/04/2016.
//  Copyright © 2016 Tom Linthwaite. All rights reserved.
//

import SpriteKit

// MARK: SKObjectGroup
class SKTilemapObjectGroup : Equatable, Hashable {
    
// MARK: Properties
    var hashValue: Int { get { return name.hashValue } }
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
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

// MARK: SKTilemapObject
class SKTilemapObject : Equatable, Hashable {
    
// MARK: Properties
    var hashValue: Int { get { return id.hashValue } }
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
    /** A unique ID for this object. */
    let id: Int
    
    /** The position of this object as taken from the .tmx file */
    let position: CGPoint
    
    /** The coordinate the position of this object is at on the map */
    var coord: CGPoint {
        get {
            switch objectGroup.tilemap.orientation {
            case .Orthogonal:
                return CGPoint(x: position.x / objectGroup.tilemap.tileSize.width,
                               y: position.y / objectGroup.tilemap.tileSize.height)
            case .Isometric:
                return CGPoint(x: position.x / (objectGroup.tilemap.tileSize.width / 2),
                               y: position.y / objectGroup.tilemap.tileSize.height)
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
        self.position = CGPoint(x: Int(x)!, y: Int(y)!)
        
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
        print("\nSKTilemapObject: \(id), Name: \(name), Type: \(type), Position: \(position), Size: \(size)")
        print("Properties: \(properties)")
    }
}

func ==(lhs: SKTilemapObject, rhs: SKTilemapObject) -> Bool {
    return lhs.hashValue == rhs.hashValue
}