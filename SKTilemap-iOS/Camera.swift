
import SpriteKit

// MARK: Camera
class Camera : SKCameraNode {
    
// MARK: Properties
    
    /** The node the camera intereacts with. Anything you want to be effected by the camera should be a child of this node. */
    let worldNode: SKNode
    
    /** Bounds the camera constrains the worldNode to. Default value is the size of the view but this can be changed. */
    var bounds: CGRect
    
    /** The current zoom scale of the camera. */
    private var zoomScale: CGFloat
    
    /** Min/Max scale the camera can zoom in/out. */
    var zoomRange: (min: CGFloat, max: CGFloat)
    
    /** Enable/Disable the ability to zoom the camera. */
    var allowZoom: Bool
    
    /** Enable/Disable the camera. */
    var enabled: Bool
    
// MARK: Initialization
    
    /** Initialize a basic camera. */
    init(scene: SKScene, view: SKView, worldNode: SKNode) {
        
        self.worldNode = worldNode
        bounds = view.bounds
        self.zoomScale = 1.0
        self.zoomRange = (0.1, 2.0)
        allowZoom = true
        enabled = true
        
        super.init()
        
        #if os(iOS)
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.updateScale(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        #endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: Input - iOS
    #if os(iOS)
    
    /** Used for zooming/scaling the camera. */
    private var pinchGestureRecognizer: UIPinchGestureRecognizer!
    
    /** Should be called from within a touches moved method. Will move the camera based on the direction of a touch.
     Any delegates of the camera will be informed that the camera moved. */
    func updatePosition(touch: UITouch) {
        
        if scene == nil || !enabled { return }
    
        let location = touch.locationInNode(scene!)
        let previousLocation = touch.previousLocationInNode(scene!)
        let difference = CGPoint(x: location.x - previousLocation.x, y: location.y - previousLocation.y)
        position = CGPoint(x: position.x - difference.x, y: position.y - difference.y)
        clampWorldNode()
    
    }
    
    /** Scales the worldNode using input from a pinch gesture recogniser.
        Any delegates of the camera will be informed that the camera changed scale. */
    func updateScale(recognizer: UIPinchGestureRecognizer) {
        
        if recognizer.state == .Changed && enabled && allowZoom {
            
            zoomScale *= recognizer.scale
            applyZoomScale(zoomScale)
            recognizer.scale = 1
        }
    }
    #endif
    
// MARK: Input - OSX
    #if os(OSX)
    /** Previous mouse location the last time the mouse was used to update position. */
    private var previousLocation: CGPoint!
    
    /** Updates the camera position based on mouse movement.
        Any delegates of the camera will be informed that the camera moved. */
    func updatePosition(event: NSEvent) {
        
        if scene == nil || !enabled { return }
        
        if previousLocation == nil { previousLocation = event.locationInNode(self) }
        
        let location = event.locationInNode(self)
        let difference = CGPoint(x: location.x - previousLocation.x, y: location.y - previousLocation.y)
        position = CGPoint(x: position.x - difference.x, y: position.y - difference.y)
        clampWorldNode()
        previousLocation = location
        
        print(position)
    }
    
    func updateScale(event: NSEvent) {
        
        print(event.scrollingDeltaY)
//        if event.state == .Changed && enabled && allowZoom {
//            
//            zoomScale *= recognizer.scale
//            applyZoomScale(zoomScale)
//            recognizer.scale = 1
//        }
    }
    
    /** Call this on mouseUp so the camera can reset the previous position. Without this the update position function
        will assume the mouse was in the last place as before an cause undesired "jump" effect. */
    func finishedInput() {
        previousLocation = nil
    }
    #endif
    
// MARK: Logic
    
    /** Keeps the worldNode clamped between a specific bounds. If the worldNode is smaller than these bounds it will
        stop it from moving outside of those bounds. */
    private func clampWorldNode() {
        
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
            position.x = minX
        } else if position.x > maxX {
            position.x = maxX
        }
        
        if position.y < minY {
            position.y = minY
        } else if position.y > maxY {
            position.y = maxY
        }
    }
    
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
        clampWorldNode()
    }
    
    /** Returns the minimum zoom scale possible for the size of the worldNode. Useful when you don't want the worldNode
        to be displayed smaller than the current bounds. */
    func minimumZoomScale() -> CGFloat {
        
        let frame = worldNode.calculateAccumulatedFrame()
        
        if bounds == CGRectZero || frame == CGRectZero { return 0 }
        
        let xScale = bounds.width / frame.width
        let yScale = bounds.height / frame.height
        return max(xScale, yScale)
    }
    
    func getZoomScale() -> CGFloat {
        return zoomScale
    }
}
