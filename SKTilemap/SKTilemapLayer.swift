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
    private var tiles: [[SKTile?]]
    
    /** The size of the layer in tiles. */
    private var size: CGSize { get { return tilemap.size } }
    private var sizeHalved: CGSize { get { return CGSize(width: size.width / 2, height: size.height / 2) } }
    
    /** The tilemap tile size. */
    private var tileSize: CGSize { get { return tilemap.tileSize } }
    private var tileSizeHalved: CGSize { get { return CGSize(width: tileSize.width / 2, height: tileSize.height / 2) } }
    
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
        tiles = Array(count: Int(tilemap.size.height), repeatedValue: Array(count: Int(tilemap.size.width), repeatedValue: nil))
        
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
            setTileAt(x: x, y: y, id: gid)
        }
        
        return true
    }
    
    /** Returns true if the x/y position passed into the function relates to a valid coordinate on the map. */
    func isValidCoord(x x: Int, y: Int) -> Bool {
        return x >= 0 && x < Int(size.width) && y >= 0 && y < Int(size.height)
    }
    
    /** Remove a particular tile at a map position. Will return the tile that was removed or nil if the tile did not exist or
     the location was invalid.  */
    func removeTile(x x: Int, y: Int) -> SKTile? {
        return setTileAt(x: x, y: y, tile: nil).tileRemoved
    }
    
    /** Removes all tiles from the layer. */
    func removeAllTiles() {
        
        for y in 0..<Int(size.height) {
            for x in 0..<Int(size.width) {
                removeTile(x: x, y: y)
            }
        }
    }
    
    /** Returns a tile at a given map position or nil if no tile exists or the position was outside of the map. */
    func tileAt(x x: Int, y: Int) -> SKTile? {
        
        if !isValidCoord(x: x, y: y) {
            return nil
        }
        
        return tiles[y][x]
    }
    
    /** Set a specific position on the map to represent the given tile. Nil can also be passed to
        remove a tile at this position (although removeTile(x:y:) is the prefered method for doing this).
        Will return a tuple containing the tile that was removed and the tile that was set. They can be nil
        if neither is true. */
    func setTileAt(x x: Int, y: Int, tile: SKTile?) -> (tileSet: SKTile?, tileRemoved: SKTile?) {
        
        if !isValidCoord(x: x, y: y) {
            return (nil, nil)
        }
        
        var tileRemoved: SKTile?
        
        if let tile = tileAt(x: x, y: y) {
            tile.removeFromParent()
            tileRemoved = tile
        }
        
        tiles[y][x] = tile
        
        if tile != nil {
            
            addChild(tile!)
            tile!.position = tileLayerPositionAt(x: x, y: y)
            tile!.sprite.anchorPoint = tilemap.orientation.tileAnchorPoint()
        }
        
        return (tile, tileRemoved)
    }
    
    /** Set a specific position on the map to represent the given tile by ID.
        Will return a tuple containing the tile that was removed and the tile that was set. They can be nil
        if neither is true. */
    func setTileAt(x x: Int, y: Int, id: Int) -> (tileSet: SKTile?, tileRemoved: SKTile?) {
        
        if let tileData = tilemap.getTileData(id: id) {
            setTileAt(x: x, y: y, tile: SKTile(tileData: tileData))
        }
        
        return (nil, nil)
    }
    
// MARK: Tile Coordinates & Positioning
    
    /** Returns the position a tile should be within the layer if they have a certain map position. */
    func tileLayerPositionAt(x x: Int, y: Int) -> CGPoint {
        
        let tileAnchorPoint = tilemap.orientation.tileAnchorPoint()
        var position =  CGPointZero
        
        switch tilemap.orientation {
            
        case .Orthogonal:
            position = CGPoint(x: x * Int(tileSize.width) + Int(tileAnchorPoint.x * tileSize.width),
                               y: y * Int(-tileSize.height) - Int(tileSize.height - tileAnchorPoint.y * tileSize.height))
            
        case .Isometric:
            position = CGPoint(x: (x - y) * Int(tileSizeHalved.width) - Int(tileSizeHalved.width - tileAnchorPoint.x * tileSize.width),
                               y: (x + y) * Int(-tileSizeHalved.height) - Int(tileSize.height - tileAnchorPoint.y * tileSize.height))
            
        }
        
        return position
    }
    
    /** Returns the coordinate from a specific position within the layer. If the position gets converted to a coordinate
        that is not valid nil is returned.  Otherwise the tile coordinate is returned. Passing the round parameter as 
        true will return a whole number coordinate (the default), or a decimal number which can be used to determine
        where exactly within the tile the layer position is. */
    func coordForLayerPosition(position: CGPoint, round: Bool = true) -> CGPoint? {
        
        var coord = CGPointZero
        
        switch tilemap.orientation {
            
        case .Orthogonal:
            coord = CGPoint(x: position.x / tileSize.width, y: position.y / -tileSize.height)
            
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
    
    /** Returns the coordinate of a tile using a touch position. If the position gets converted to a coordinate
     that is not valid nil is returned.  Otherwise the tile coordinate is returned. Passing the round parameter as
     true will return a whole number coordinate (the default), or a decimal number which can be used to determine
     where exactly within the tile the layer position is. */
    func coordForTouch(touch: UITouch, round: Bool = true) -> CGPoint? {
        
        let touchPosition = touch.locationInNode(self)
        return coordForLayerPosition(touchPosition, round: round)
    }
}
