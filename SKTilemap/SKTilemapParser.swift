//
//  TMXTilemapParser.swift
//  SKTilemap
//
//  Created by Thomas Linthwaite on 07/04/2016.
//  Copyright © 2016 Tom Linthwaite. All rights reserved.
//

import SpriteKit

// MARK: SKTilemapParser
class SKTilemapParser : NSObject, NSXMLParserDelegate {
    
// MARK: Properties
    private var errorMessage = ""
    private var characters = ""
    private var encoding = ""
    private var data: [Int] = []
    private var lastElement: AnyObject?
    private var lastID: Int?
    internal var properties: [String : String] = [:]
    
    private var filename = ""
    private var tilemap: SKTilemap?
    
// MARK: Functions
    
    /** Load an SKTilemap from a .tmx tilemap file. */
    func loadTilemap(filename filename: String) -> SKTilemap? {
        guard
            let path = NSBundle.mainBundle().pathForResource(filename, ofType: ".tmx"),
            let data = NSData(contentsOfFile: path) else {
                return nil
        }
        
        self.filename = filename
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        errorMessage = "SKTilemapParser: Couldn't load file \(filename)"
        
        if parser.parse() {
            return tilemap
        }
        
        print(errorMessage)
        return nil
    }
    
// MARK: NSXMLParser Delegate Functions
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "map" {
            
            guard let tilemap = SKTilemap(filename: filename, tmxParserAttributes: attributeDict) else {
                parser.abortParsing()
                return
            }
            
            self.tilemap = tilemap
            lastElement = tilemap
        }
        
        if elementName == "tileset" {
            
            guard let tileset = SKTilemapTileset(tmxParserAttributes: attributeDict) else {
                parser.abortParsing()
                return
            }
            
            tilemap!.add(tileset: tileset)
            lastElement = tileset
        }
        
        if elementName == "tileoffset" {
            
            guard
                let x = attributeDict["x"] where (Int(x) != nil),
                let y = attributeDict["y"] where (Int(y) != nil),
                let tileset = lastElement as? SKTilemapTileset
                else {
                    errorMessage = "SKTilemapParser: Failed to parse <tileoffset>. [\(parser.lineNumber)]"
                    parser.abortParsing()
                    return
            }
            
            tileset.tileOffset = CGPoint(x: Int(x)!, y: Int(y)!)
        }
        
        if elementName == "image" {
            
            guard
                let source = attributeDict["source"],
                let tileset = lastElement as? SKTilemapTileset
                else {
                    errorMessage = "SKTilemapParser: Failed to parse <image>. [\(parser.lineNumber)]"
                    parser.abortParsing()
                    return
            }
            
            if lastID == nil {
                /* Dealing with an image tag for a tileset. (sprite sheet) */
                tileset.addTileData(spriteSheet: source)
            } else {
                /* Dealing with an image tag for a tile. */
                tileset.addTileData(id: tileset.firstGID + lastID!, imageNamed: (source as NSString).lastPathComponent)
            }
        }
        
        if elementName == "tile" {
            
            if let gid = attributeDict["gid"] where (Int(gid) != nil) && encoding == "xml" {
                data.append(Int(gid)!)
            }
            else if let id = attributeDict["id"] where (Int(id) != nil) {
                lastID = Int(id)!
            } else {
                errorMessage = "SKTilemapParser: Failed to parse <tile>. [\(parser.lineNumber)]"
                parser.abortParsing()
                return
            }
        }
        
        if elementName == "frame" {
            
            guard
                let id = attributeDict["tileid"] where (Int(id) != nil),
                let duration = attributeDict["duration"] where (Int(duration) != nil),
                let tileset = (lastElement as? SKTilemapTileset) where (lastID != nil),
                let tileData = tileset.getTileData(id: lastID! + tileset.firstGID)
                else {
                    errorMessage = "SKTilemapParser: Failed to parse <frame>. [\(parser.lineNumber)]"
                    parser.abortParsing()
                    return
            }
            
            tileData.animationFrames.append((id: Int(id)! + tileset.firstGID, duration: CGFloat(Int(duration)!)))
        }
        
