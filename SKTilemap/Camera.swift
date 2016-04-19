
import SpriteKit

class Camera : SKCameraNode {
    
// MARK: Properties
    let worldNode: SKNode
    var bounds: CGRect
    private var pinchGestureRecognizer: UIPinchGestureRecognizer!
    private var zoomScale: CGFloat
    var zoomRange: (min: CGFloat, max: CGFloat)
    
    var allowZoom: Bool
    var enabled: Bool

// MARK: Initialization
    init(scene: SKScene, view: SKView, worldNode: SKNode) {
        
        self.worldNode = worldNode
        bounds = view.bounds
        self.zoomScale = 1.0
        self.zoomRange = (0.1, 2.0)
        allowZoom = true
        enabled = true
        
        super.init()
        
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.scaleCamera(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: Input
    
    /// Should be called from within a touches moved method. Will move the camera based on the direction of a touch.
    func panCamera(touch: UITouch) {
        
        if scene != nil && enabled {
            
            let location = touch.locationInNode(scene!)
            let previousLocation = touch.previousLocationInNode(scene!)
            let difference = CGPoint(x: location.x - previousLocation.x, y: location.y - previousLocation.y)
            position = CGPoint(x: position.x - difference.x, y: position.y - difference.y)
            clampWorldNode()
        }
    }
    
    /// Scales the worldNode using input from a pinch gesture recogniser.
    func scaleCamera(recognizer: UIPinchGestureRecognizer) {
        
        if recognizer.state == .Changed && enabled && allowZoom {
            
            zoomScale *= recognizer.scale
            applyZoomScale(zoomScale)
            recognizer.scale = 1
        }
    }
    
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
    
    /// Applies a scale to the worldNode. Ensures that the scale stays within its range and that the worldNode is clamped within its bounds.
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
    
    /// Returns the minimum zoom scale possible for the size of the worldNode. Useful when you don't want the worldNode to be displayed smaller than the current bounds.
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
