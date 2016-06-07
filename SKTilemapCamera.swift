/*
 SKTilemap
 SKTilemapCamera.swift
 
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
#if os(iOS)
    import UIKit
#endif

protocol SKTilemapCameraDelegate : class {
    
    func didUpdatePosition(position position: CGPoint, scale: CGFloat, bounds: CGRect)
    func didUpdateZoomScale(position position: CGPoint, scale: CGFloat, bounds: CGRect)
    func didUpdateBounds(position position: CGPoint, scale: CGFloat, bounds: CGRect)
}

// MARK: Camera
class SKTilemapCamera : SKCameraNode {
    
// MARK: Properties
    
    /** The node the camera intereacts with. Anything you want to be effected by the camera should be a child of this node. */
    let worldNode: SKNode
    
    /** Bounds the camera constrains the worldNode to. Default value is the size of the view but this can be changed. */
    private var bounds: CGRect
    
    /** The current zoom scale of the camera. */
    private var zoomScale: CGFloat
    
    /** Min/Max scale the camera can zoom in/out. */
    var zoomRange: (min: CGFloat, max: CGFloat)
    
    /** Enable/Disable the ability to zoom the camera. */
    var allowZoom: Bool
    
    private var isEnabled: Bool
    
    /** Enable/Disable the camera. */
    var enabled: Bool {
        get { return isEnabled }
        set {
            isEnabled = newValue
            
#if os(iOS)
            longPressGestureRecognizer.enabled = newValue
            pinchGestureRecognizer.enabled = newValue
#endif
        }
    }
    
    /** Enable/Disable clamping of the worldNode */
    var enableClamping: Bool
    
    /** Delegates are informed when the camera repositions or performs some other action. */
    private var delegates: [SKTilemapCameraDelegate] = []
    
    /** Previous touch/mouse location the last time the position was updated. */
    private var previousLocation: CGPoint!
    
// MARK: Initialization
    
    /** Initialize a basic camera. */
    init(scene: SKScene, view: SKView, worldNode: SKNode) {
        
        self.worldNode = worldNode
        bounds = view.bounds
        zoomScale = 1.0
        zoomRange = (0.05, 4.0)
        allowZoom = true
        isEnabled = true
        enableClamping = true
        
        super.init()
        
#if os(iOS)
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.updateScale(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
    
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.updatePosition(_:)))
        longPressGestureRecognizer.numberOfTouchesRequired = 1
        longPressGestureRecognizer.numberOfTapsRequired = 0
        longPressGestureRecognizer.allowableMovement = 0
        longPressGestureRecognizer.minimumPressDuration = 0
        view.addGestureRecognizer(longPressGestureRecognizer)
#endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    /** Adds a delegate to camera. Will not allow duplicate delegates to be added. */
    func addDelegate(delegate: SKTilemapCameraDelegate) {
        
        if let _ = delegates.indexOf({ $0 === delegate }) { return }
        delegates.append(delegate)
    }
    
    /** Removes a delegate from the camera. */
    func removeDelegate(delegate: SKTilemapCameraDelegate) {
        if let index = delegates.indexOf( { $0 === delegate } ) {
            delegates.removeAtIndex(index)
        }
    }
    
// MARK: Input - iOS
    
#if os(iOS)
    /** Used for zooming/scaling the camera. */
    var pinchGestureRecognizer: UIPinchGestureRecognizer!
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    /** Used to determine the intial touch location when the user performs a pinch gesture. */
    private var initialTouchLocation = CGPointZero
    
    /** Will move the camera based on the direction of a touch from the longPressGestureRecognizer.
        Any delegates of the camera will be informed that the camera moved. */
    func updatePosition(recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state == .Began {
            previousLocation = recognizer.locationInView(recognizer.view)
        }
        
        if recognizer.state == .Changed {
            
            if previousLocation == nil { return }
            
            let location = recognizer.locationInView(recognizer.view)
            let difference = CGPoint(x: location.x - previousLocation.x, y: location.y - previousLocation.y)
            centerOnPosition(CGPoint(x: Int(position.x - difference.x), y: Int(position.y - -difference.y)))
            previousLocation = location
        }
    }
    
    /** Scales the worldNode using input from a pinch gesture recogniser.
        Any delegates of the camera will be informed that the camera changed scale. */
    func updateScale(recognizer: UIPinchGestureRecognizer) {
        
        guard let scene = self.scene else { return }
        
        if recognizer.state == .Began {
            initialTouchLocation = scene.convertPointFromView(recognizer.locationInView(recognizer.view))
        }
        
        if recognizer.state == .Changed && enabled && allowZoom {
            
            zoomScale *= recognizer.scale
            applyZoomScale(zoomScale)
            recognizer.scale = 1
            centerOnPosition(CGPoint(x: initialTouchLocation.x * zoomScale, y: initialTouchLocation.y * zoomScale))
        }
        
        if recognizer.state == .Ended { }
    }
