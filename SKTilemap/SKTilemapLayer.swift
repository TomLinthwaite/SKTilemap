//
//  SKTileLayer.swift
//  SKTilemap
//
//  Created by Thomas Linthwaite on 07/04/2016.
//  Copyright © 2016 Tom Linthwaite. All rights reserved.
//

import SpriteKit

// MARK: SKTileLayer
class SKTilemapLayer : SKNode {
    
// MARK: Properties
    override var hashValue: Int { get { return name!.hashValue } }
    
    /** Properties shared by all TMX object types. */
    var properties: [String : String] = [:]
    
    /** The offset to draw this layer at from the tilemap position. */
    let offset: CGPoint
    
    /** The tilemap this layer has been added to. */
    let tilemap: SKTilemap
    
    /** A 2D array representing the tile layer data. */
    private var tiles: [[SKTilemapTile?]]
    
    /** The size of the layer in tiles. */
    private var size: CGSize { get { return tilemap.size } }
    private var sizeHalved: CGSize { get { return CGSize(width: size.width / 2, height: size.height / 2) } }
    
    /** The tilemap tile size. */
    private var tileSize: CGSize { get { return tilemap.tileSize } }
    private var tileSizeHalved: CGSize { get { return CGSize(width: tileSize.width / 2, height: tileSize.height / 2) } }
    
// MARK: Initialization
    
    /** Initialize an empty tilemap layer */
    init(tilemap: SKTilemap, name: String, offset: CGPoint = CGPointZero) {
        
        self.tilemap = tilemap
        self.offset = offset
        
        tiles = Array(count: Int(tilemap.size.height), repeatedValue: Array(count: Int(tilemap.size.width), repeatedValue: nil))
        
        super.init()
        
        self.name = name
    }
    
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
        tiles = Array(count: Int(tilemap.size.height), repeatedValue: Array(count: Int(tilemap.size.width), repeatedValue: nil))
        
        super.init()
        
        self.name = name
        
        if let opacity = attributes["opacity"] where (Double(opacity)) != nil {
            alpha = CGFloat(Double(opacity)!)
        }
        
