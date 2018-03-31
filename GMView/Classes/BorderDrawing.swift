//
//  BorderDrawing.swift
//  GMView
//
//  Created by wangjianfei on 2018/3/13.
//

import Foundation

public enum BorderStyle {
    case solid, dotted, dashed
}

public struct CornerRadii {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat
}

public struct BorderColors {
    var top: CGColor
    var left: CGColor
    var bottom: CGColor
    var right: CGColor
}

public struct CornerInsets {
    var topLeft: CGSize
    var topRight: CGSize
    var bottomLeft: CGSize
    var bottomRight: CGSize
}

let borderThreshold: CGFloat = 0.001

func borderInsetsAreEqual(_ borderInsets: UIEdgeInsets) -> Bool {
    return
        fabs(borderInsets.left - borderInsets.right) < borderThreshold &&
        fabs(borderInsets.left - borderInsets.bottom) < borderThreshold &&
        fabs(borderInsets.left - borderInsets.top) < borderThreshold
}

func cornerRadiiAreEqual(_ cornerRadii: CornerRadii) -> Bool {
    return
        fabs(cornerRadii.topLeft - cornerRadii.topRight) < borderThreshold &&
        fabs(cornerRadii.topLeft - cornerRadii.bottomLeft) < borderThreshold &&
        fabs(cornerRadii.topLeft - cornerRadii.bottomRight) < borderThreshold
}

func borderColorsAreEqual(_ borderColors: BorderColors) -> Bool {
    return
        borderColors.left == borderColors.right &&
        borderColors.left == borderColors.top &&
        borderColors.left == borderColors.bottom
}

func getCornerInsets(cornerRadii: CornerRadii, edgeInsets: UIEdgeInsets) -> CornerInsets {
    return CornerInsets(
        topLeft: CGSize(width: max(0, cornerRadii.topLeft - edgeInsets.left), height: max(0, cornerRadii.topLeft - edgeInsets.top)),
        topRight: CGSize(width: max(0, cornerRadii.topRight - edgeInsets.right), height: max(0, cornerRadii.topRight - edgeInsets.top)),
        bottomLeft: CGSize(width: max(0, cornerRadii.bottomLeft - edgeInsets.left), height: max(0, cornerRadii.bottomLeft - edgeInsets.bottom)),
        bottomRight: CGSize(width: max(0, cornerRadii.bottomRight - edgeInsets.right), height: max(0, cornerRadii.bottomRight - edgeInsets.bottom))
    )
}

func pathAddEllipticArc(path: CGMutablePath, m: CGAffineTransform?, origin: CGPoint, size: CGSize, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
    var xScale: CGFloat = 1, yScale: CGFloat = 1, radius: CGFloat = 0
    if size.width != 0 {
        xScale = 1
        yScale = size.height / size.width
        radius = size.width
    } else if size.height != 0 {
        xScale = size.width / size.height
        yScale = 1
        radius = size.height
    }
    var t = CGAffineTransform(translationX: origin.x, y: origin.y)
    t = t.scaledBy(x: xScale, y: yScale)
    if let m = m {
        t = t.concatenating(m)
    }
    path.addArc(center: CGPoint(x: 0, y: 0), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise, transform: t)
}

