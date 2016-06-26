/*
 SKTilemap
 SKTilemapParser.swift
 
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

// MARK: SKTilemapParser
class SKTilemapParser : NSObject, XMLParserDelegate {
    
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
    func loadTilemap(filename: String) -> SKTilemap? {
        
        guard
            let path = Bundle.main().pathForResource(filename, ofType: ".tmx"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                print("SKTilemapParser: Failed to load tilemap '\(filename)'.")
                return nil
        }
        
        self.filename = filename
        let parser = XMLParser(data: data)
        parser.delegate = self
        errorMessage = "SKTilemapParser: Couldn't load file \(filename)"
        
        if parser.parse() {
            return tilemap
        }
        
        print(errorMessage)
        return nil
    }
    
// MARK: NSXMLParser Delegate Functions
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
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
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?,
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
                characters = characters.replacingOccurrences(of: "\n", with: "")
                characters = characters.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                characters = characters.replacingOccurrences(of: " ", with: "")
                let stringData = characters.components(separatedBy: ",")
                
                for stringID in stringData {
                    
                    if let id = Int(stringID) {
                        data.append(id)
                    }
                }
                
                initializeLayer = true
            }
            
            if encoding == "base64" {
                
                let options = Data.Base64DecodingOptions.ignoreUnknownCharacters
                
                characters = characters.replacingOccurrences(of: "\n", with: "")
                characters = characters.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                characters = characters.replacingOccurrences(of: " ", with: "")
                if let base64Data = Data(base64Encoded: characters) {
                    
                    let count = base64Data.count / sizeof(Int32)
                    var arr = [Int32](repeating: 0, count: count)
                    (base64Data as NSData).getBytes(&arr, length: count * sizeof(Int32))
                    
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
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        characters += string
    }
}
