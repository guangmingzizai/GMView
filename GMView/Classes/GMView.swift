//
//  BorderStyle.swift
//  GMView
//
//  Created by wangjianfei on 2018/2/12.
//

import Foundation

public enum PointerEvents {
    case unspecified, none, boxNone, boxOnly
}

open class GMView: UIView {
    public var pointerEvents: PointerEvents = .unspecified {
        didSet {
            isUserInteractionEnabled = (pointerEvents != .none)
        }
    }
    
    public var borderStyle: BorderStyle = .solid
    
    /**
     * Border radii.
     */
    public var borderRadius: CGFloat = -1
    public var borderTopLeftRadius: CGFloat = -1
    public var borderTopRightRadius: CGFloat = -1
    public var borderBottomLeftRadius: CGFloat = -1
    public var borderBottomRightRadius: CGFloat = -1
    
    /**
     * Border colors.
     */
    public var borderColor: UIColor?
    public var borderTopColor: UIColor?
    public var borderLeftColor: UIColor?
    public var borderBottomColor: UIColor?
    public var borderRightColor: UIColor?
    
    /**
     * Border widths.
     */
    public var borderWidth: CGFloat = -1
    public var borderTopWidth: CGFloat = -1
    public var borderLeftWidth: CGFloat = -1
    public var borderBottomWidth: CGFloat = -1
    public var borderRightWidth: CGFloat = -1
    
    /**
     *  Insets used when hit testing inside this view.
     */
    public var hitTestEdgeInsets: UIEdgeInsets = .zero
    