func pathCreateWithRoundedRect(bounds: CGRect, cornerInsets: CornerInsets, transform: CGAffineTransform?) -> CGPath {
    let minX = bounds.minX, minY = bounds.minY, maxX = bounds.maxX, maxY = bounds.maxY
    let topLeft = CGSize(
        width: max(0, min(cornerInsets.topLeft.width, bounds.size.width - cornerInsets.topRight.width)),
        height: max(0, min(cornerInsets.topLeft.height, bounds.size.height - cornerInsets.bottomLeft.height))
    )
    let topRight = CGSize(
        width: max(0, min(cornerInsets.topRight.width, bounds.size.width - cornerInsets.topLeft.width)),
        height: max(0, min(cornerInsets.topRight.height, bounds.size.height - cornerInsets.bottomRight.height))
    )
    let bottomLeft = CGSize(
        width: max(0, min(cornerInsets.bottomLeft.width, bounds.size.width - cornerInsets.bottomRight.width)),
        height: max(0, min(cornerInsets.bottomLeft.height, bounds.size.height - cornerInsets.topLeft.height))
    )
    let bottomRight = CGSize(
        width: max(0, min(cornerInsets.bottomRight.width, bounds.size.width - cornerInsets.bottomLeft.width)),
        height: max(0, min(cornerInsets.bottomRight.height, bounds.size.height - cornerInsets.topRight.height))
    )
    let path = CGMutablePath()
    pathAddEllipticArc(path: path, m: transform, origin: CGPoint(x: minX + topLeft.width, y: minY + topLeft.height), size: topLeft, startAngle: CGFloat(Double.pi), endAngle: CGFloat(3 * (Double.pi / 2)), clockwise: false)
    pathAddEllipticArc(path: path, m: transform, origin: CGPoint(x: maxX - topRight.width, y: minY + topRight.height), size: topRight, startAngle: CGFloat(3 * (Double.pi / 2)), endAngle: 0, clockwise: false)
    pathAddEllipticArc(path: path, m: transform, origin: CGPoint(x: maxX - bottomRight.width, y: maxY - bottomRight.height), size: bottomRight, startAngle: 0, endAngle: CGFloat(Double.pi / 2), clockwise: false)
    pathAddEllipticArc(path: path, m: transform, origin: CGPoint(x: minX + bottomLeft.width, y: maxY - bottomLeft.height), size: bottomLeft, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: false)
    return path
}

func ellipseGetIntersectionsWithLine(ellipseBounds: CGRect, lineStart: CGPoint, lineEnd: CGPoint) -> (CGPoint, CGPoint) {
    var vLineStart = lineStart, vLineEnd = lineEnd
    
    let ellipseCenter = CGPoint(x: ellipseBounds.midX, y: ellipseBounds.midY)
    
    vLineStart.x -= ellipseCenter.x
    vLineStart.y -= ellipseCenter.y
    vLineEnd.x -= ellipseCenter.x
    vLineEnd.y -= ellipseCenter.y
    
    let m = (vLineEnd.y - vLineStart.y) / (vLineEnd.x - vLineStart.x)
    let a = ellipseBounds.size.width / 2
    let b = ellipseBounds.size.height / 2
    let c = vLineStart.y - m * vLineStart.x
    let A = (b * b + a * a * m * m)
    let B = 2 * a * a * c * m
    
    let D1 = Double((a * a * (b * b - c * c)) / A)
    let D2 = pow(Double(B / (2 * A)), 2)
    let D = CGFloat(sqrt(D1 + D2))
    
    let x_ = -B / (2 * A)
    let x1 = x_ + D
    let x2 = x_ - D
    let y1 = m * x1 + c
    let y2 = m * x2 + c
    
    let intersection1 = CGPoint(x: x1 + ellipseCenter.x, y: y1 + ellipseCenter.y)
    let intersection2 = CGPoint(x: x2 + ellipseCenter.x, y: y2 + ellipseCenter.y)
    return (intersection1, intersection2)
}

func cornerRadiiAreAboveThreshold(_ cornerRadii: CornerRadii) -> Bool {
    return (
        cornerRadii.topLeft > borderThreshold ||
        cornerRadii.topRight > borderThreshold ||
        cornerRadii.bottomLeft > borderThreshold ||
        cornerRadii.bottomRight > borderThreshold
    )
}

func pathCreateOuterOutline(drawToEdge: Bool, rect: CGRect, cornerRadii: CornerRadii) -> CGPath {
    if drawToEdge {
        return CGPath(rect: rect, transform: nil)
    }
    return pathCreateWithRoundedRect(bounds: rect, cornerInsets: getCornerInsets(cornerRadii: cornerRadii, edgeInsets: .zero), transform: nil)
}

func GMUIGraphicsBeginImageContext(size: CGSize, backgroundColor: CGColor, hasCornerRadii: Bool, drawToEdge: Bool) -> CGContext {
    let alpha = backgroundColor.alpha
    let opaque = (drawToEdge || !hasCornerRadii) && alpha == 1.0
    UIGraphicsBeginImageContextWithOptions(size, opaque, 0.0)
    return UIGraphicsGetCurrentContext()!
}