        if let visible = attributes["visible"] where (Int(visible)) != nil {
            hidden = (Int(visible)! == 0 ? true : false)
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
    
// MARK: Tiles
    
    func initializeTilesWithData(data: [Int]) -> Bool {
        
        if data.count != Int(size.width) * Int(size.height) {
            print("SKTilemapLayer: Failed to initialize tile data. Data size is invalid.")
            return false
        }
        
        removeAllTiles()
        
        for i in 0..<data.count {
            let gid = data[i]
            let x = i % Int(size.width)
            let y = i / Int(size.width)
            setTileAtCoord(x, y, id: gid)
        }
        
        return true
    }
    
    /** Returns true if the x/y position passed into the function relates to a valid coordinate on the map. */
    func isValidCoord(x x: Int, y: Int) -> Bool {
        return x >= 0 && x < Int(size.width) && y >= 0 && y < Int(size.height)
    }
    
    /** Remove a particular tile at a map position. Will return the tile that was removed or nil if the tile did not exist or
     the location was invalid.  */
    func removeTileAtCoord(x: Int, _ y: Int) -> SKTilemapTile? {
        return setTileAtCoord(x, y, tile: nil).tileRemoved
    }
    
    func removeTileAtCoord(coord: CGPoint) -> SKTilemapTile? {
        return setTileAtCoord(Int(coord.x), Int(coord.y), tile: nil).tileRemoved
    }
    
    /** Removes all tiles from the layer. */
    func removeAllTiles() {
        
        for y in 0..<Int(size.height) {
            for x in 0..<Int(size.width) {
                removeTileAtCoord(x, y)
            }
        }
    }
    
    /** Returns a tile at a given map position or nil if no tile exists or the position was outside of the map. */
    func tileAtCoord(x: Int, _ y: Int) -> SKTilemapTile? {
        
        if !isValidCoord(x: x, y: y) {
            return nil
        }
        
        return tiles[y][x]
    }
    
    func tileAtCoord(coord: CGPoint) -> SKTilemapTile? {
        return tileAtCoord(Int(coord.x), Int(coord.y))
    }
    
    /** Returns the tile at a certain position within the layer. */
    func tileAtPosition(positionInLayer: CGPoint) -> SKTilemapTile? {
        if let coord = coordAtPosition(positionInLayer, round: true) {
            return tileAtCoord(Int(coord.x), Int(coord.y))
        }
        return nil
    }
    
    /** Set a specific position on the map to represent the given tile. Nil can also be passed to
        remove a tile at this position (although removeTile(x:y:) is the prefered method for doing this).
        Will return a tuple containing the tile that was removed and the tile that was set. They can be nil
        if neither is true. */
    func setTileAtCoord(x: Int, _ y: Int, tile: SKTilemapTile?) -> (tileSet: SKTilemapTile?, tileRemoved: SKTilemapTile?) {
        
        if !isValidCoord(x: x, y: y) {
            return (nil, nil)
        }
        
        var tileRemoved: SKTilemapTile?
        
        if let tile = tileAtCoord(x, y) {
            tile.removeFromParent()
            tileRemoved = tile
        }
        
        tiles[y][x] = tile
        
        if let t = tile {
            
            addChild(t)
            t.position = tilePositionAtCoord(x, y, offset: t.tileData.tileset.tileOffset)
            t.sprite.anchorPoint = tilemap.orientation.tileAnchorPoint()
        }
        
        return (tile, tileRemoved)
    }
    
    func setTileAtCoord(coord: CGPoint, tile: SKTilemapTile?) -> (tileSet: SKTilemapTile?, tileRemoved: SKTilemapTile?) {
        return setTileAtCoord(Int(coord.x), Int(coord.y), tile: tile)
    }
    
    /** Set a specific position on the map to represent the given tile by ID.
        Will return a tuple containing the tile that was removed and the tile that was set. They can be nil
        if neither is true. */
    func setTileAtCoord(x: Int, _ y: Int, id: Int) -> (tileSet: SKTilemapTile?, tileRemoved: SKTilemapTile?) {
        
        if let tileData = tilemap.getTileData(id: id) {
            setTileAtCoord(x, y, tile: SKTilemapTile(tileData: tileData))
        }
        
        return (nil, nil)
    }
    
    func setTileAtCoord(coord: CGPoint, id: Int) -> (tileSet: SKTilemapTile?, tileRemoved: SKTilemapTile?) {
        return setTileAtCoord(Int(coord.x), Int(coord.y), id: id)
    }
    
// MARK: Tile Coordinates & Positioning
    
    /** Returns the position a tile should be within the layer if they have a certain map position. */
    func tilePositionAtCoord(x: Int, _ y: Int, offset: CGPoint = CGPointZero) -> CGPoint {
        
        let tileAnchorPoint = tilemap.orientation.tileAnchorPoint()
        var position = CGPointZero
        
        switch tilemap.orientation {
            
        case .Orthogonal:
            position = CGPoint(x: x * Int(tileSize.width) + Int(tileAnchorPoint.x * tileSize.width),
                               y: y * Int(-tileSize.height) - Int(tileSize.height - tileAnchorPoint.y * tileSize.height))
            
        case .Isometric:
            position = CGPoint(x: (x - y) * Int(tileSizeHalved.width) - Int(tileSizeHalved.width - tileAnchorPoint.x * tileSize.width),
                               y: (x + y) * Int(-tileSizeHalved.height) - Int(tileSize.height - tileAnchorPoint.y * tileSize.height))
            
        }
        
        /* Re-position tile based on the tileset offset. */
        position.x = position.x + (offset.x - tileAnchorPoint.x * offset.x)
        position.y = position.y - (offset.y - tileAnchorPoint.y * offset.y)
        
        
        return position
    }
    
    /** Returns the coordinate from a specific position within the layer. 
        If the position gets converted to a coordinate that is not valid nil is returned.  Otherwise the tile coordinate
        is returned.
        A custom offset point can be passed to this function which is useful if the tileset being used has an offset.
        Passing the round parameter as true will return a whole number coordinate (the default), or a decimal number
        which can be used to determine where exactly within the tile the layer position is. */
    func coordAtPosition(positionInLayer: CGPoint, offset: CGPoint = CGPointZero, round: Bool = true) -> CGPoint? {
        
        var coord = CGPointZero
        
        let tileAnchorPoint = tilemap.orientation.tileAnchorPoint()
        let position = CGPoint(x: positionInLayer.x - (self.offset.x * tileAnchorPoint.x) + (offset.x - tileAnchorPoint.x * offset.x),
                               y: positionInLayer.y + (self.offset.y * tileAnchorPoint.y) - (offset.y - tileAnchorPoint.y * offset.y))

        
        switch tilemap.orientation {
            
        case .Orthogonal:
            coord = CGPoint(x: position.x / tileSize.width,
                            y: position.y / -tileSize.height)
            
        case .Isometric:
            coord = CGPoint(x: ((position.x / tileSizeHalved.width) + (position.y / -tileSizeHalved.height)) / 2,
                            y: ((position.y / -tileSizeHalved.height) - (position.x / tileSizeHalved.width)) / 2)
        }
        
        if !isValidCoord(x: Int(floor(coord.x)), y: Int(floor(coord.y))) {
            return nil
        }
        
        if round {
            return CGPoint(x: Int(floor(coord.x)), y: Int(floor(coord.y)))
        }
        
        return coord
    }
    
    /** Returns the coordinate of a tile using a touch position. 
        If the position gets converted to a coordinate that is not valid nil is returned.  Otherwise the tile 
        coordinate is returned. 
        A custom offset point can be passed to this function which is useful if the tileset being used has an offset.
        Passing the round parameter as true will return a whole number coordinate (the default), or a decimal number 
        which can be used to determine where exactly within the tile the layer position is. */
    func coordAtTouchPosition(touch: UITouch, offset: CGPoint = CGPointZero, round: Bool = true) -> CGPoint? {
        return coordAtPosition(touch.locationInNode(self), offset: offset, round: round)
    }
}
