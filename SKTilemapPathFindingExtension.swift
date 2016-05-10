/*
 SKTilemap
 SKTilemapParser.swift
 
 Created by Thomas Linthwaite on 07/04/2016.
 GitHub: https://github.com/TomLinthwaite/SKTilemap
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
import GameplayKit

// MARK: SKTilemap PathFinding Extension
extension SKTilemap {
    
// MARK: Initialization
    
    /** Initializes the path finding graph. Tiles on the layers named that have the collision property are treated as
        collidable (walls / non-walkable). Naming all of the collision layers isn't required. If no names are supplied
        all layer tiles are checked for the corresponding property. */
    func initializeGraph(collisionProperty collisionProperty: String, collisionLayerNames: [String]? = nil, diagonalsAllowed: Bool) -> Bool {
        
        let time = NSDate()
        
        var layers: [SKTilemapLayer] = []
        
        if collisionLayerNames == nil {
            
            layers = Array(getLayers())
            
        } else {
            
            for name in collisionLayerNames! {
                
                guard let layer = getLayer(name: name) else {
                    print("SKTilemap: Failed to initialize path finding graph. The collision layer (\(name)) could not be found.")
                    return false
                }
                
                layers.append(layer)
            }
        }
        
        pathFindingGraph = GKGridGraph(fromGridStartingAt: vector2(0, 0), width: Int32(width), height: Int32(height), diagonalsAllowed: diagonalsAllowed)
        removedGraphNodes = []
        
        var nodesToRemove: [GKGridGraphNode] = []
        
        for y in 0..<height {
            for x in 0..<width {
                
                for layer in layers {
                    
                    if layer.tileAtCoord(x, y)?.tileData.properties[collisionProperty] != nil {
                        nodesToRemove.append(pathFindingGraph!.nodeAtGridPosition(vector2(Int32(x), Int32(y)))!)
                        break
                    }
                }
            }
        }
        
        pathFindingGraph?.removeNodes(nodesToRemove)
        
        print("SKTilemap: Initialized path finding graph in \(NSDate().timeIntervalSinceDate(time)) seconds. \(nodesToRemove.count) collidable nodes were removed.")
        
        return true
    }
    
    /** Initializes the path finding graph. All tiles on the given layer are treated as collidable tiles (walls / non-walkable). */
    func initializeGraph(collisionLayerName collisionLayerName: String, diagonalsAllowed: Bool) -> Bool {
        
        let time = NSDate()
        
        guard let layer = getLayer(name: collisionLayerName) else {
            print("SKTilemap: Failed to initialize path finding graph. The collision layer (\(collisionLayerName)) could not be found.")
            return false
        }
        
        pathFindingGraph = GKGridGraph(fromGridStartingAt: vector2(0, 0), width: Int32(width), height: Int32(height), diagonalsAllowed: diagonalsAllowed)
        removedGraphNodes = []
        
        var nodesToRemove: [GKGridGraphNode] = []
        
        for y in 0..<height {
            for x in 0..<width {
                
                if layer.tileAtCoord(x, y) != nil {
                    nodesToRemove.append(pathFindingGraph!.nodeAtGridPosition(vector2(Int32(x), Int32(y)))!)
                }
            }
        }
        
        pathFindingGraph?.removeNodes(nodesToRemove)
        
        print("SKTilemap: Initialized path finding graph in \(NSDate().timeIntervalSinceDate(time)) seconds. \(nodesToRemove.count) collidable nodes were removed.")
        
        return true
    }
    
// MARK: Path Finding
    
    /** Find a path from a start grid position to an end grid position. Will return nil if no path can be found. 
        Optional parameter removes the starting position from the returned graph, which is usually desired. How ever it
        can be turned off.
        Returns an array of tilemap coordinates representing the path from start to finish. */
    func findPathFrom(x x: Int32, y: Int32, toX: Int32, toY: Int32, removeStartPosition: Bool = true) -> [CGPoint]? {
        
        if x == toX && y == toY {
            print("SKTilemap: Failed to find path. Start and End points are the same.")
            return nil
        }
        
        guard let graph = pathFindingGraph else {
            print("SKTilemap: Failed to find path. Graph not initialized.")
            return nil
        }
        
        guard let fromNode = graph.nodeAtGridPosition(vector2(x, y)) else {
            print("SKTilemap. Failed to find path. Invalid start position.")
            return nil
        }
        
        guard let toNode = graph.nodeAtGridPosition(vector2(toX, toY)) else {
            print("SKTilemap. Failed to find path. Invalid end position.")
            return nil
        }
        
        var path = graph.findPathFromNode(fromNode, toNode: toNode)
        
        if (removeStartPosition && path.count <= 1) || path.count == 0 {
            print("SKTilemap: Failed to find path.")
            return nil
        }
        
        if removeStartPosition { path.removeFirst() }
        
        return path.map({ CGPoint(x: Int(($0 as! GKGridGraphNode).gridPosition.x), y: Int(($0 as! GKGridGraphNode).gridPosition.y)) })
    }
    
    /** Find a path from a start grid position to an end grid position. Will return nil if no path can be found.
        Optional parameter removes the starting position from the returned graph, which is usually desired. How ever it
        can be turned off. */
    func findPathFrom(position: CGPoint, toPosition: CGPoint, removeStartPosition: Bool = true) -> [CGPoint]? {
        return findPathFrom(x: Int32(position.x),
                            y: Int32(position.y),
                            toX: Int32(toPosition.x),
                            toY: Int32(toPosition.y),
                            removeStartPosition: removeStartPosition)
    }
    
    /** Removes a node from the graph. This node can no longer be used when finding a path. */
    func removeGraphNodeAtPosition(x x: Int32, y: Int32) {
        
        if let node = pathFindingGraph?.nodeAtGridPosition(vector2(x, y)) {
            pathFindingGraph?.removeNodes([node])
            removedGraphNodes.append(node)
        }
    }
    
    func removeGraphNodeAtPosition(position: CGPoint) {
        removeGraphNodeAtPosition(x: Int32(position.x), y: Int32(position.y))
    }
    
    /** Re-adds all nodes that were removed from the graph. This resets the graph to the state it was in when it was 
        first initialized. */
    func resetGraph() {
        
        pathFindingGraph?.addNodes(removedGraphNodes)
        removedGraphNodes.forEach({ pathFindingGraph?.connectNodeToAdjacentNodes($0) })
        removedGraphNodes = []
    }
    
    /** Adds a previously removed node to the grid. Does nothing if the grid already has a node at this position.
        Nodes that are added to the grid become valid path positions. */
    func addGraphNodeAtPosition(x x: Int32, y: Int32) {
        
        guard let graph = pathFindingGraph else { return }
        
        if x < 0 || x >= Int32(graph.gridWidth) || y < 0 || y >= Int32(graph.gridHeight) { return }
        
        if graph.nodeAtGridPosition(vector2(x, y)) != nil { return }
        
        var nodeToAdd: GKGridGraphNode?
        
        for node in removedGraphNodes {
            if node.gridPosition.x == x && node.gridPosition.y == y {
                nodeToAdd = node
                break
            }
        }
        
        graph.addNodes([nodeToAdd!])
        graph.connectNodeToAdjacentNodes(nodeToAdd!)
    }
    
    func addGraphNodeAtPosition(position: CGPoint) {
        addGraphNodeAtPosition(x: Int32(position.x), y: Int32(position.y))
    }
}