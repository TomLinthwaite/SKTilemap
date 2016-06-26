/*
 SKTilemap
 SKTilemapTileset.swift
 
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

// MARK: SKTilemapTileset
class SKTilemapTileset : Equatable, Hashable {
    
    // MARK: Properties
    var hashValue: Int { get { return name.hashValue } }
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
    /** The first GID of data within the tileset. */
    let firstGID: Int
    
    /** Returns the highest ID value for this tileset. */
    var lastGID: Int {
        var id = firstGID
        for data in tileData {
            if data.id > id { id = data.id }
        }
        return id
    }
    
    /** The name of this tileset. This name should be unique per tileset added to the tilemap. */
    let name: String
    
    /** The filename of the source image used for this tileset. This will only be used if the tileset was created from
     a single image. */
    var source = ""
    
    /** The name of the .atlas file used when creating the tileset. */
    var textureAtlasName = ""
    var textureAtlas: SKTextureAtlas?
    
    /** Spacing in pixels between tiles within the source image. Only used when creating tiles from a single image
     (sprite sheet). */
    var spacing = 0
    
    /** Margin in pixels around the edges of the source image. Only used when creating tiles from a single image.
     (sprite sheet) */
    var margin = 0
    
    /** The size of each tile. */
    let tileSize: CGSize
    
    /** Offset from tile position when drawing tiles. */
    var tileOffset = CGPoint.zero
    
    /** A set containing all of the tile data for this tileset. */
    private var tileData: Set<SKTilemapTileData> = []
    
// MARK: Initialization
    
    /** Initialize an empty tileset. */
    init(name: String, firstGID: Int, tileSize: CGSize, tileOffset: CGPoint = CGPoint.zero) {
        
        self.name = name
        self.firstGID = firstGID
        self.tileSize = tileSize
        self.tileOffset = tileOffset
    }
    
    /** Initialize using TMX Parser attributes. Should probably only be called by SKTilemapParser. */
    init?(tmxParserAttributes attributes: [String : String]) {
        
        guard
            let firstGID = attributes["firstgid"] where (Int(firstGID) != nil),
            let name = attributes["name"],
            let tileWidth = attributes["tilewidth"] where (Int(tileWidth) != nil),
            let tileHeight = attributes["tileheight"] where (Int(tileHeight) != nil)
            else {
                print("SKTilemapTileset: Failed to initialize with tmxAttributes.")
                return nil
        }
        
        self.firstGID = Int(firstGID)!
        self.name = name
        self.tileSize = CGSize(width: Int(tileWidth)!, height: Int(tileHeight)!)
        
        /* Optional attributes */
        if let spacing = attributes["spacing"] where (Int(spacing) != nil) { self.spacing = Int(spacing)! } else { spacing = 0 }
        if let margin = attributes["margin"] where (Int(margin) != nil) { self.margin = Int(margin)! } else { margin = 0 }
    }
    
    convenience init(name: String, atlasName: String, firstGID: Int, tileSize: CGSize, tileOffset: CGPoint = CGPoint.zero) {
        
        self.init(name: name, firstGID: firstGID, tileSize: tileSize, tileOffset: tileOffset)
        
        addTileData(atlasName: atlasName)
    }
    
// MARK: Debug
    func printDebugDescription() {
        
        print("\nTileset: \(name), firstGID: \(firstGID), TileSize: \(tileSize), TileOffset: \(tileOffset), Source: \(source), Margin: \(margin), Spacing: \(spacing)")
        print("Properties: \(properties)")
        
        for tile in tileData { tile.printDebugDescription() }
    }
    