func getSolidBorderImage(cornerRadii: CornerRadii,
                         viewSize: CGSize,
                         borderInsets: UIEdgeInsets,
                         borderColors: BorderColors,
                         backgroundColor: CGColor,
                         drawToEdge: Bool) -> UIImage {
    let hasCornerRadii = cornerRadiiAreAboveThreshold(cornerRadii)
    let cornerInsets = getCornerInsets(cornerRadii: cornerRadii, edgeInsets: borderInsets)
    
    let makeStretchable =
        (borderInsets.left + cornerInsets.topLeft.width +
            borderInsets.right + cornerInsets.bottomRight.width <= viewSize.width) &&
        (borderInsets.left + cornerInsets.bottomLeft.width +
                borderInsets.right + cornerInsets.topRight.width <= viewSize.width) &&
        (borderInsets.top + cornerInsets.topLeft.height +
                borderInsets.bottom + cornerInsets.bottomRight.height <= viewSize.height) &&
        (borderInsets.top + cornerInsets.topRight.height +
                borderInsets.bottom + cornerInsets.bottomLeft.height <= viewSize.height)
    
    let edgeInsets = UIEdgeInsets(
        top: borderInsets.top + max(cornerInsets.topLeft.height, cornerInsets.topRight.height),
        left: borderInsets.left + max(cornerInsets.topLeft.width, cornerInsets.bottomLeft.width),
        bottom: borderInsets.bottom + max(cornerInsets.bottomLeft.height, cornerInsets.bottomRight.height),
        right: borderInsets.right + max(cornerInsets.bottomRight.width, cornerInsets.topRight.width)
    )
    
    // 1pt for the middle stretchable area along each axis
    let size = makeStretchable ? CGSize(width: edgeInsets.left + 1 + edgeInsets.right, height: edgeInsets.top + 1 + edgeInsets.bottom) : viewSize
    
    let ctx = GMUIGraphicsBeginImageContext(size: size, backgroundColor: backgroundColor, hasCornerRadii: hasCornerRadii, drawToEdge: drawToEdge)
    let rect = CGRect(origin: .zero, size: size)
    let path = pathCreateOuterOutline(drawToEdge: drawToEdge, rect: rect, cornerRadii: cornerRadii)
    
    ctx.setFillColor(backgroundColor)
    ctx.addPath(path)
    ctx.fillPath()
    
    ctx.addPath(path)
    
    let insetPath = pathCreateWithRoundedRect(bounds: UIEdgeInsetsInsetRect(rect, borderInsets), cornerInsets: cornerInsets, transform: nil)
    
    ctx.addPath(insetPath)
    ctx.clip(using: .evenOdd)
    
    let hasEqualColors = borderColorsAreEqual(borderColors)
    if drawToEdge || !hasCornerRadii, hasEqualColors {
        ctx.setFillColor(borderColors.left)
        ctx.addRect(rect)
        ctx.addPath(insetPath)
        ctx.fillPath(using: .evenOdd)
    } else {
        var topLeft = CGPoint(x: borderInsets.left, y: borderInsets.top)
        if cornerInsets.topLeft.width > 0 && cornerInsets.topLeft.height > 0 {
            let points = ellipseGetIntersectionsWithLine(ellipseBounds: CGRect(origin: topLeft, size: CGSize(width: 2 * cornerInsets.topLeft.width, height: 2 * cornerInsets.topLeft.height)), lineStart: .zero, lineEnd: topLeft)
            if !points.1.x.isNaN && !points.1.y.isNaN {
                topLeft = points.1
            }
        }
        
        var bottomLeft = CGPoint(x: borderInsets.left, y: size.height - borderInsets.bottom)
        if cornerInsets.bottomLeft.width > 0 && cornerInsets.bottomLeft.height > 0 {
            let points = ellipseGetIntersectionsWithLine(ellipseBounds: CGRect(x: bottomLeft.x, y: bottomLeft.y - 2 * cornerInsets.bottomLeft.height, width: 2 * cornerInsets.bottomLeft.width, height: 2 * cornerInsets.bottomLeft.height), lineStart: CGPoint(x: 0, y: size.height), lineEnd: bottomLeft)
            if !points.1.x.isNaN && !points.1.y.isNaN {
                bottomLeft = points.1
            }
        }
        
        var topRight = CGPoint(x: size.width - borderInsets.right, y: borderInsets.top)
        if cornerInsets.topRight.width > 0 && cornerInsets.topRight.height > 0 {
            let points = ellipseGetIntersectionsWithLine(ellipseBounds: CGRect(x: topRight.x - 2 * cornerInsets.topRight.width, y: topRight.y, width: 2 * cornerInsets.topRight.width, height: 2 * cornerInsets.topRight.height), lineStart: CGPoint(x: size.width, y: 0), lineEnd: topRight)
            if !points.0.x.isNaN && !points.0.y.isNaN {
                topRight = points.0
            }
        }
        
        var bottomRight = CGPoint(x: size.width - borderInsets.right, y: size.height - borderInsets.bottom)
        if cornerInsets.bottomRight.width > 0 && cornerInsets.bottomRight.height > 0 {
            let points = ellipseGetIntersectionsWithLine(ellipseBounds: CGRect(x: bottomRight.x - 2 * cornerInsets.bottomRight.width, y: bottomRight.y - 2 * cornerInsets.bottomRight.height, width: 2 * cornerInsets.bottomRight.width, height: 2 * cornerInsets.bottomRight.height), lineStart: CGPoint(x: size.width, y: size.height), lineEnd: bottomRight)
            if !points.0.x.isNaN && !points.0.y.isNaN {
                bottomRight = points.0
            }
        }
        
        var currentColor: CGColor? = nil
        
        // RIGHT
        if borderInsets.right > 0 {
            let points = [
                CGPoint(x: size.width, y: 0),
                topRight,
                bottomRight,
                CGPoint(x: size.width, y: size.height)
            ]
            
            currentColor = borderColors.right
            ctx.addLines(between: points)
        }
        
        // BOTTOM
        if borderInsets.bottom > 0 {
            let points = [
                CGPoint(x: 0, y: size.height),
                bottomLeft,
                bottomRight,
                CGPoint(x: size.width, y: size.height)
            ]
            
            if currentColor != borderColors.bottom {
                if let currentColor = currentColor {
                    ctx.setFillColor(currentColor)
                    ctx.fillPath()
                }
                currentColor = borderColors.bottom
            }
            ctx.addLines(between: points)
        }
        
        // LEFT
        if borderInsets.left > 0 {
            let points = [
                CGPoint.zero,
                topLeft,
                bottomLeft,
                CGPoint(x: 0, y: size.height)
            ]
            
            if currentColor != borderColors.left {
                if let currentColor = currentColor {
                    ctx.setFillColor(currentColor)
                    ctx.fillPath()
                }
                currentColor = borderColors.left
            }
            ctx.addLines(between: points)
        }
        
        // TOP
        if borderInsets.top > 0 {
            let points = [
                CGPoint.zero,
                topLeft,
                topRight,
                CGPoint(x: size.width, y: 0)
            ]
            
            if currentColor != borderColors.top {
                if let currentColor = currentColor {
                    ctx.setFillColor(currentColor)
                    ctx.fillPath()
                }
                currentColor = borderColors.top
            }
            ctx.addLines(between: points)
        }
        
        if let currentColor = currentColor {
            ctx.setFillColor(currentColor)
        }
        ctx.fillPath()
    }
    
    var image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    if makeStretchable {
        image = image?.resizableImage(withCapInsets: edgeInsets)
    }
    
    return image!
}