        if elementName == "property" {
            
            guard
                let name = attributeDict["name"],
                let value = attributeDict["value"]
                else {
                    errorMessage = "SKTilemapParser: Failed to parse <property>. [\(parser.lineNumber)]"
                    parser.abortParsing()
                    return
            }
            
            properties[name] = value
        }
        
        if elementName == "layer" {
            
            guard let layer = SKTilemapLayer(tilemap: tilemap!, tmxParserAttributes: attributeDict) else {
                parser.abortParsing()
                return
            }
            
            tilemap!.add(tileLayer: layer)
            lastElement = layer
        }
        
        if elementName == "objectgroup" {
            
            guard let objectGroup = SKTilemapObjectGroup(tilemap: tilemap!, tmxParserAttributes: attributeDict) else {
                parser.abortParsing()
                return
            }
            
            tilemap!.add(objectGroup: objectGroup)
            lastElement = objectGroup
        }
        
        if elementName == "object" {
            
            guard
                let objectGroup = lastElement as? SKTilemapObjectGroup,
                let object = SKTilemapObject(objectGroup: objectGroup, tmxParserAttributes: attributeDict)
                else {
                parser.abortParsing()
                return
            }
            
            objectGroup.addObject(object)
            lastID = object.id
        }
        
        if elementName == "data" {
            
            if let _ = attributeDict["compression"] {
                errorMessage = "SKTilemapParser: Does not support data compression."
                parser.abortParsing()
                return
            }
            
            if let encoding = attributeDict["encoding"] {
                self.encoding = encoding
            } else {
                self.encoding = "xml"
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?) {
        
        if elementName == "tile" {
            
            if let tileset = lastElement as? SKTilemapTileset where (lastID != nil) {
                tileset.getTileData(id: tileset.firstGID + lastID!)?.properties = properties
                properties = [:]
            }
            
            lastID = nil
        }
        
        if elementName == "object" {
            
            if let objectGroup = lastElement as? SKTilemapObjectGroup where (lastID != nil) {
                objectGroup.getObject(id: lastID!)?.properties = properties
                properties = [:]
            }
            
            lastID = nil
        }
        
        if elementName == "properties" {
            
            if let tilemap = lastElement as? SKTilemap { tilemap.properties = properties }
            if let tileset = lastElement as? SKTilemapTileset where (lastID == nil) { tileset.properties = properties }
            if let layer = lastElement as? SKTilemapLayer { layer.properties = properties }
            if let objectGroup = lastElement as? SKTilemapObjectGroup where (lastID == nil) { objectGroup.properties = properties }
            
            if lastID == nil {
                properties = [:]
            }
        }
        
        if elementName == "data" {
            
            guard let layer = lastElement as? SKTilemapLayer else {
                parser.abortParsing()
                return
            }
            
            var initializeLayer = false
            
            if encoding == "xml" {
                initializeLayer = true
            }
            
            if encoding == "csv" {
                characters = characters.stringByReplacingOccurrencesOfString("\n", withString: "")
                characters = characters.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                characters = characters.stringByReplacingOccurrencesOfString(" ", withString: "")
                let stringData = characters.componentsSeparatedByString(",")
                
                for stringID in stringData {
                    
                    if let id = Int(stringID) {
                        data.append(id)
                    }
                }
                
                initializeLayer = true
            }
            
            if encoding == "base64" {
                
                if let base64Data = NSData(base64EncodedString: characters, options: .IgnoreUnknownCharacters) {
                    
                    let count = base64Data.length / sizeof(Int32)
                    var arr = [Int32](count: count, repeatedValue: 0)
                    base64Data.getBytes(&arr, length: count * sizeof(Int32))
                    
                    for id in arr {
                        data.append(Int(id))
                    }
                    
                    initializeLayer = true
                }
            }
            
            if initializeLayer {
                layer.initializeTilesWithData(data)
            } else {
                errorMessage = "SKTilemapParser: Failed to initialize data <data>. [\(parser.lineNumber)]"
                parser.abortParsing()
                return
            }
            
            data = []
        }
        
        characters = ""
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        characters += string
    }
}