#endif
    
// MARK: Input - OSX
    
#if os(OSX)
    
    /** Updates the camera position based on mouse movement.
        Any delegates of the camera will be informed that the camera moved. */
    func updatePosition(event: NSEvent) {
        
        if scene == nil || !enabled { return }
        
        if previousLocation == nil { previousLocation = event.locationInNode(self) }
        
        let location = event.locationInNode(self)
        let difference = CGPoint(x: location.x - previousLocation.x, y: location.y - previousLocation.y)
        centerOnPosition(CGPoint(x: Int(position.x - difference.x), y: Int(position.y - difference.y)))
        previousLocation = location
    }
    
    /** Call this on mouseUp so the camera can reset the previous position. Without this the update position function
        will assume the mouse was in the last place as before an cause undesired "jump" effect. */
    func finishedInput() {
        previousLocation = nil
    }
#endif
    
// MARK: Positioning
    
    /** Moves the camera so it centers on a certain position within the scene. Easing can be applied by setting a timing 
        interval. Otherwise the position is changed instantly. */
    func centerOnPosition(scenePosition: CGPoint, easingDuration: NSTimeInterval = 0) {
        
        if easingDuration == 0 {
            
            position = scenePosition
            clampWorldNode()
            for delegate in delegates { delegate.didUpdatePosition(position: position, scale: zoomScale, bounds: self.bounds) }
            
        } else {
            
            let moveAction = SKAction.moveTo(scenePosition, duration: easingDuration)
            moveAction.timingMode = .EaseOut
            
            let blockAction = SKAction.runBlock({
                self.clampWorldNode()
                for delegate in self.delegates { delegate.didUpdatePosition(position: self.position, scale: self.zoomScale, bounds: self.bounds) }
            })
            
            runAction(SKAction.group([moveAction, blockAction]))
        }
    }
    
    override func centerOnNode(node: SKNode?, easingDuration: NSTimeInterval = 0) {
        
        guard let theNode = node where theNode.parent != nil else { return }
        
        let position = scene!.convertPoint(theNode.position, fromNode: theNode.parent!)
        centerOnPosition(position, easingDuration: easingDuration)
    }
    
// MARK: Scaling and Zoom
    
    /** Applies a scale to the worldNode. Ensures that the scale stays within its range and that the worldNode is 
        clamped within its bounds. */
    func applyZoomScale(scale: CGFloat) {
        
        var zoomScale = scale
        
        if zoomScale < zoomRange.min {
            zoomScale = zoomRange.min
        } else if zoomScale > zoomRange.max {
            zoomScale = zoomRange.max
        }
        
        self.zoomScale = zoomScale
        worldNode.setScale(zoomScale)
        
        for delegate in delegates { delegate.didUpdateZoomScale(position: position, scale: zoomScale, bounds: self.bounds) }
    }
    
    /** Returns the minimum zoom scale possible for the size of the worldNode. Useful when you don't want the worldNode
        to be displayed smaller than the current bounds. */
    func minimumZoomScale() -> CGFloat {
        
        let frame = worldNode.calculateAccumulatedFrame()
        
        if bounds == CGRectZero || frame == CGRectZero { return 0 }
        
        let xScale = (bounds.width * zoomScale) / frame.width
        let yScale = (bounds.height * zoomScale) / frame.height
        return min(xScale, yScale)
    }
    
// MARK: Bounds
    
    /** Keeps the worldNode clamped between a specific bounds. If the worldNode is smaller than these bounds it will
     stop it from moving outside of those bounds. */
    private func clampWorldNode() {
        
        if !enableClamping { return }
        
        let frame = worldNode.calculateAccumulatedFrame()
        var minX = frame.minX + (bounds.size.width / 2)
        var maxX = frame.maxX - (bounds.size.width / 2)
        var minY = frame.minY + (bounds.size.height / 2)
        var maxY = frame.maxY - (bounds.size.height / 2)
        
        if frame.width < bounds.width {
            swap(&minX, &maxX)
        }
        
        if frame.height < bounds.height {
            swap(&minY, &maxY)
        }
        
        if position.x < minX {
            position.x = CGFloat(Int(minX))
        } else if position.x > maxX {
            position.x = CGFloat(Int(maxX))
        }
        
        if position.y < minY {
            position.y = CGFloat(Int(minY))
        } else if position.y > maxY {
            position.y = CGFloat(Int(maxY))
        }
    }
    
    /** Returns the current bounds the camera is using. */
    func getBounds() -> CGRect {
        return bounds
    }
    
    /** Updates the bounds for the worldNode to be constrained to. Will inform all delegates this change occured. */
    func updateBounds(bounds: CGRect) {
        
        self.bounds = bounds
        for delegate in delegates { delegate.didUpdateBounds(position: position, scale: zoomScale, bounds: self.bounds) }
    }
}