// Currently, the dashed / dotted implementation only supports a single colour +
// single width, as that's currently required and supported on Android.
//
// Supporting individual widths + colours on each side is possible by modifying
// the current implementation. The idea is that we will draw four different lines
// and clip appropriately for each side (might require adjustment of phase so that
// they line up but even browsers don't do a good job at that).
//
// Firstly, create two paths for the outer and inner paths. The inner path is
// generated exactly the same way as the outer, just given an inset rect, derived
// from the insets on each side. Then clip using the odd-even rule
// (CGContextEOClip()). This will give us a nice rounded (possibly) clip mask.
//
// +----------------------------------+
// |@@@@@@@@  Clipped Space  @@@@@@@@@|
// |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|
// |@@+----------------------+@@@@@@@@|
// |@@|                      |@@@@@@@@|
// |@@|                      |@@@@@@@@|
// |@@|                      |@@@@@@@@|
// |@@+----------------------+@@@@@@@@|
// |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|
// +----------------------------------+
//
// Afterwards, we create a clip path for each border side (CGContextSaveGState()
// and CGContextRestoreGState() when drawing each side). The clip mask for each
// segment is a trapezoid connecting corresponding edges of the inner and outer
// rects. For example, in the case of the top edge, the points would be:
// - (MinX(outer), MinY(outer))
// - (MaxX(outer), MinY(outer))
// - (MinX(inner) + topLeftRadius, MinY(inner) + topLeftRadius)
// - (MaxX(inner) - topRightRadius, MinY(inner) + topRightRadius)
//
//         +------------------+
//         |\                /|
//         | \              / |
//         |  \    top     /  |
//         |   \          /   |
//         |    \        /    |
//         |     +------+     |
//         |     |      |     |
//         |     |      |     |
//         |     |      |     |
//         |left |      |right|
//         |     |      |     |
//         |     |      |     |
//         |     +------+     |
//         |    /        \    |
//         |   /          \   |
//         |  /            \  |
//         | /    bottom    \ |
//         |/                \|
//         +------------------+
//
//
// Note that this approach will produce discontinous colour changes at the edge
// (which is okay). The reason is that Quartz does not currently support drawing
// of gradients _along_ a path (NB: clipping a path and drawing a linear gradient
// is _not_ equivalent).

