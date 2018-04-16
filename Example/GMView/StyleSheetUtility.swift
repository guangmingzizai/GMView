//
//  StyleSheetUtility.swift
//  OneOne
//
//  Created by wangjianfei on 2017/12/20.
//  Copyright © 2017年 zheli.tech. All rights reserved.
//

import UIKit

public struct StyleSheetItemKey : RawRepresentable, Equatable, Hashable {
    public init(rawValue: String) {
        self.rawValue = rawValue
        self.hashValue = rawValue.hashValue
    }
    
    public var rawValue: String
    
    public typealias RawValue = String
    
    public static func ==(lhs: StyleSheetItemKey, rhs: StyleSheetItemKey) -> Bool {
        return (lhs.rawValue == rhs.rawValue)
    }
    
    public var hashValue: Int
}

enum AdaptiveBase {
    case width
    case height
}

enum StyleSheetProperty: String {
    case top, left, bottom, right
    case width, height, sizeLength
    case margin, marginTop, marginLeft, marginBottom, marginRight, marginHorizontal, marginVertical
    case padding, paddingTop, paddingLeft, paddingBottom, paddingRight, paddingHorizontal, paddingVertical
    case maxWidth, maxHeight, minWidth, minHeight
    case fontSize
    case borderRadius
    case borderWidth
}

typealias StyleSheet = [StyleSheetItemKey: [StyleSheetProperty: Float]]

class StyleSheetUtility {
    static func isIPhoneX() -> Bool {
        return (UIScreen.main.bounds.height == 812)
    }
    
    static func adaptiveStyleSheet(_ styleSheet: StyleSheet, base: AdaptiveBase = .width) -> StyleSheet {
        return styleSheet.mapValues { (style: [StyleSheetProperty: Float]) -> [StyleSheetProperty: Float] in
            style.mapValues({ adaptiveValue($0, base: base) })
        }
    }
    
    static func adaptiveValue(_ value: Float, base: AdaptiveBase = .width) -> Float {
        let designScreenWidth: Float = 375, designScreenHeight: Float = 667
        let screenWidth: Float = Float(UIScreen.main.bounds.width), screenHeight: Float = Float(UIScreen.main.bounds.height)
        
        return (value * (base == .width ? (screenWidth / designScreenWidth) : (screenHeight / designScreenHeight)))
    }
}

func adaptiveLayoutValue(_ value: Float, base: AdaptiveBase = .width) -> Float {
    return StyleSheetUtility.adaptiveValue(value, base: base)
}

func adaptiveLayoutValue(_ value: CGFloat, base: AdaptiveBase = .width) -> CGFloat {
    return CGFloat(StyleSheetUtility.adaptiveValue(Float(value), base: base))
}

func adaptiveLayoutValue(_ value: CGRect, base: AdaptiveBase = .width) -> CGRect {
    return CGRect(x: adaptiveLayoutValue(value.origin.x), y: adaptiveLayoutValue(value.origin.y), width: adaptiveLayoutValue(value.size.width), height: adaptiveLayoutValue(value.size.height))
}

func scalable(_ value: Float, base: AdaptiveBase = .width) -> Float {
    return StyleSheetUtility.adaptiveValue(value, base: base)
}

func scalable(_ value: CGFloat, base: AdaptiveBase = .width) -> CGFloat {
    return CGFloat(StyleSheetUtility.adaptiveValue(Float(value), base: base))
}

func scalable(_ value: CGRect, base: AdaptiveBase = .width) -> CGRect {
    return CGRect(x: adaptiveLayoutValue(value.origin.x), y: adaptiveLayoutValue(value.origin.y), width: adaptiveLayoutValue(value.size.width), height: adaptiveLayoutValue(value.size.height))
}

func scalable(_ value: UIEdgeInsets, base: AdaptiveBase = .width) -> UIEdgeInsets {
    return UIEdgeInsetsMake(adaptiveLayoutValue(value.top), adaptiveLayoutValue(value.left), adaptiveLayoutValue(value.bottom), adaptiveLayoutValue(value.right))
}

func scalable(_ value: CGSize, base: AdaptiveBase = .width) -> CGSize {
    return CGSize(width: scalable(value.width), height: scalable(value.height))
}

func isIPhoneX() -> Bool {
    return (UIScreen.main.bounds.height == 812)
}
