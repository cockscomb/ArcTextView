import UIKit

public class ArcTextView: UIView {

    override public class func layerClass() -> AnyClass {
        return ArcTextLayer.self
    }

    private var arcTextLayer: ArcTextLayer {
        return layer as! ArcTextLayer
    }

    public var attributedText: NSAttributedString? {
        get {
            return arcTextLayer.attributedText
        }
        set {
            arcTextLayer.attributedText = newValue
        }
    }

    public var alignment: ArcTextLayer.Alignment {
        get {
            return arcTextLayer.alignment
        }
        set {
            arcTextLayer.alignment = newValue
        }
    }

    public var radius: CGFloat {
        get {
            return arcTextLayer.radius
        }
        set {
            arcTextLayer.radius = newValue
        }
    }
    
    public var angle: CGFloat {
        get {
            return arcTextLayer.angle
        }
        set {
            arcTextLayer.angle = newValue
        }
    }
    
}