// MARK: Tile Data
    
    /** Add tile data to the tileset using a sprite sheet. */
    func addTileData(spriteSheet source: String) {
        
        self.source = source
        let texture = SKTexture(imageNamed: source)
        let width = Int(texture.size().width)
        let height = Int(texture.size().height)
        let tilesPerRow = (width - (margin * 2) + spacing) / (Int(tileSize.width) + spacing)
        let tilesPerCol = (height - (margin * 2) + spacing) / (Int(tileSize.height) + spacing)
        let totalTiles = tilesPerCol * tilesPerRow
        var x = margin
        var y = margin + (Int(tileSize.height) * tilesPerCol) + (spacing * (tilesPerCol - 1)) - Int(tileSize.height)
        
        for id in firstGID..<(firstGID + totalTiles) {
            
            let rX = CGFloat(x) / CGFloat(width)
            let rY = CGFloat(y) / CGFloat(height)
            let rW = tileSize.width / CGFloat(width)
            let rH = tileSize.height / CGFloat(height)
            let rect = CGRect(x: rX, y: rY, width: rW, height: rH)
            
            let texture = SKTexture(rect: rect, in: texture)
            addTileData(id: id, texture: texture)
            
            x += Int(tileSize.width) + spacing
            if x >= width {
                x = margin
                y -= Int(tileSize.height) + spacing
            }
        }
    }
    
    /** Adds TileData with images taken from a .atlas file found inside the bundle. Note that when using this method GIDs
        cannot be garunteed for each image and may change each time the game is loaded or atlas is changed. Instead use the image
        names themselves when retrieving tiles from this tileset using this function: 'getTileData(name: String) -> SKTilemapTileData?' */
    func addTileData(atlasName: String, atlas: SKTextureAtlas) {
        
        self.textureAtlasName = atlasName
        self.textureAtlas = atlas
        
        for imageName in textureAtlas!.textureNames {
            
            let texture = textureAtlas!.textureNamed(imageName)
            let id = self.tileData.count == 0 ? lastGID : lastGID + 1
            let tileData = SKTilemapTileData(id: id, texture: texture, source: imageName, tileset: self)
            self.tileData.insert(tileData)
            
            //print("\(id) - \(imageName) - \(atlasName)")
        }
    }
    
    /** Adds TileData with images taken from a .atlas file found inside the main bundle. The atlas is created when this
        function is called. If you would rather preload the atlas call 'addTileData(atlasName atlasName: String, atlas: SKTextureAtlas)' instead.*/
    func addTileData(atlasName: String) {
        
        addTileData(atlasName: atlasName, atlas: SKTextureAtlas(named: atlasName))
    }
    
    /** Add a single SKTilemapTileData object to this tileset with texture. Will return the tile data object that was added on
        success or nil on failure. */
    func addTileData(id: Int? = nil, texture: SKTexture) -> SKTilemapTileData? {
        
        var tileID: Int
        
        if id == nil {
            tileID = lastGID + 1
        } else {
            tileID = id!
        }
        
        if self.tileData.contains({ $0.hashValue == tileID.hashValue }) {
            print("SKTilemapTileset: Failed to add tile data. Tile data with the same id already exists.")
            return nil
        }
        
        let tileData = SKTilemapTileData(id: tileID, texture: texture, tileset: self)
        self.tileData.insert(tileData)
        return tileData
    }
    
    /** Add a single SKTilemapTileData object to this tileset. It's texture is loaded from a file provided from the filename.
        Will return the tile data object that was added on success or nil on failure. */
    func addTileData(id: Int? = nil, imageNamed source: String) -> SKTilemapTileData? {
        
        var tileID: Int
        
        if id == nil {
            tileID = lastGID + 1
        } else {
            tileID = id!
        }
        
        if self.tileData.contains({ $0.hashValue == tileID.hashValue }) {
            print("SKTilemapTileset: Failed to add tile data. Tile data with the same id already exists.")
            return nil
        }
        
        let tileData = SKTilemapTileData(id: tileID, imageNamed: source, tileset: self)
        self.tileData.insert(tileData)
        return tileData
    }
    
    /** Returns a SKTilemapTileData object contained within this tileset matching the ID. Returns nil on failure. */
    func getTileData(id: Int) -> SKTilemapTileData? {
        
        if let index = tileData.index( where: { $0.id == id } ) {
            return tileData[index]
        }
        
        return nil
    }
    
    /** Returns a TileData object with a certain name. The name will be the same as the image name used to create it.
        Note that only TileData objects created through an .atlas or added with an image name will can be retrieved.
        If you loaded this tileset from a sprite sheet or added tile data with only a texture this function will not find
        the tile. This is because there is no way of knowing what the source image is called.*/
    func getTileData(_ name: String) -> SKTilemapTileData? {

        if let index = tileData.index(where: { ($0.source as NSString).deletingPathExtension == (name as NSString).deletingPathExtension }) {
            return tileData[index]
        }
        
        return nil
    }
        
    
}

func ==(lhs: SKTilemapTileset, rhs: SKTilemapTileset) -> Bool {
    return (lhs.hashValue == rhs.hashValue)
}