    public convenience init(hitTestEdgeInsets: UIEdgeInsets) {
        self.init()
        self.hitTestEdgeInsets = hitTestEdgeInsets
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let canReceiveTouchEvents = (isUserInteractionEnabled && !isHidden)
        if !canReceiveTouchEvents {
            return nil
        }
        
        // `hitSubview` is the topmost subview which was hit. The hit point can
        // be outside the bounds of `view` (e.g., if -clipsToBounds is NO).
        var hitSubview: UIView? = nil
        let isPointInside = self.point(inside: point, with: event)
        let needsHitSubview = !(pointerEvents == .none || pointerEvents == .boxOnly)
        if needsHitSubview && (!clipsToBounds || isPointInside) {
            // The default behaviour of UIKit is that if a view does not contain a point,
            // then no subviews will be returned from hit testing, even if they contain
            // the hit point. By doing hit testing directly on the subviews, we bypass
            // the strict containment policy (i.e., UIKit guarantees that every ancestor
            // of the hit view will return YES from -pointInside:withEvent:). See:
            //  - https://developer.apple.com/library/ios/qa/qa2013/qa1812.html
            for subview in subviews.reversed() {
                let convertedPoint = subview.convert(point, from: self)
                hitSubview = subview.hitTest(convertedPoint, with: event)
                if hitSubview != nil {
                    break
                }
            }
        }
        
        let hitView = (isPointInside ? self : nil)
        switch pointerEvents {
        case .none:
            return nil
        case .unspecified:
            return hitSubview ?? hitView
        case .boxOnly:
            return hitView
        case .boxNone:
            return hitSubview
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if UIEdgeInsetsEqualToEdgeInsets(hitTestEdgeInsets, .zero) {
            return super.point(inside: point, with: event)
        }
        let hitFrame = UIEdgeInsetsInsetRect(bounds, hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
    
    //    MARK: - Borders
    
    open override var backgroundColor: UIColor? {
        didSet {
            layer.setNeedsDisplay()
        }
    }
    
    private func bordersAsInsets() -> UIEdgeInsets {
        let borderWidth = max(0, self.borderWidth)
        return UIEdgeInsetsMake(
            borderTopWidth >= 0 ? borderTopWidth : borderWidth,
            borderLeftWidth >= 0 ? borderLeftWidth : borderWidth,
            borderBottomWidth >= 0 ? borderBottomWidth : borderWidth,
            borderRightWidth >= 0 ? borderRightWidth : borderWidth
        )
    }
    
    private func cornerRadii() -> CornerRadii {
        // Get corner radii
        let radius = max(0, borderRadius)
        let topLeftRadius = borderTopLeftRadius >= 0 ? borderTopLeftRadius : radius
        let topRightRadius = borderTopRightRadius >= 0 ? borderTopRightRadius : radius
        let bottomLeftRadius = borderBottomLeftRadius >= 0 ? borderBottomLeftRadius : radius
        let bottomRightRadius = borderBottomRightRadius >= 0 ? borderBottomRightRadius : radius
        
        // Get scale factors required to prevent radii from overlapping
        let size = bounds.size
        let topScaleFactor = zeroIfNaN(value: min(1, size.width / (topLeftRadius + topRightRadius)))
        let bottomScaleFactor = zeroIfNaN(value: min(1, size.width / (bottomLeftRadius + bottomRightRadius)))
        let rightScaleFactor = zeroIfNaN(value: min(1, size.height / (topRightRadius + bottomRightRadius)))
        let leftScaleFactor = zeroIfNaN(value: min(1, size.height / (topLeftRadius + bottomLeftRadius)))
        
        return CornerRadii(
            topLeft: topLeftRadius * min(topScaleFactor, leftScaleFactor),
            topRight: topRightRadius * min(topScaleFactor, rightScaleFactor),
            bottomLeft: bottomLeftRadius * min(bottomScaleFactor, leftScaleFactor),
            bottomRight: bottomRightRadius * min(bottomScaleFactor, rightScaleFactor)
        )
    }
    
    private func borderColors() -> BorderColors {
        let borderColor = self.borderColor ?? UIColor.clear
        return BorderColors(
            top: borderTopColor?.cgColor ?? borderColor.cgColor,
            left: borderLeftColor?.cgColor ?? borderColor.cgColor,
            bottom: borderBottomColor?.cgColor ?? borderColor.cgColor,
            right: borderRightColor?.cgColor ?? borderColor.cgColor
        )
    }
    
    private func updateShadowPathForView(_ view: GMView) {
        if layer.hasShadow {
            if let backgroundColor = backgroundColor, backgroundColor.cgColor.alpha > 0.999 {
                // If view has a solid background color, calculate shadow path from border
                let cornerRadii = view.cornerRadii()
                let cornerInsets = getCornerInsets(cornerRadii: cornerRadii, edgeInsets: .zero)
                view.layer.shadowPath = pathCreateWithRoundedRect(bounds: bounds, cornerInsets: cornerInsets, transform: nil)
            } else {
                // Can't accurately calculate box shadow, so fall back to pixel-based shadow
                view.layer.shadowPath = nil
            }
        }
    }
    
    private func updateClippingForLayer(_ layer: CALayer) {
        var mask: CALayer? = nil
        var cornerRadius: CGFloat = 0
        
        if clipsToBounds {
            let cornerRadii = self.cornerRadii()
            if (cornerRadiiAreEqual(cornerRadii)) {
                cornerRadius = cornerRadii.topLeft
            } else {
                let shapeLayer = CAShapeLayer()
                let path = pathCreateWithRoundedRect(bounds: bounds, cornerInsets: getCornerInsets(cornerRadii: cornerRadii, edgeInsets: .zero), transform: nil)
                shapeLayer.path = path
                mask = shapeLayer
            }
        }
        
        layer.cornerRadius = cornerRadius
        layer.mask = mask
    }
    
    open override func display(_ layer: CALayer) {
        if layer.bounds.size.equalTo(.zero) {
            return
        }
        
        updateShadowPathForView(self)
        
        let cornerRadii = self.cornerRadii()
        let borderInsets = bordersAsInsets()
        let borderColors = self.borderColors()
        
        // iOS draws borders in front of the content whereas CSS draws them behind
        // the content. For this reason, only use iOS border drawing when clipping
        // or when the border is hidden.
        let useIOSBorderRendering =
            cornerRadiiAreEqual(cornerRadii) &&
            borderInsetsAreEqual(borderInsets) &&
            borderColorsAreEqual(borderColors) &&
            borderStyle == .solid &&
            (borderInsets.top == 0 || (borderColors.top.alpha == 0) || clipsToBounds)
        
        // iOS clips to the outside of the border, but CSS clips to the inside. To
        // solve this, we'll need to add a container view inside the main view to
        // correctly clip the subviews.
        
        if useIOSBorderRendering {
            layer.cornerRadius = cornerRadii.topLeft
            layer.borderColor = borderColors.left
            layer.borderWidth = borderInsets.left
            layer.backgroundColor = backgroundColor?.cgColor
            layer.contents = nil
            layer.needsDisplayOnBoundsChange = false
            layer.mask = nil
            return
        }
        
        layer.backgroundColor = nil
        
        guard let image = getBorderImage(
            borderStyle: borderStyle,
            viewSize: layer.bounds.size,
            cornerRadii: cornerRadii,
            borderInsets: borderInsets,
            borderColors: borderColors,
            backgroundColor: backgroundColor?.cgColor ?? UIColor.clear.cgColor,
            drawToEdge: clipsToBounds
        ) else {
            layer.contents = nil
            layer.needsDisplayOnBoundsChange = false
            return
        }
        
        let imageSize = image.size
        let imageCapInsets = image.capInsets
        let contentsCenter = CGRect(
            x: imageCapInsets.left / imageSize.width,
            y: imageCapInsets.top / imageSize.height,
            width: 1.0 / imageSize.width,
            height: 1.0 / imageSize.height
        )
        
        layer.contents = image.cgImage
        layer.contentsScale = image.scale
        layer.needsDisplayOnBoundsChange = true
        layer.magnificationFilter = kCAFilterNearest
        
        let isResizable = !UIEdgeInsetsEqualToEdgeInsets(image.capInsets, .zero)
        if isResizable {
            layer.contentsCenter = contentsCenter
        } else {
            layer.contentsCenter = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        
        updateClippingForLayer(layer)
    }
    
}