func getDashedOrDottedBorderImage(borderStyle: BorderStyle,
                                  cornerRadii: CornerRadii,
                                  viewSize: CGSize,
                                  borderInsets: UIEdgeInsets,
                                  borderColors: BorderColors,
                                  backgroundColor: CGColor,
                                  drawToEdge: Bool) -> UIImage? {
    assert(borderStyle == .dashed || borderStyle == .dotted)
    
    if !borderColorsAreEqual(borderColors) || !borderInsetsAreEqual(borderInsets) {
        print("Unsupported dashed / dotted border style")
        return nil
    }
    
    let lineWidth = borderInsets.top
    if lineWidth <= 0.0 {
        return nil
    }
    
    let hasCornerRadii = cornerRadiiAreAboveThreshold(cornerRadii)
    let ctx = GMUIGraphicsBeginImageContext(size: viewSize, backgroundColor: backgroundColor, hasCornerRadii: hasCornerRadii, drawToEdge: drawToEdge)
    let rect = CGRect(origin: .zero, size: viewSize)
    
    let outerPath = pathCreateOuterOutline(drawToEdge: drawToEdge, rect: rect, cornerRadii: cornerRadii)
    ctx.addPath(outerPath)
    
    ctx.setFillColor(backgroundColor)
    ctx.fillPath()
    
    // Stroking means that the width is divided in half and grows in both directions
    // perpendicular to the path, that's why we inset by half the width, so that it
    // reaches the edge of the rect.
    let pathRect = rect.insetBy(dx: lineWidth / 2.0, dy: lineWidth / 2.0)
    let path = pathCreateWithRoundedRect(bounds: pathRect, cornerInsets: getCornerInsets(cornerRadii: cornerRadii, edgeInsets: .zero), transform: nil)
    
    let dashLengths = [CGFloat](repeating: (borderStyle == .dashed ? 3 : 1) * lineWidth, count: 2)
    
    ctx.setLineWidth(lineWidth)
    ctx.setLineDash(phase: 0, lengths: dashLengths)
    
    ctx.setStrokeColor(UIColor.yellow.cgColor)
    
    ctx.addPath(path)
    ctx.setStrokeColor(borderColors.top)
    ctx.strokePath()
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    return image
}

func getBorderImage(borderStyle: BorderStyle,
                    viewSize: CGSize,
                    cornerRadii: CornerRadii,
                    borderInsets: UIEdgeInsets,
                    borderColors: BorderColors,
                    backgroundColor: CGColor,
                    drawToEdge: Bool) -> UIImage? {
    switch borderStyle {
    case .solid:
        return getSolidBorderImage(cornerRadii: cornerRadii, viewSize: viewSize, borderInsets: borderInsets, borderColors: borderColors, backgroundColor: backgroundColor, drawToEdge: drawToEdge)
    case .dashed, .dotted:
        return getDashedOrDottedBorderImage(borderStyle: borderStyle, cornerRadii: cornerRadii, viewSize: viewSize, borderInsets: borderInsets, borderColors: borderColors, backgroundColor: backgroundColor, drawToEdge: drawToEdge)
    }
}
